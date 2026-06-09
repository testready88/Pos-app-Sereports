package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponesInventoryItemDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseProductInventoryDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.util.CacheKeyGenerator;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@Service
@Repository
@RequiredArgsConstructor
public class ProductServiceImpl {
    private final CompanyUserService companyUserService;

    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate mainJdbcTemplate;

    // Make Redis optional - will be null if Redis is not available
    @Autowired(required = false)
    private RedisTemplate<String, Object> redisTemplate;

    public PaginatedResponseProductInventoryDTO getPaginatedInventoryItems(
            String searchProduct,
            String categoryName,
            String subCategoryName,
            String supplierName,
            String stockLevel,
            String itemSaleType,
            String token,
            int page,
            int size) throws SQLException {

        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);
        String companyId = userAllData.getCompanyId();

        // Try to get from cache if Redis is available
        if (redisTemplate != null) {
            // Generate cache keys
            String productCacheKey = CacheKeyGenerator.generateProductCacheKey(
                    companyId, searchProduct, categoryName, subCategoryName,
                    supplierName, stockLevel, itemSaleType, page, size);
            String countCacheKey = CacheKeyGenerator.generateProductCountCacheKey(
                    companyId, searchProduct, categoryName, subCategoryName,
                    supplierName, stockLevel, itemSaleType);

            try {
                // Try to get from cache
                @SuppressWarnings("unchecked")
                List<ResponesInventoryItemDTO> cachedData = (List<ResponesInventoryItemDTO>) redisTemplate.opsForValue().get(productCacheKey);
                Long cachedCount = (Long) redisTemplate.opsForValue().get(countCacheKey);

                if (cachedData != null && cachedCount != null) {
                    // Return cached data
                    return PaginatedResponseProductInventoryDTO.builder()
                            .data(cachedData)
                            .count(cachedCount)
                            .build();
                }
            } catch (Exception e) {
                // If Redis fails, continue with database query
                System.err.println("Redis cache error, falling back to database: " + e.getMessage());
            }
        }

        // Cache miss - fetch from database
        StringBuilder dataSql = new StringBuilder();
        List<Object> dataParams = new ArrayList<>();
        buildBaseQuery(dataSql);
        applyCommonFilters(dataSql, dataParams, searchProduct, categoryName, subCategoryName,
                supplierName, stockLevel, itemSaleType, companyId);

        dataSql.append("ORDER BY tbl_PriceLink1.ItemName ASC "); // Use ItemName from SELECT list (tbl_PriceLink1.ItemName)
        dataSql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        dataParams.add(page * size);
        dataParams.add(size);

        StringBuilder countSql = new StringBuilder();
        List<Object> countParams = new ArrayList<>();
        countSql.append("SELECT COUNT(DISTINCT CONCAT(tbl_PriceLink1.ItemCode, '|', tbl_PriceLink1.ItemBarcode)) FROM tbl_PriceLink1 ");
        countSql.append("INNER JOIN tbl_ItemDet ON tbl_ItemDet.ItemCode=tbl_PriceLink1.ItemCode ");
        countSql.append("AND tbl_PriceLink1.LocaCode=tbl_ItemDet.LocaCode ");
        countSql.append("AND tbl_ItemDet.CompID=tbl_PriceLink1.CompID "); // Ensure CompID matches
        applyCommonFilters(countSql, countParams, searchProduct, categoryName, subCategoryName,
                supplierName, stockLevel, itemSaleType, companyId);

        List<ResponesInventoryItemDTO> data = mainJdbcTemplate.query(
                dataSql.toString(),
                dataParams.toArray(),
                new InventoryItemRowMapper()
        );

        Long count = mainJdbcTemplate.queryForObject(
                countSql.toString(),
                countParams.toArray(),
                Long.class
        );

        long finalCount = count != null ? count : 0;

        // Cache the results if Redis is available (TTL: 1 hour as configured in RedisConfig)
        if (redisTemplate != null) {
            try {
                String productCacheKey = CacheKeyGenerator.generateProductCacheKey(
                        companyId, searchProduct, categoryName, subCategoryName,
                        supplierName, stockLevel, itemSaleType, page, size);
                String countCacheKey = CacheKeyGenerator.generateProductCountCacheKey(
                        companyId, searchProduct, categoryName, subCategoryName,
                        supplierName, stockLevel, itemSaleType);
                
                redisTemplate.opsForValue().set(productCacheKey, data, java.time.Duration.ofHours(1));
                redisTemplate.opsForValue().set(countCacheKey, finalCount, java.time.Duration.ofHours(1));
            } catch (Exception e) {
                // If caching fails, continue without caching
                System.err.println("Failed to cache product data: " + e.getMessage());
            }
        }

        return PaginatedResponseProductInventoryDTO.builder()
                .data(data)
                .count(finalCount)
                .build();
    }

    /**
     * Evict all product caches for a specific company
     * Call this method when products are updated/added/deleted
     */
    public void evictProductCache(String companyId) {
        if (redisTemplate == null) {
            return; // Redis not available, nothing to evict
        }
        
        try {
            // Get all keys matching the pattern
            Set<String> productKeys = redisTemplate.keys(CacheKeyGenerator.generateCompanyProductCachePattern(companyId));
            Set<String> countKeys = redisTemplate.keys(CacheKeyGenerator.generateCompanyProductCountCachePattern(companyId));

            if (productKeys != null && !productKeys.isEmpty()) {
                redisTemplate.delete(productKeys);
            }
            if (countKeys != null && !countKeys.isEmpty()) {
                redisTemplate.delete(countKeys);
            }
        } catch (Exception e) {
            // Log error but don't fail the operation
            System.err.println("Error evicting product cache for company: " + companyId + " - " + e.getMessage());
        }
    }

    private void buildBaseQuery(StringBuilder sql) {
        sql.append("SELECT DISTINCT tbl_PriceLink1.CompID, tbl_PriceLink1.LocaCode, tbl_PriceLink1.StockID, ");
        sql.append("tbl_PriceLink1.ItemCode, tbl_PriceLink1.ItemBarcode, tbl_PriceLink1.ItemName, ");
        sql.append("tbl_PriceLink1.QtyRemain, tbl_PriceLink1.ItemAvgCost, tbl_PriceLink1.ItemUPrice, ");
        sql.append("tbl_PriceLink1.ItemSPrice, tbl_PriceLink1.ItemDPrice, tbl_PriceLink1.ItemCatName, ");
        sql.append("tbl_PriceLink1.ItemSubCatName1, tbl_PriceLink1.ItemSupName, tbl_ItemDet.ProductImg1 ");
        sql.append("FROM tbl_PriceLink1 ");
        sql.append("INNER JOIN tbl_ItemDet ON tbl_ItemDet.ItemCode=tbl_PriceLink1.ItemCode ");
        sql.append("AND tbl_PriceLink1.LocaCode=tbl_ItemDet.LocaCode ");
        sql.append("AND tbl_ItemDet.CompID=tbl_PriceLink1.CompID "); // Ensure CompID matches to avoid duplicates
    }

    private void applyCommonFilters(StringBuilder sql, List<Object> params,
                                    String searchProduct, String categoryName,
                                    String subCategoryName, String supplierName,
                                    String stockLevel, String itemSaleType,
                                    String companyId) {
        sql.append("WHERE tbl_PriceLink1.CompID=? ");
        params.add(companyId);
        sql.append("AND tbl_ItemDet.CompID=? "); // Also filter ItemDet by CompID to avoid cross-company duplicates
        params.add(companyId);
        sql.append("AND tbl_ItemDet.chkActiveItem='1' ");
        sql.append("AND tbl_ItemDet.ItemBarcode!='*1' ");
        sql.append("AND tbl_ItemDet.ItemCatCode!='CAT-11-000000' ");
        sql.append("AND tbl_ItemDet.chkShowPriceLink='1' ");
        sql.append("AND ItemUPrice!=0 AND ItemSPrice!=0 ");

        if (!StringUtils.isEmpty(searchProduct)) {
            sql.append("AND (tbl_ItemDet.ItemName LIKE ? ");
            sql.append("OR tbl_ItemDet.ItemBarcode LIKE ? ");
            sql.append("OR tbl_ItemDet.ItemBarcode1 LIKE ? ");
            sql.append("OR tbl_ItemDet.ItemBarcode2 LIKE ? ");
            sql.append("OR tbl_ItemDet.ItemUnit LIKE ? ");
            sql.append("OR tbl_ItemDet.ItemMake LIKE ? ");
            sql.append("OR tbl_ItemDet.PartNo1 LIKE ? ");
            sql.append("OR tbl_ItemDet.PartNo2 LIKE ? ");
            sql.append("OR tbl_ItemDet.PartNo3 LIKE ? ");
            sql.append("OR tbl_ItemDet.PartNo4 LIKE ?) ");
            for (int i = 0; i < 10; i++) {
                params.add("%" + searchProduct + "%");
            }
        }

        if (isNullOrAll(categoryName)) {
            sql.append("AND tbl_ItemDet.ItemCatName= ? ");
            params.add(categoryName);
        }

        if (isNullOrAll(subCategoryName)) {
            sql.append("AND tbl_ItemDet.ItemSubCatName1= ? ");
            params.add(subCategoryName);
        }

        if (isNullOrAll(supplierName)) {
            sql.append("AND tbl_ItemDet.ItemSupName= ? ");
            params.add(supplierName);
        }

        if (isNullOrAll(stockLevel)) {
            switch (stockLevel.trim()) {
                case "Status Ok":
                    sql.append("AND tbl_PriceLink1.QtyRemain>tbl_PriceLink1.QtyOL ");
                    break;
                case "Out Of Stock":
                    sql.append("AND tbl_PriceLink1.QtyRemain <= 0 ");
                    break;
                case "Minus stock":
                    sql.append("AND tbl_PriceLink1.QtyRemain < 0 ");
                    break;
                case "Re Order Stock":
                    sql.append("AND ((tbl_PriceLink1.QtyRemain) <= (tbl_PriceLink1.QtyOL) AND (tbl_PriceLink1.QtyRemain) > 0 ) ");
                    break;
            }
        }

        if (isNullOrAll(itemSaleType)) {
            switch (itemSaleType.trim()) {
                case "Discounted item":
                    sql.append("AND tbl_PriceLink1.ItemDPrice!=0 ");
                    break;
                case "L.Discounted Item":
                    sql.append("AND tbl_PriceLink1.ItemLDPrice!=0 ");
                    break;
                case "Offer item":
                    sql.append("AND tbl_PriceLink1.ItemOPrice!=0 ");
                    break;
                case "Wholesale Items":
                    sql.append("AND tbl_PriceLink1.ItemWPrice!=0 ");
                    break;
                case "No Discount Items":
                    sql.append("AND tbl_PriceLink1.ItemDPrice = 0 AND tbl_PriceLink1.ItemLDPrice = 0 AND tbl_PriceLink1.ItemOPrice = 0 ");
                    break;
                case "New Featured":
                    sql.append("AND tbl_Itemdet.ItemSaleType='New Featured' ");
                    break;
                case "Hot Sales":
                    sql.append("AND tbl_Itemdet.ItemSaleType='Hot Sale' ");
                    break;
                case "Day Of The Day":
                    sql.append("AND tbl_Itemdet.ItemSaleType='Deal Of The Day' ");
                    break;
            }
        }
    }

    private boolean isNullOrAll(String value) {
        return value != null && !value.isEmpty() && !"All".equals(value);
    }

    private static class InventoryItemRowMapper implements RowMapper<ResponesInventoryItemDTO> {
        @Override
        public ResponesInventoryItemDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            return ResponesInventoryItemDTO.builder()
                    .compId(rs.getString("CompID"))
                    .locaCode(rs.getString("LocaCode"))
                    .stockId(rs.getString("StockID"))
                    .itemCode(rs.getString("ItemCode"))
                    .itemBarcode(rs.getString("ItemBarcode"))
                    .itemName(rs.getString("ItemName"))
                    .qtyRemain(rs.getDouble("QtyRemain"))
                    .itemAvgCost(rs.getDouble("ItemAvgCost"))
                    .itemUPrice(rs.getDouble("ItemUPrice"))
                    .itemSPrice(rs.getDouble("ItemSPrice"))
                    .itemDPrice(rs.getDouble("ItemDPrice"))
                    .itemCatName(rs.getString("ItemCatName"))
                    .itemSubCatName1(rs.getString("ItemSubCatName1"))
                    .itemSupName(rs.getString("ItemSupName"))
                    .productImg1(rs.getString("ProductImg1"))
                    .build();
        }
    }
}