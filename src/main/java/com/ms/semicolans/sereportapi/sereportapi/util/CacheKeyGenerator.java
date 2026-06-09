package com.ms.semicolans.sereportapi.sereportapi.util;

import org.apache.commons.lang3.StringUtils;

import java.util.Objects;

/**
 * Utility class for generating cache keys for product queries
 */
public class CacheKeyGenerator {

    private static final String PRODUCT_CACHE_PREFIX = "products:";
    private static final String PRODUCT_COUNT_CACHE_PREFIX = "productCount:";

    /**
     * Generate cache key for product list query
     */
    public static String generateProductCacheKey(
            String companyId,
            String searchProduct,
            String categoryName,
            String subCategoryName,
            String supplierName,
            String stockLevel,
            String itemSaleType,
            int page,
            int size) {

        StringBuilder key = new StringBuilder(PRODUCT_CACHE_PREFIX);
        key.append(companyId).append(":");
        key.append(Objects.toString(searchProduct, "")).append(":");
        key.append(Objects.toString(categoryName, "")).append(":");
        key.append(Objects.toString(subCategoryName, "")).append(":");
        key.append(Objects.toString(supplierName, "")).append(":");
        key.append(Objects.toString(stockLevel, "")).append(":");
        key.append(Objects.toString(itemSaleType, "")).append(":");
        key.append(page).append(":");
        key.append(size);

        return key.toString();
    }

    /**
     * Generate cache key for product count query
     */
    public static String generateProductCountCacheKey(
            String companyId,
            String searchProduct,
            String categoryName,
            String subCategoryName,
            String supplierName,
            String stockLevel,
            String itemSaleType) {

        StringBuilder key = new StringBuilder(PRODUCT_COUNT_CACHE_PREFIX);
        key.append(companyId).append(":");
        key.append(Objects.toString(searchProduct, "")).append(":");
        key.append(Objects.toString(categoryName, "")).append(":");
        key.append(Objects.toString(subCategoryName, "")).append(":");
        key.append(Objects.toString(supplierName, "")).append(":");
        key.append(Objects.toString(stockLevel, "")).append(":");
        key.append(Objects.toString(itemSaleType, ""));

        return key.toString();
    }

    /**
     * Generate cache key pattern for invalidating all product caches for a company
     */
    public static String generateCompanyProductCachePattern(String companyId) {
        return PRODUCT_CACHE_PREFIX + companyId + ":*";
    }

    /**
     * Generate cache key pattern for invalidating all product count caches for a company
     */
    public static String generateCompanyProductCountCachePattern(String companyId) {
        return PRODUCT_COUNT_CACHE_PREFIX + companyId + ":*";
    }
}


