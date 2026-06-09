package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponsePurchaseDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.PurchaseService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PurchaseServiceImpl implements PurchaseService {
    private final JdbcTemplate mainJdbcTemplate;
    private final CompanyUserService companyUserService;

    @Override
    public PaginatedResponsePurchaseDTO getPurchaseDetails(String token, String locaCode, String searchItem,
                                                           String searchCategory, String searchSupplier, String purchaseType, LocalDate dateFrom,
                                                           LocalDate dateTo, int page, int size) throws SQLException {



        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();



        // Format dates with time components
        String formattedDateFrom = dateFrom.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 00:00:00";
        String formattedDateTo = dateTo.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 23:59:59";


        // Build filter conditions
        String locationFilterPurDet = buildLocationFilter(locaCode, "tbl_PurDet");
        String locationFilterPurSummery = buildLocationFilter(locaCode, "tbl_PurSummery");
        String itemFilter = buildItemFilter(searchItem);
        String categoryFilter = buildCategoryFilter(searchCategory);
        String supplierFilter = buildSupplierFilter(searchSupplier);
        String purchaseTypeFilter = buildPurchaseTypeFilter(purchaseType);

        // Use simple date comparison
        String dateFilterPurDet = "AND tbl_Purdet.CreateDate >= ? AND tbl_Purdet.CreateDate <= ?";
        String dateFilterPurSummery = "AND tbl_PurSummery.CreateDate >= ? AND tbl_PurSummery.CreateDate <= ?";

        // Build parameters in correct order based on actual filters being used
        List<Object> dataParams = new ArrayList<>();

        // Add search filter parameters first (based on which filters are active)
        if (searchItem != null && !searchItem.isEmpty() && !"All".equals(searchItem)) {
            String searchPattern = "%" + searchItem + "%";
            for (int i = 0; i < 7; i++) { // 7 fields in item search
                dataParams.add(searchPattern);
            }
        }

        if (searchCategory != null && !searchCategory.isEmpty() && !"All".equals(searchCategory)) {
            String searchPattern = "%" + searchCategory + "%";
            dataParams.add(searchPattern);
            dataParams.add(searchPattern);
        }

        if (searchSupplier != null && !searchSupplier.isEmpty() && !"All".equals(searchSupplier)) {
            String searchPattern = "%" + searchSupplier + "%";
            dataParams.add(searchPattern);
            dataParams.add(searchPattern);
        }

        // Add date parameters
        dataParams.add(formattedDateFrom);
        dataParams.add(formattedDateTo);

        // Add company IDs
        dataParams.add(companyId);
        dataParams.add(companyId);

        // Add location parameter if needed
        if (!"All".equals(locaCode) && !locationFilterPurSummery.isEmpty()) {
            dataParams.add(locaCode);
        }

        // Add pagination parameters
        dataParams.add(page * size);
        dataParams.add(size);

        // Build SQL with only active filters
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT tbl_PurDet.LocaCode, tbl_PurDet.CreateDate, tbl_PurDet.InvoiceNo, tbl_PurDet.SerialNo, ");
        sqlBuilder.append("tbl_PurDet.ID, tbl_PurDet.ItemCode, tbl_PurDet.ItemBarcode, tbl_PurDet.ItemName, tbl_PurDet.Qty, ");
        sqlBuilder.append("tbl_PurDet.FreeQty, tbl_PurDet.ItemUPrice1, tbl_PurDet.ItemDis1, tbl_PurDet.ItemDis2, tbl_PurDet.ItemUPrice, ");
        sqlBuilder.append("((tbl_PurDet.Qty+tbl_Purdet.FreeQty)*tbl_PurDet.ItemUPrice) AS TotalAmount, ");
        sqlBuilder.append("(CASE WHEN tbl_PurDet.ItemSPrice<>0 THEN (tbl_PurDet.ItemSPrice-tbl_PurDet.ItemUPrice)*100/tbl_PurDet.ItemSPrice ELSE 0 END) AS GPPer, ");
        sqlBuilder.append("tbl_PurDet.ItemSPrice, tbl_PurDet.ItemDPrice, tbl_PurDet.ItemExpDate, tbl_PurDet.ItemSupName, ");
        sqlBuilder.append("tbl_PurDet.ItemCatName, tbl_PurDet.CreateBy ");
        sqlBuilder.append("FROM tbl_PurDet INNER JOIN tbl_PurSummery ON tbl_PurSummery.SerialNo=tbl_PurDet.SerialNo ");
        sqlBuilder.append("WHERE (Left(tbl_PurDet.SerialNo, 8)!='PCHM-SUP' AND Left(tbl_PurDet.SerialNo, 8)!='PCHN-SUP') ");

        // Add filters only if they're not empty
        if (!purchaseTypeFilter.isEmpty()) {
            sqlBuilder.append(purchaseTypeFilter);
        }
        if (!itemFilter.isEmpty()) {
            sqlBuilder.append(itemFilter);
        }
        if (!categoryFilter.isEmpty()) {
            sqlBuilder.append(categoryFilter);
        }
        if (!supplierFilter.isEmpty()) {
            sqlBuilder.append(supplierFilter);
        }

        sqlBuilder.append("AND tbl_Purdet.CreateDate >= ? AND tbl_Purdet.CreateDate <= ? ");
        sqlBuilder.append("AND tbl_PurDet.CompID=? AND tbl_PurSummery.CompID=? ");

        if (!locationFilterPurSummery.isEmpty()) {
            sqlBuilder.append(locationFilterPurSummery).append(" ");
        }

        sqlBuilder.append("ORDER BY tbl_PurDet.CreateDate DESC ");
        sqlBuilder.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        String dataSql = sqlBuilder.toString();



        // Execute query and map results
        List<Object> purchases = mainJdbcTemplate.query(dataSql, dataParams.toArray(), (rs, rowNum) -> {
            Map<String, Object> purchase = new HashMap<>();
            purchase.put("locaCode", rs.getString("LocaCode"));
            purchase.put("createDate", rs.getDate("CreateDate"));
            purchase.put("invoiceNo", rs.getString("InvoiceNo"));
            purchase.put("serialNo", rs.getString("SerialNo"));
            purchase.put("id", rs.getString("ID"));
            purchase.put("itemCode", rs.getString("ItemCode"));
            purchase.put("itemBarcode", rs.getString("ItemBarcode"));
            purchase.put("itemName", rs.getString("ItemName"));
            purchase.put("qty", rs.getDouble("Qty"));
            purchase.put("freeQty", rs.getDouble("FreeQty"));
            purchase.put("itemUPrice1", rs.getDouble("ItemUPrice1"));
            purchase.put("itemDis1", rs.getDouble("ItemDis1"));
            purchase.put("itemDis2", rs.getDouble("ItemDis2"));
            purchase.put("itemUPrice", rs.getDouble("ItemUPrice"));
            purchase.put("totalAmount", rs.getDouble("TotalAmount"));
            purchase.put("gpPer", rs.getDouble("GPPer"));
            purchase.put("itemSPrice", rs.getDouble("ItemSPrice"));
            purchase.put("itemDPrice", rs.getDouble("ItemDPrice"));
            purchase.put("itemExpDate", rs.getDate("ItemExpDate"));
            purchase.put("itemSupName", rs.getString("ItemSupName"));
            purchase.put("itemCatName", rs.getString("ItemCatName"));
            purchase.put("createBy", rs.getString("CreateBy"));
            return purchase;
        });

        // Build count query with same filters
        List<Object> countParams = new ArrayList<>();

        // Add search filter parameters in same order
        if (searchItem != null && !searchItem.isEmpty() && !"All".equals(searchItem)) {
            String searchPattern = "%" + searchItem + "%";
            for (int i = 0; i < 7; i++) {
                countParams.add(searchPattern);
            }
        }

        if (searchCategory != null && !searchCategory.isEmpty() && !"All".equals(searchCategory)) {
            String searchPattern = "%" + searchCategory + "%";
            countParams.add(searchPattern);
            countParams.add(searchPattern);
        }

        if (searchSupplier != null && !searchSupplier.isEmpty() && !"All".equals(searchSupplier)) {
            String searchPattern = "%" + searchSupplier + "%";
            countParams.add(searchPattern);
            countParams.add(searchPattern);
        }

        // Add date parameters
        countParams.add(formattedDateFrom);
        countParams.add(formattedDateTo);

        // Add company IDs
        countParams.add(companyId);
        countParams.add(companyId);

        // Add location parameter if needed
        if (!"All".equals(locaCode) && !locationFilterPurSummery.isEmpty()) {
            countParams.add(locaCode);
        }

        StringBuilder countSqlBuilder = new StringBuilder();
        countSqlBuilder.append("SELECT COUNT(*) FROM tbl_PurDet INNER JOIN tbl_PurSummery ON tbl_PurSummery.SerialNo=tbl_PurDet.SerialNo ");
        countSqlBuilder.append("WHERE (Left(tbl_PurDet.SerialNo, 8)!='PCHM-SUP' AND Left(tbl_PurDet.SerialNo, 8)!='PCHN-SUP') ");

        // Add same filters as main query
        if (!purchaseTypeFilter.isEmpty()) {
            countSqlBuilder.append(purchaseTypeFilter);
        }
        if (!itemFilter.isEmpty()) {
            countSqlBuilder.append(itemFilter);
        }
        if (!categoryFilter.isEmpty()) {
            countSqlBuilder.append(categoryFilter);
        }
        if (!supplierFilter.isEmpty()) {
            countSqlBuilder.append(supplierFilter);
        }

        countSqlBuilder.append("AND tbl_Purdet.CreateDate >= ? AND tbl_Purdet.CreateDate <= ? ");
        countSqlBuilder.append("AND tbl_PurDet.CompID=? AND tbl_PurSummery.CompID=? ");

        if (!locationFilterPurSummery.isEmpty()) {
            countSqlBuilder.append(locationFilterPurSummery);
        }

        String countSql = countSqlBuilder.toString();


        Long totalCount = mainJdbcTemplate.queryForObject(countSql, countParams.toArray(), Long.class);

        // Get Purchase Summaries
        Map<String, Double> purchaseSummary = getPurchaseSummary(companyId, locaCode, formattedDateFrom, formattedDateTo);
        Map<String, Double> paymentSummary = getPaymentSummary(companyId, locaCode, formattedDateFrom, formattedDateTo);

        // Calculate final net purchase
        Double netPurchase = purchaseSummary.get("netPurchase") +
                paymentSummary.get("transportCharge") +
                paymentSummary.get("labourCharge") -
                paymentSummary.get("cashDiscountPur");

        // Build response
        return PaginatedResponsePurchaseDTO.builder()
                .count(totalCount)
                .data(purchases)
                .totalQtyPur(purchaseSummary.get("totalQtyPur"))
                .grossPurchase(purchaseSummary.get("grossPurchase"))
                .itemDiscountPur(purchaseSummary.get("itemDiscountPur"))
                .netPurchase(netPurchase)
                .cashDiscountPur(paymentSummary.get("cashDiscountPur"))
                .advancePaymentPur(paymentSummary.get("advancePaymentPur"))
                .chqPaymentPur(paymentSummary.get("chqPaymentPur"))
                .cardPaymentPur(paymentSummary.get("cardPaymentPur"))
                .creditPaymentPur(paymentSummary.get("creditPaymentPur"))
                .cashPaymentPur(paymentSummary.get("cashPaymentPur"))
                .transportCharge(paymentSummary.get("transportCharge"))
                .labourCharge(paymentSummary.get("labourCharge"))
                .build();
    }

    /**
     * Get purchase summary information
     */
    private Map<String, Double> getPurchaseSummary(String companyId, String locaCode, String dateFrom, String dateTo) {
        String locationFilter = buildLocationFilter(locaCode, "tbl_PurDet");
        String dateFilter = "AND tbl_Purdet.CreateDate >= ? AND tbl_Purdet.CreateDate <= ?";

        // FIXED: Correct parameter order
        List<Object> params = new ArrayList<>();

        // Add date parameters first
        params.add(dateFrom);
        params.add(dateTo);

        // Add company IDs
        params.add(companyId);
        params.add(companyId);

        // Add location parameter if needed
        if (!"All".equals(locaCode) && !locationFilter.isEmpty()) {
            params.add(locaCode);
        }

        String summarySql = "SELECT " +
                "SUM((tbl_PurDet.Qty+tbl_PurDet.FreeQty)) AS TotalQtyPur, " +
                "SUM((tbl_PurDet.Qty+tbl_PurDet.FreeQty) * tbl_PurDet.ItemSPrice) AS GrossPurchase, " +
                "SUM((tbl_PurDet.Qty+tbl_PurDet.FreeQty) * tbl_PurDet.ItemUPrice) AS NetPurchase, " +
                "SUM((tbl_PurDet.Qty+tbl_PurDet.FreeQty)*(tbl_PurDet.ItemSPrice-tbl_PurDet.ItemUPrice)) AS ItemDiscount " +
                "FROM tbl_PurDet INNER JOIN tbl_PurSummery ON tbl_PurSummery.SerialNo=tbl_PurDet.SerialNo " +
                "WHERE (Left(tbl_PurDet.SerialNo, 8)!='PCHM-SUP' AND Left(tbl_PurDet.SerialNo, 8)!='PCHN-SUP') " +
                dateFilter + " " +
                "AND tbl_PurDet.CompID=? AND tbl_PurSummery.CompID=? " + locationFilter;

        return mainJdbcTemplate.queryForObject(summarySql, params.toArray(), (rs, rowNum) -> {
            Map<String, Double> summary = new HashMap<>();
            summary.put("totalQtyPur", rs.getObject("TotalQtyPur", Double.class) != null ? rs.getDouble("TotalQtyPur") : 0.0);
            summary.put("grossPurchase", rs.getObject("GrossPurchase", Double.class) != null ? rs.getDouble("GrossPurchase") : 0.0);
            summary.put("netPurchase", rs.getObject("NetPurchase", Double.class) != null ? rs.getDouble("NetPurchase") : 0.0);
            summary.put("itemDiscountPur", rs.getObject("ItemDiscount", Double.class) != null ? rs.getDouble("ItemDiscount") : 0.0);
            return summary;
        });
    }

    /**
     * Get payment summary information
     */
    private Map<String, Double> getPaymentSummary(String companyId, String locaCode, String dateFrom, String dateTo) {
        String locationFilter = buildLocationFilter(locaCode, "tbl_PurSummery");
        String dateFilter = "AND tbl_PurSummery.CreateDate >= ? AND tbl_PurSummery.CreateDate <= ?";

        // FIXED: Correct parameter order
        List<Object> params = new ArrayList<>();

        // Add date parameters first
        params.add(dateFrom);
        params.add(dateTo);

        // Add company ID
        params.add(companyId);

        // Add location parameter if needed
        if (!"All".equals(locaCode) && !locationFilter.isEmpty()) {
            params.add(locaCode);
        }

        String summarySql = "SELECT " +
                "SUM(tbl_PurSummery.DiscountForTot) AS CashDiscountPur, " +
                "SUM(tbl_PurSummery.OtherPaid) AS AdvancePaymentPur, " +
                "SUM(tbl_PurSummery.CHQPaid) AS CHQPaymentPur, " +
                "SUM(tbl_PurSummery.CardPaid) AS CardPaymentPur, " +
                "SUM(tbl_PurSummery.IDueAmount) AS CreditPaymentPur, " +
                "SUM(tbl_PurSummery.CashPaid) AS CashPaymentPur, " +
                "SUM(tbl_PurSummery.ServiceCharge1) AS TransportCharges, " +
                "SUM(tbl_PurSummery.ServiceCharge2) AS LabourCharges " +
                "FROM tbl_PurSummery " +
                "WHERE (Left(tbl_PurSummery.SerialNo, 8)!='PCHM-SUP' AND Left(tbl_PurSummery.SerialNo, 8)!='PCHN-SUP') " +
                dateFilter + " " +
                "AND tbl_PurSummery.CompID=? " + locationFilter;

        return mainJdbcTemplate.queryForObject(summarySql, params.toArray(), (rs, rowNum) -> {
            Map<String, Double> summary = new HashMap<>();
            summary.put("cashDiscountPur", rs.getObject("CashDiscountPur", Double.class) != null ? rs.getDouble("CashDiscountPur") : 0.0);
            summary.put("advancePaymentPur", rs.getObject("AdvancePaymentPur", Double.class) != null ? rs.getDouble("AdvancePaymentPur") : 0.0);
            summary.put("chqPaymentPur", rs.getObject("CHQPaymentPur", Double.class) != null ? rs.getDouble("CHQPaymentPur") : 0.0);
            summary.put("cardPaymentPur", rs.getObject("CardPaymentPur", Double.class) != null ? rs.getDouble("CardPaymentPur") : 0.0);
            summary.put("creditPaymentPur", rs.getObject("CreditPaymentPur", Double.class) != null ? rs.getDouble("CreditPaymentPur") : 0.0);
            summary.put("cashPaymentPur", rs.getObject("CashPaymentPur", Double.class) != null ? rs.getDouble("CashPaymentPur") : 0.0);
            summary.put("transportCharge", rs.getObject("TransportCharges", Double.class) != null ? rs.getDouble("TransportCharges") : 0.0);
            summary.put("labourCharge", rs.getObject("LabourCharges", Double.class) != null ? rs.getDouble("LabourCharges") : 0.0);
            return summary;
        });
    }

    /**
     * Build location filter condition
     */
    private String buildLocationFilter(String locaCode, String tableName) {
        if ("All".equals(locaCode)) {
            return "";
        }
        return "AND " + tableName + ".LocaCode=?";
    }

    /**
     * Build item filter condition
     */
    private String buildItemFilter(String searchItem) {
        if (searchItem == null || searchItem.isEmpty()) {
            return "";
        }

        return "AND (tbl_PurDet.ItemCode LIKE ? " +
                "OR tbl_PurDet.ItemBarcode LIKE ? " +
                "OR tbl_PurDet.ItemBarcode1 LIKE ? " +
                "OR tbl_PurDet.ItemBarcode2 LIKE ? " +
                "OR tbl_PurDet.ItemBarcode3 LIKE ? " +
                "OR tbl_PurDet.ItemBarcode4 LIKE ? " +
                "OR tbl_PurDet.ItemName LIKE ?) ";
    }

    /**
     * Build category filter condition
     */
    private String buildCategoryFilter(String searchCategory) {
        if (searchCategory == null || searchCategory.isEmpty()) {
            return "";
        }

        return "AND (tbl_PurDet.ItemCatCode LIKE ? OR tbl_PurDet.ItemCatName LIKE ?) ";
    }

    /**
     * Build supplier filter condition
     */
    private String buildSupplierFilter(String searchSupplier) {
        if (searchSupplier == null || searchSupplier.isEmpty()) {
            return "";
        }

        return "AND (tbl_PurDet.ItemSupCode LIKE ? OR tbl_PurDet.ItemSupName LIKE ?) ";
    }

    /**
     * Build purchase type filter condition
     */
    private String buildPurchaseTypeFilter(String purchaseType) {
        if ("All".equals(purchaseType)) {
            return "";
        } else if ("GRN".equals(purchaseType)) {
            return "AND tbl_PurDet.ID='PCH' ";
        } else if ("PRN".equals(purchaseType)) {
            return "AND tbl_PurDet.ID='PRN' ";
        } else if ("Damage Return".equals(purchaseType)) {
            return "AND tbl_PurDet.ID='MKR' AND tbl_PurDet.Reason='Damage' ";
        }

        return "";
    }
}