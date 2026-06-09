package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseSalesSummaryDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.SalesSummaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SalesSummaryServiceImpl implements SalesSummaryService {

    private final JdbcTemplate mainJdbcTemplate;
    private final CompanyUserService companyUserService;

    @Override
    public PaginatedResponseSalesSummaryDTO getSalesSummary(
            String token,
            String locaCode,
            String searchCustomer,
            String paymentType,
            String dateFrom,
            String dateTo,
            int page,
            int size) throws SQLException {

        // Get user data from token
        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();

        System.out.println("DateFrom: " + dateFrom);
        System.out.println("DateTo: " + dateTo);
        System.out.println("CompanyId: " + companyId);

        // Build filter conditions
        String locationFilterInvDet = buildLocationFilter(locaCode, "tbl_InvDet");
        String locationFilterInvSummery = buildLocationFilter(locaCode, "tbl_InvSummery");
        String customerFilter = buildCustomerFilter(searchCustomer);
        String paymentTypeFilter = buildPaymentTypeFilter(paymentType);

        // Use consistent date filter format
        String dateFilterInvDet = "AND CONVERT(date, tbl_Invdet.CreateDate) BETWEEN CONVERT(date, ?) AND CONVERT(date, ?)";
        String dateFilterInvSummery = "AND CONVERT(date, tbl_InvSummery.CreateDate) BETWEEN CONVERT(date, ?) AND CONVERT(date, ?)";

        // FIXED: Parameters for data query with correct order to match SQL WHERE clause
        List<Object> dataParams = new ArrayList<>();

        // Add date parameters first (for date filter)
        dataParams.add(dateFrom);
        dataParams.add(dateTo);

        // Add company ID (for CompID=?)
        dataParams.add(companyId);

        // Add location filter parameter if required
        if (!"All".equals(locaCode) && !locationFilterInvSummery.isEmpty()) {
            dataParams.add(locaCode);
        }

        // Add pagination parameters
        dataParams.add(page * size);
        dataParams.add(size);

        // Main query with pagination
        String dataSql = "SELECT tbl_InvSummery.LocaCode, tbl_InvSummery.CreateDate, tbl_InvSummery.SerialNo, " +
                "tbl_InvSummery.GTotal, tbl_InvSummery.ItemDiscount, tbl_InvSummery.DiscountForTot, tbl_InvSummery.NTotal, " +
                "(tbl_InvSummery.NTotal-tbl_InvSummery.CTotal) AS GP, tbl_InvSummery.CashPaid, tbl_InvSummery.IDueAmount, " +
                "(tbl_InvSummery.CashPaid+tbl_InvSummery.CHQPaid+tbl_InvSummery.CardPaid+tbl_InvSummery.CreditNotePaid+" +
                "tbl_InvSummery.VoucherPaid+tbl_InvSummery.OtherPaid) AS PaidAmount, " +
                "tbl_InvSummery.CashPaid As CashPayment, tbl_InvSummery.ChqPaid AS ChqPayment, tbl_InvSummery.CardPaid AS CardPayment, " +
                "tbl_InvSummery.CreditNotePaid AS BankPayment, tbl_InvSummery.VoucherPaid AS VoucherPayment, tbl_InvSummery.CreditPay, " +
                "tbl_InvSummery.PointsRedeem, tbl_InvSummery.ExCharges, tbl_InvSummery.TQty, tbl_InvSummery.TPcs, tbl_InvSummery.DeliveryCharge, " +
                "(CASE WHEN tbl_InvSummery.InvoiceDescription Is NUll OR tbl_InvSummery.InvoiceDescription='' OR " +
                "tbl_InvSummery.InvoiceDescription='NULL' THEN tbl_InvSummery.CusName " +
                "ELSE tbl_InvSummery.CusName+'-'+tbl_InvSummery.InvoiceDescription END) AS Remark " +
                "FROM tbl_InvSummery " +
                "WHERE Left(tbl_InvSummery.SerialNo, 8)!='INVM-CUS' AND Left(tbl_InvSummery.SerialNo, 8)!='INVN-CUS' " +
                paymentTypeFilter + " " + customerFilter + " " + dateFilterInvSummery + " " +
                "AND tbl_InvSummery.CompID=? " + locationFilterInvSummery + " " +
                "ORDER BY tbl_InvSummery.RowNo ASC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        System.out.println("Data SQL: " + dataSql);
        System.out.println("Data Params: " + dataParams);

        // Execute query and map results
        List<Object> salesSummaries = mainJdbcTemplate.query(dataSql, dataParams.toArray(), (rs, rowNum) -> {
            Map<String, Object> summary = new HashMap<>();
            summary.put("locaCode", rs.getString("LocaCode"));
            summary.put("createDate", rs.getDate("CreateDate"));
            summary.put("serialNo", rs.getString("SerialNo"));
            summary.put("gTotal", rs.getDouble("GTotal"));
            summary.put("itemDiscount", rs.getDouble("ItemDiscount"));
            summary.put("discountForTot", rs.getDouble("DiscountForTot"));
            summary.put("nTotal", rs.getDouble("NTotal"));
            summary.put("gp", rs.getDouble("GP"));
            summary.put("cashPaid", rs.getDouble("CashPaid"));
            summary.put("iDueAmount", rs.getDouble("IDueAmount"));
            summary.put("paidAmount", rs.getDouble("PaidAmount"));
            summary.put("cashPayment", rs.getDouble("CashPayment"));
            summary.put("chqPayment", rs.getDouble("ChqPayment"));
            summary.put("cardPayment", rs.getDouble("CardPayment"));
            summary.put("bankPayment", rs.getDouble("BankPayment"));
            summary.put("voucherPayment", rs.getDouble("VoucherPayment"));
            summary.put("creditPay", rs.getDouble("CreditPay"));
            summary.put("pointsRedeem", rs.getDouble("PointsRedeem"));
            summary.put("exCharges", rs.getDouble("ExCharges"));
            summary.put("tQty", rs.getDouble("TQty"));
            summary.put("tPcs", rs.getDouble("TPcs"));
            summary.put("deliveryCharge", rs.getDouble("DeliveryCharge"));
            summary.put("remark", rs.getString("Remark"));
            return summary;
        });

        System.out.println("Sales summaries count: " + salesSummaries.size());

        // FIXED: Count query with correct parameter order
        String countSql = "SELECT COUNT(*) FROM tbl_InvSummery " +
                "WHERE Left(tbl_InvSummery.SerialNo, 8)!='INVM-CUS' AND Left(tbl_InvSummery.SerialNo, 8)!='INVN-CUS' " +
                paymentTypeFilter + " " + customerFilter + " " + dateFilterInvSummery + " " +
                "AND tbl_InvSummery.CompID=? " + locationFilterInvSummery;

        // Parameters for count query (same order, no pagination)
        List<Object> countParams = new ArrayList<>();
        countParams.add(dateFrom);
        countParams.add(dateTo);
        countParams.add(companyId);

        if (!"All".equals(locaCode) && !locationFilterInvSummery.isEmpty()) {
            countParams.add(locaCode);
        }

        System.out.println("Count SQL: " + countSql);
        System.out.println("Count Params: " + countParams);

        Long totalCount = mainJdbcTemplate.queryForObject(countSql, countParams.toArray(), Long.class);

        // Get sales summary details
        Map<String, Double> salesSummary = getSalesSummary(companyId, locaCode, customerFilter,
                paymentTypeFilter, dateFrom, dateTo);

        // Get payment summary
        Map<String, Double> paymentSummary = getPaymentSummary(companyId, locaCode, customerFilter,
                paymentTypeFilter, dateFrom, dateTo);

        // Get profit summary
        Map<String, Double> profitSummary = getProfitSummary(companyId, locaCode, customerFilter,
                paymentTypeFilter, dateFrom, dateTo);

        // Calculate net profit
        Double netSales = salesSummary.get("netSales") + salesSummary.get("exCharges") -
                paymentSummary.get("cashDiscount") - paymentSummary.get("pointsRedeem");

        Double profitAfterDiscount = netSales - salesSummary.get("costSales");

        Double profitBeforeDiscount = salesSummary.get("grossSales") + salesSummary.get("exCharges") -
                paymentSummary.get("cashDiscount") - paymentSummary.get("pointsRedeem") -
                salesSummary.get("costSales");

        // Build response
        return PaginatedResponseSalesSummaryDTO.builder()
                .count(totalCount)
                .data(salesSummaries)
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
    private Map<String, Double> getSalesSummary(String companyId, String locaCode, String customerFilter,
                                                String paymentTypeFilter, String dateFrom, String dateTo) {
        String locationFilterInvDet = buildLocationFilter(locaCode, "tbl_InvDet");
        String locationFilterInvSummery = buildLocationFilter(locaCode, "tbl_InvSummery");
        String dateFilterInvDet = "AND CONVERT(date, tbl_Invdet.CreateDate) BETWEEN CONVERT(date, ?) AND CONVERT(date, ?)";

        // FIXED: Correct parameter order
        List<Object> params = new ArrayList<>();

        // Add date parameters first (for date filter)
        params.add(dateFrom);
        params.add(dateTo);

        // Add company IDs (for both tables)
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
                paymentTypeFilter + " " + customerFilter + " " + dateFilterInvDet + " " +
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
    private Map<String, Double> getPaymentSummary(String companyId, String locaCode, String customerFilter,
                                                  String paymentTypeFilter, String dateFrom, String dateTo) {
        String locationFilterInvSummery = buildLocationFilter(locaCode, "tbl_InvSummery");
        String dateFilterInvSummery = "AND CONVERT(date, tbl_InvSummery.CreateDate) BETWEEN CONVERT(date, ?) AND CONVERT(date, ?)";

        // FIXED: Correct parameter order
        List<Object> params = new ArrayList<>();

        // Add date parameters first (for date filter)
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
                dateFilterInvSummery + " " + paymentTypeFilter + " " + customerFilter + " " +
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
    private Map<String, Double> getProfitSummary(String companyId, String locaCode, String customerFilter,
                                                 String paymentTypeFilter, String dateFrom, String dateTo) {
        Map<String, Double> results = new HashMap<>();

        // Cash sales profit
        results.putAll(getProfitByPaymentType(companyId, locaCode, customerFilter,
                paymentTypeFilter, dateFrom, dateTo, true));

        // Credit sales profit
        results.putAll(getProfitByPaymentType(companyId, locaCode, customerFilter,
                paymentTypeFilter, dateFrom, dateTo, false));

        return results;
    }

    /**
     * Get profit summary by payment type (cash or credit)
     */
    private Map<String, Double> getProfitByPaymentType(String companyId, String locaCode, String customerFilter,
                                                       String paymentTypeFilter, String dateFrom, String dateTo,
                                                       boolean isCash) {

        String locationFilterInvDet = buildLocationFilter(locaCode, "tbl_InvDet");
        String locationFilterInvSummery = buildLocationFilter(locaCode, "tbl_InvSummery");
        String dateFilterInvDet = "AND CONVERT(date, tbl_Invdet.CreateDate) BETWEEN CONVERT(date, ?) AND CONVERT(date, ?)";

        String paymentCondition = isCash ?
                "AND tbl_InvSummery.OtherPaid=0 AND tbl_InvSummery.CHQPaid=0 AND tbl_InvSummery.IDueAmount=0 " :
                "AND (tbl_InvSummery.OtherPaid!=0 OR tbl_InvSummery.CHQPaid!=0 OR tbl_InvSummery.IDueAmount!=0) ";

        // FIXED: Correct parameter order
        List<Object> params = new ArrayList<>();

        // Add date parameters first (for date filter)
        params.add(dateFrom);
        params.add(dateTo);

        // Add company IDs (for both tables)
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
                paymentTypeFilter + " " + customerFilter + " " + dateFilterInvDet + " " +
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
     * Build customer filter condition
     */
    private String buildCustomerFilter(String searchCustomer) {
        if (searchCustomer == null || searchCustomer.isEmpty()) {
            return "";
        }

        return "AND (tbl_InvSummery.CusCode LIKE '%" + searchCustomer + "%' " +
                "OR tbl_InvSummery.CusName LIKE '%" + searchCustomer + "%' " +
                "OR tbl_InvSummery.InvoiceDescription LIKE '%" + searchCustomer + "%') ";
    }

    /**
     * Build payment type filter condition
     */
    private String buildPaymentTypeFilter(String paymentType) {
        if ("All".equals(paymentType)) {
            return "";
        } else if ("Cash".equals(paymentType)) {
            return "AND tbl_InvSummery.CashPaid > 0 ";
        } else if ("Credit".equals(paymentType)) {
            return "AND tbl_InvSummery.IDueAmount > 0 ";
        } else if ("Cheque".equals(paymentType)) {
            return "AND tbl_InvSummery.CHQPaid > 0 ";
        } else if ("Card".equals(paymentType)) {
            return "AND tbl_InvSummery.CardPaid > 0 ";
        } else if ("Advance".equals(paymentType)) {
            return "AND tbl_InvSummery.OtherPaid > 0 ";
        } else if ("Voucher".equals(paymentType)) {
            return "AND tbl_InvSummery.VoucherPaid > 0 ";
        } else if ("Bank Transfer".equals(paymentType)) {
            return "AND tbl_InvSummery.CreditNotePaid > 0 ";
        }

        return "";
    }
}