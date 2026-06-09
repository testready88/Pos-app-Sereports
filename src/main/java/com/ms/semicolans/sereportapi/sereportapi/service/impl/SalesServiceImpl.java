package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseSalesDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.SalesService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class SalesServiceImpl implements SalesService {
    private final JdbcTemplate mainJdbcTemplate;
    private final CompanyUserService companyUserService;

    @Override
    public PaginatedResponseSalesDTO getSalesDetails(
            String token,
            String locaCode,
            String searchItem,
            String searchCategory,
            String searchSupplier,
            String salesType,
            LocalDate dateFrom,
            LocalDate dateTo,
            int page,
            int size) throws SQLException {

        System.out.println("Original DateFrom: " + dateFrom);
        System.out.println("Original DateTo: " + dateTo);

        // Get user data from token
        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();

        // Format dates as strings with time components for SQL Server
        String formattedDateFrom = dateFrom.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 00:00:00";
        String formattedDateTo = dateTo.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 23:59:59";

        System.out.println("Formatted DateFrom: " + formattedDateFrom);
        System.out.println("Formatted DateTo: " + formattedDateTo);
        System.out.println("CompanyId: " + companyId);

        // Build filter conditions
        String locationFilterInvDet = buildLocationFilter(locaCode, "tbl_InvDet");
        String locationFilterInvSummery = buildLocationFilter(locaCode, "tbl_InvSummery");
        String itemFilter = buildItemFilter(searchItem);
        String categoryFilter = buildCategoryFilter(searchCategory);
        String supplierFilter = buildSupplierFilter(searchSupplier);
        String salesTypeFilter = buildSalesTypeFilter(salesType);

        // Use simple date comparison without CONVERT functions
        String dateFilterInvDet = "AND tbl_Invdet.CreateDate >= ? AND tbl_Invdet.CreateDate <= ?";
        String dateFilterInvSummery = "AND tbl_InvSummery.CreateDate >= ? AND tbl_InvSummery.CreateDate <= ?";

        // Build the complete WHERE clause to understand parameter order
        StringBuilder whereClause = new StringBuilder();
        whereClause.append("WHERE Left(tbl_InvDet.SerialNo, 8)!='INVM-CUS' AND Left(tbl_InvDet.SerialNo, 8)!='INVN-CUS' ");

        List<Object> whereParams = new ArrayList<>();

        // Add filter conditions and their parameters in order
        if (!salesTypeFilter.isEmpty()) {
            whereClause.append(salesTypeFilter).append(" ");
        }

        if (!itemFilter.isEmpty()) {
            whereClause.append(itemFilter).append(" ");
        }

        if (!categoryFilter.isEmpty()) {
            whereClause.append(categoryFilter).append(" ");
        }

        if (!supplierFilter.isEmpty()) {
            whereClause.append(supplierFilter).append(" ");
        }

        // Add date filter
        whereClause.append(dateFilterInvDet).append(" ");
        whereParams.add(formattedDateFrom);
        whereParams.add(formattedDateTo);

        // Add company filter
        whereClause.append("AND tbl_InvDet.CompID=? AND tbl_InvSummery.CompID=? ");
        whereParams.add(companyId);
        whereParams.add(companyId);

        // Add location filter if needed
        if (!"All".equals(locaCode) && !locationFilterInvDet.isEmpty()) {
            whereClause.append(locationFilterInvDet).append(" ");
            whereParams.add(locaCode);
        }

        // Parameters for data query with pagination
        List<Object> dataParams = new ArrayList<>(whereParams);
        dataParams.add(page * size);
        dataParams.add(size);

        // Main query with pagination
        String dataSql = "SELECT tbl_InvDet.LocaCode, tbl_InvDet.CreateDate, tbl_InvDet.ItemBarcode, tbl_InvDet.ItemName, " +
                "tbl_InvDet.ItemUPrice, tbl_InvDet.ItemSPrice, tbl_InvDet.Qty, tbl_InvDet.ItemDPrice, " +
                "(tbl_InvDet.Qty*tbl_InvDet.ItemDPrice) AS TotalAmount, " +
                "tbl_InvDet.Qty*(tbl_InvDet.ItemDPrice-ItemUPrice) AS GPAmount, " +
                "(CASE WHEN tbl_InvSummery.InvoiceDescription Is NUll OR tbl_InvSummery.InvoiceDescription='' OR tbl_InvSummery.InvoiceDescription='NULL' " +
                "THEN tbl_InvSummery.CusName ELSE tbl_InvSummery.CusName+'-'+tbl_InvSummery.InvoiceDescription END) AS Remark " +
                "FROM tbl_InvDet INNER JOIN tbl_InvSummery ON tbl_InvSummery.SerialNo=tbl_InvDet.SerialNo " +
                whereClause.toString() +
                "ORDER BY tbl_InvDet.CreateDate DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        System.out.println("Data SQL: " + dataSql);
        System.out.println("Data Params: " + dataParams);

        // Execute query and map results
        List<Object> sales = mainJdbcTemplate.query(dataSql, dataParams.toArray(), (rs, rowNum) -> {
            Map<String, Object> sale = new HashMap<>();
            sale.put("locaCode", rs.getString("LocaCode"));
            sale.put("createDate", rs.getDate("CreateDate"));
            sale.put("itemBarcode", rs.getString("ItemBarcode"));
            sale.put("itemName", rs.getString("ItemName"));
            sale.put("itemUPrice", rs.getDouble("ItemUPrice"));
            sale.put("itemSPrice", rs.getDouble("ItemSPrice"));
            sale.put("qty", rs.getDouble("Qty"));
            sale.put("itemDPrice", rs.getDouble("ItemDPrice"));
            sale.put("totalAmount", rs.getDouble("TotalAmount"));
            sale.put("gpAmount", rs.getDouble("GPAmount"));
            sale.put("remark", rs.getString("Remark"));
            return sale;
        });

        System.out.println("Sales count: " + sales.size());

        // Count query with same WHERE clause
        String countSql = "SELECT COUNT(*) FROM tbl_InvDet INNER JOIN tbl_InvSummery ON tbl_InvSummery.SerialNo=tbl_InvDet.SerialNo " +
                whereClause.toString();

        System.out.println("Count SQL: " + countSql);
        System.out.println("Count Params: " + whereParams);

        Long totalCount = mainJdbcTemplate.queryForObject(countSql, whereParams.toArray(), Long.class);

        // Get sales summary
        Map<String, Double> salesSummary = getSalesSummary(companyId, locaCode, salesTypeFilter, itemFilter,
                categoryFilter, supplierFilter, formattedDateFrom, formattedDateTo);

        // Get payment summary
        Map<String, Double> paymentSummary = getPaymentSummary(companyId, locaCode, formattedDateFrom, formattedDateTo);

        // Get profit summary
        Map<String, Double> profitSummary = getProfitSummary(companyId, locaCode, salesTypeFilter, itemFilter,
                categoryFilter, supplierFilter, formattedDateFrom, formattedDateTo);

        // Calculate net profit
        Double netSales = salesSummary.get("netSales") + salesSummary.get("exCharges") - paymentSummary.get("cashDiscount") - paymentSummary.get("pointsRedeem");
        Double profitAfterDiscount = netSales - salesSummary.get("costSales");
        Double profitBeforeDiscount = salesSummary.get("grossSales") + salesSummary.get("exCharges") - paymentSummary.get("cashDiscount") - paymentSummary.get("pointsRedeem") - salesSummary.get("costSales");

        // Build response
        return PaginatedResponseSalesDTO.builder()
                .count(totalCount)
                .data(sales)
                .totalQtySold(salesSummary.get("totalQtySold"))
                .grossSales(salesSummary.get("grossSales"))
                .itemDiscount(salesSummary.get("itemDiscount"))
                .netSales(netSales)
                .profitBeforeDiscount(profitBeforeDiscount)
                .profitAfterDiscount(profitAfterDiscount)
                .costSales(salesSummary.get("costSales"))
                .exCharges(salesSummary.get("exCharges"))
                .advancePayment(paymentSummary.get("advancePayment"))
                .chqPayment(paymentSummary.get("chqPayment"))
                .cardPayment(paymentSummary.get("cardPayment"))
                .creditPayment(paymentSummary.get("creditPayment"))
                .cashPayment(paymentSummary.get("cashPayment"))
                .creditSettlement(paymentSummary.get("creditSettlement"))
                .cashDiscount(paymentSummary.get("cashDiscount"))
                .pointsRedeem(paymentSummary.get("pointsRedeem"))
                .voucherPaid(paymentSummary.get("voucherPaid"))
                .cashSales(profitSummary.get("cashSales"))
                .profitByCashSales(profitSummary.get("profitByCashSales"))
                .creditSales(profitSummary.get("creditSales"))
                .profitByCreditSales(profitSummary.get("profitByCreditSales"))
                .build();
    }

    /**
     * Get sales summary information
     */
    private Map<String, Double> getSalesSummary(String companyId, String locaCode, String salesTypeFilter,
                                                String itemFilter, String categoryFilter, String supplierFilter,
                                                String dateFrom, String dateTo) {
        String locationFilterInvDet = buildLocationFilter(locaCode, "tbl_InvDet");
        String locationFilterInvSummery = buildLocationFilter(locaCode, "tbl_InvSummery");
        String dateFilterInvDet = "AND tbl_Invdet.CreateDate >= ? AND tbl_Invdet.CreateDate <= ?";

        List<Object> params = new ArrayList<>();

        // Add date parameters first
        params.add(dateFrom);
        params.add(dateTo);

        // Add company IDs
        params.add(companyId);
        params.add(companyId);

        // Add location parameter if needed
        if (!"All".equals(locaCode) && !locationFilterInvSummery.isEmpty()) {
            params.add(locaCode);
        }

        String summarySql = "SELECT " +
                "SUM(tbl_InvDet.Qty) AS TotalQtySold, " +
                "SUM(tbl_InvDet.Qty*tbl_InvDet.ItemSPrice) AS GrossSales, " +
                "SUM(tbl_InvDet.Qty*(tbl_InvDet.ItemSPrice-tbl_InvDet.ItemDPrice)) AS ItemDiscount, " +
                "SUM(tbl_InvDet.Qty*tbl_InvDet.ItemDPrice) AS NetSales, " +
                "SUM(tbl_InvDet.Qty*((tbl_InvDet.ItemSPrice+tbl_InvDet.ExCharges)-tbl_InvDet.ItemUPrice)) AS ProfitBeforeDiscount, " +
                "SUM(tbl_InvDet.Qty*((tbl_InvDet.ItemDPrice+tbl_InvDet.ExCharges)-tbl_InvDet.ItemUPrice)) AS ProfitAfterDiscount, " +
                "SUM(tbl_InvDet.Qty*tbl_InvDet.ExCharges) AS ExCharges, " +
                "SUM(tbl_InvDet.Qty*tbl_InvDet.ItemUPrice) AS CostOfSales " +
                "FROM tbl_InvDet INNER JOIN tbl_InvSummery ON tbl_InvSummery.SerialNo=tbl_InvDet.SerialNo " +
                "WHERE Left(tbl_InvDet.SerialNo, 8)!='INVM-CUS' AND Left(tbl_InvDet.SerialNo, 8)!='INVN-CUS' " +
                salesTypeFilter + " " + itemFilter + " " + categoryFilter + " " + supplierFilter + " " + dateFilterInvDet + " " +
                "AND tbl_InvDet.CompID=? AND tbl_InvSummery.CompID=? " + locationFilterInvSummery;

        return mainJdbcTemplate.queryForObject(summarySql, params.toArray(), (rs, rowNum) -> {
            Map<String, Double> summary = new HashMap<>();
            summary.put("totalQtySold", rs.getObject("TotalQtySold", Double.class) != null ? rs.getDouble("TotalQtySold") : 0.0);
            summary.put("grossSales", rs.getObject("GrossSales", Double.class) != null ? rs.getDouble("GrossSales") : 0.0);
            summary.put("itemDiscount", rs.getObject("ItemDiscount", Double.class) != null ? rs.getDouble("ItemDiscount") : 0.0);
            summary.put("netSales", rs.getObject("NetSales", Double.class) != null ? rs.getDouble("NetSales") : 0.0);
            summary.put("profitBeforeDiscount", rs.getObject("ProfitBeforeDiscount", Double.class) != null ? rs.getDouble("ProfitBeforeDiscount") : 0.0);
            summary.put("profitAfterDiscount", rs.getObject("ProfitAfterDiscount", Double.class) != null ? rs.getDouble("ProfitAfterDiscount") : 0.0);
            summary.put("exCharges", rs.getObject("ExCharges", Double.class) != null ? rs.getDouble("ExCharges") : 0.0);
            summary.put("costSales", rs.getObject("CostOfSales", Double.class) != null ? rs.getDouble("CostOfSales") : 0.0);
            return summary;
        });
    }

    /**
     * Get payment summary information
     */
    private Map<String, Double> getPaymentSummary(String companyId, String locaCode, String dateFrom, String dateTo) {
        String locationFilterInvSummery = buildLocationFilter(locaCode, "tbl_InvSummery");
        String dateFilterInvSummery = "AND tbl_InvSummery.CreateDate >= ? AND tbl_InvSummery.CreateDate <= ?";

        List<Object> params = new ArrayList<>();

        // Add date parameters first
        params.add(dateFrom);
        params.add(dateTo);

        // Add company ID
        params.add(companyId);

        // Add location parameter if needed
        if (!"All".equals(locaCode) && !locationFilterInvSummery.isEmpty()) {
            params.add(locaCode);
        }

        String summarySql = "SELECT " +
                "SUM(tbl_InvSummery.OtherPaid) AS AdvancePayment, " +
                "SUM(tbl_InvSummery.CHQPaid) AS CHQPayment, " +
                "SUM(tbl_InvSummery.CardPaid) AS CardPayment, " +
                "SUM(tbl_InvSummery.IDueAmount) AS CreditPayment, " +
                "SUM(tbl_InvSummery.CashPaid) AS CashPayment, " +
                "SUM(tbl_InvSummery.CreditPay) AS CreditSettlement, " +
                "SUM(tbl_InvSummery.DiscountForTot) AS CashDiscount, " +
                "SUM(tbl_InvSummery.PointsRedeem) AS PointsRedeem, " +
                "SUM(tbl_InvSummery.VoucherPaid) AS VoucherPaid " +
                "FROM tbl_InvSummery " +
                "WHERE Left(tbl_InvSummery.SerialNo, 8)!='INVM-CUS' AND Left(tbl_InvSummery.SerialNo, 8)!='INVN-CUS' " +
                dateFilterInvSummery + " " +
                "AND tbl_InvSummery.CompID=? " + locationFilterInvSummery;

        return mainJdbcTemplate.queryForObject(summarySql, params.toArray(), (rs, rowNum) -> {
            Map<String, Double> summary = new HashMap<>();
            summary.put("advancePayment", rs.getObject("AdvancePayment", Double.class) != null ? rs.getDouble("AdvancePayment") : 0.0);
            summary.put("chqPayment", rs.getObject("CHQPayment", Double.class) != null ? rs.getDouble("CHQPayment") : 0.0);
            summary.put("cardPayment", rs.getObject("CardPayment", Double.class) != null ? rs.getDouble("CardPayment") : 0.0);
            summary.put("creditPayment", rs.getObject("CreditPayment", Double.class) != null ? rs.getDouble("CreditPayment") : 0.0);
            summary.put("cashPayment", rs.getObject("CashPayment", Double.class) != null ? rs.getDouble("CashPayment") : 0.0);
            summary.put("creditSettlement", rs.getObject("CreditSettlement", Double.class) != null ? rs.getDouble("CreditSettlement") : 0.0);
            summary.put("cashDiscount", rs.getObject("CashDiscount", Double.class) != null ? rs.getDouble("CashDiscount") : 0.0);
            summary.put("pointsRedeem", rs.getObject("PointsRedeem", Double.class) != null ? rs.getDouble("PointsRedeem") : 0.0);
            summary.put("voucherPaid", rs.getObject("VoucherPaid", Double.class) != null ? rs.getDouble("VoucherPaid") : 0.0);
            return summary;
        });
    }

    /**
     * Get profit summary by payment method
     */
    private Map<String, Double> getProfitSummary(String companyId, String locaCode, String salesTypeFilter,
                                                 String itemFilter, String categoryFilter, String supplierFilter,
                                                 String dateFrom, String dateTo) {
        Map<String, Double> results = new HashMap<>();

        // Cash sales profit
        results.putAll(getProfitByPaymentType(companyId, locaCode, salesTypeFilter, itemFilter,
                categoryFilter, supplierFilter, dateFrom, dateTo, true));

        // Credit sales profit
        results.putAll(getProfitByPaymentType(companyId, locaCode, salesTypeFilter, itemFilter,
                categoryFilter, supplierFilter, dateFrom, dateTo, false));

        return results;
    }

    /**
     * Get profit summary by payment type (cash or credit)
     */
    private Map<String, Double> getProfitByPaymentType(String companyId, String locaCode, String salesTypeFilter,
                                                       String itemFilter, String categoryFilter, String supplierFilter,
                                                       String dateFrom, String dateTo, boolean isCash) {

        String locationFilterInvDet = buildLocationFilter(locaCode, "tbl_InvDet");
        String locationFilterInvSummery = buildLocationFilter(locaCode, "tbl_InvSummery");
        String dateFilterInvDet = "AND tbl_Invdet.CreateDate >= ? AND tbl_Invdet.CreateDate <= ?";

        String paymentCondition = isCash ?
                "AND tbl_InvSummery.OtherPaid=0 AND tbl_InvSummery.CHQPaid=0 AND tbl_InvSummery.IDueAmount=0 " :
                "AND (tbl_InvSummery.OtherPaid!=0 OR tbl_InvSummery.CHQPaid!=0 OR tbl_InvSummery.IDueAmount!=0) ";

        List<Object> params = new ArrayList<>();

        // Add date parameters first
        params.add(dateFrom);
        params.add(dateTo);

        // Add company IDs
        params.add(companyId);
        params.add(companyId);

        // Add location parameter if needed
        if (!"All".equals(locaCode) && !locationFilterInvSummery.isEmpty()) {
            params.add(locaCode);
        }

        String summarySql = "SELECT " +
                "SUM(tbl_InvDet.Qty*((tbl_InvDet.ItemDPrice+tbl_InvDet.ExCharges) - tbl_InvDet.ItemAvgCost)) AS ProfitByPaymentType, " +
                "SUM(tbl_InvDet.Qty*(tbl_InvDet.ItemDPrice+tbl_InvDet.ExCharges)) AS SalesByPaymentType " +
                "FROM tbl_InvDet INNER JOIN tbl_InvSummery ON tbl_InvSummery.SerialNo=tbl_InvDet.SerialNo " +
                "WHERE (Left(tbl_InvDet.SerialNo, 8)!='INVM-CUS' AND Left(tbl_InvDet.SerialNo, 8)!='INVN-CUS') " +
                paymentCondition +
                salesTypeFilter + " " + itemFilter + " " + categoryFilter + " " + supplierFilter + " " + dateFilterInvDet + " " +
                "AND tbl_InvDet.CompID=? AND tbl_InvSummery.CompID=? " + locationFilterInvSummery;

        Map<String, Double> result = mainJdbcTemplate.queryForObject(summarySql, params.toArray(), (rs, rowNum) -> {
            Map<String, Double> summary = new HashMap<>();
            Double sales = rs.getObject("SalesByPaymentType", Double.class) != null ? rs.getDouble("SalesByPaymentType") : 0.0;
            Double profit = rs.getObject("ProfitByPaymentType", Double.class) != null ? rs.getDouble("ProfitByPaymentType") : 0.0;

            if (isCash) {
                summary.put("cashSales", sales);
                summary.put("profitByCashSales", profit);
            } else {
                summary.put("creditSales", sales);
                summary.put("profitByCreditSales", profit);
            }

            return summary;
        });

        return result;
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

        return "AND (tbl_InvDet.ItemCode LIKE '%" + searchItem + "%' " +
                "OR tbl_InvDet.ItemBarcode LIKE '%" + searchItem + "%' " +
                "OR tbl_InvDet.ItemBarcode1 LIKE '%" + searchItem + "%' " +
                "OR tbl_InvDet.ItemBarcode2 LIKE '%" + searchItem + "%' " +
                "OR tbl_InvDet.ItemBarcode3 LIKE '%" + searchItem + "%' " +
                "OR tbl_InvDet.ItemBarcode4 LIKE '%" + searchItem + "%' " +
                "OR tbl_InvDet.ItemName LIKE '%" + searchItem + "%') ";
    }

    /**
     * Build category filter condition
     */
    private String buildCategoryFilter(String searchCategory) {
        if (searchCategory == null || searchCategory.isEmpty()) {
            return "";
        }

        return "AND (tbl_InvDet.ItemCatCode LIKE '%" + searchCategory + "%' " +
                "OR tbl_InvDet.ItemCatName LIKE '%" + searchCategory + "%') ";
    }

    /**
     * Build supplier filter condition
     */
    private String buildSupplierFilter(String searchSupplier) {
        if (searchSupplier == null || searchSupplier.isEmpty()) {
            return "";
        }

        return "AND (tbl_InvDet.ItemSupCode LIKE '%" + searchSupplier + "%' " +
                "OR tbl_InvDet.ItemSupName LIKE '%" + searchSupplier + "%') ";
    }

    /**
     * Build sales type filter condition
     */
    private String buildSalesTypeFilter(String salesType) {
        if ("All".equals(salesType)) {
            return "";
        } else if ("Retail".equals(salesType)) {
            return "AND tbl_InvDet.ID='INV' AND tbl_InvDet.InvType='RETAIL' ";
        } else if ("Discounted".equals(salesType)) {
            return "AND tbl_InvDet.ID='INV' AND tbl_InvDet.InvType='DISCOUNTED' ";
        } else if ("Wholesale".equals(salesType)) {
            return "AND tbl_InvDet.ID='INV' AND tbl_InvDet.InvType='WHOLE SALE' ";
        } else if ("Free".equals(salesType)) {
            return "AND tbl_InvDet.ID='INV' AND tbl_InvDet.InvType='FREE' ";
        } else if ("Invoice Return".equals(salesType)) {
            return "AND tbl_InvDet.ID='MKR' ";
        } else if ("Damage Return".equals(salesType)) {
            return "AND tbl_InvDet.ID='MKR' AND tbl_InvDet.Reason='Damage' ";
        } else if ("Under Cost".equals(salesType)) {
            return "AND (tbl_InvDet.ItemDPrice <= tbl_InvDet.ItemUPrice) ";
        }

        return "";
    }
}