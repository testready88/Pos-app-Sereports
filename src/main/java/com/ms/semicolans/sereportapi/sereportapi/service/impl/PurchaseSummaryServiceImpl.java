package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponsePurchaseSummaryDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.PurchaseSummaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PurchaseSummaryServiceImpl implements PurchaseSummaryService {
    private final JdbcTemplate mainJdbcTemplate;
    private final CompanyUserService companyUserService;

    @Override
    public PaginatedResponsePurchaseSummaryDTO getPurchaseSummary(
            String token,
            String locaCode,
            String searchSupplier,
            String searchInvoice,
            String paymentType,
            LocalDate dateFrom,
            LocalDate dateTo,
            int page,
            int size) throws SQLException {

        System.out.println("DateFrom: " + dateFrom);
        System.out.println("DateTo: " + dateTo);

        // Get user data from token
        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();

        System.out.println("CompanyId: " + companyId);

        // Format dates with time components
        String formattedDateFrom = dateFrom.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 00:00:00";
        String formattedDateTo = dateTo.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 23:59:59";

        System.out.println("Formatted DateFrom: " + formattedDateFrom);
        System.out.println("Formatted DateTo: " + formattedDateTo);

        // Build filter conditions
        String locationFilterPurSummery = buildLocationFilter(locaCode, "tbl_PurSummery");
        String supplierFilter = buildSupplierFilter(searchSupplier);
        String invoiceFilter = buildInvoiceFilter(searchInvoice);
        String paymentTypeFilter = buildPaymentTypeFilter(paymentType);
        String dateFilterPurSummery = "AND tbl_PurSummery.CreateDate >= ? AND tbl_PurSummery.CreateDate <= ?";

        // FIXED: Build parameters in the correct order to match SQL WHERE clause
        List<Object> dataParams = new ArrayList<>();

        // Add supplier filter parameters first (if supplier search exists)
        if (searchSupplier != null && !searchSupplier.isEmpty() && !"All".equals(searchSupplier)) {
            String searchPattern = "%" + searchSupplier + "%";
            dataParams.add(searchPattern);
            dataParams.add(searchPattern);
        }

        // Add invoice filter parameters (if invoice search exists)
        if (searchInvoice != null && !searchInvoice.isEmpty() && !"All".equals(searchInvoice)) {
            String searchPattern = "%" + searchInvoice + "%";
            dataParams.add(searchPattern);
            dataParams.add(searchPattern);
        }

        // Add date parameters
        dataParams.add(formattedDateFrom);
        dataParams.add(formattedDateTo);

        // Add company ID
        dataParams.add(companyId);

        // Add location parameter if needed
        if (!"All".equals(locaCode) && !locationFilterPurSummery.isEmpty()) {
            dataParams.add(locaCode);
        }

        // Add pagination parameters
        dataParams.add(page * size);
        dataParams.add(size);

        // Build SQL dynamically based on active filters
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT tbl_PurSummery.LocaCode, tbl_PurSummery.CreateDate, tbl_PurSummery.CreateBy, ");
        sqlBuilder.append("tbl_PurSummery.SerialNo, tbl_PurSummery.InvoiceNo, tbl_PurSummery.CusName, tbl_PurSummery.GTotal, ");
        sqlBuilder.append("(tbl_PurSummery.DiscountForTot+tbl_PurSummery.ItemDiscount) AS DiscountAmount, ");
        sqlBuilder.append("tbl_PurSummery.DiscountForTot AS CashDiscount, tbl_PurSummery.ItemDiscount AS ItemDiscount, ");
        sqlBuilder.append("tbl_PurSummery.NTotal, ");
        sqlBuilder.append("(CASE WHEN tbl_PurSummery.NTotal!=0 THEN (tbl_PurSummery.GTotal-tbl_PurSummery.NTotal) ELSE 0 END) AS GPValue, ");
        sqlBuilder.append("(CASE WHEN tbl_PurSummery.NTotal!=0 THEN (tbl_PurSummery.GTotal-tbl_PurSummery.NTotal)*100/tbl_PurSummery.NTotal ELSE 0 END) AS GPPer, ");
        sqlBuilder.append("(CASE WHEN ExCharges='' THEN 0 ELSE tbl_PurSummery.ExCharges END) AS ExtraCharges, ");
        sqlBuilder.append("tbl_PurSummery.ServiceCharge1, tbl_PurSummery.ServiceCharge2, tbl_PurSummery.ServiceCharge3, ");
        sqlBuilder.append("tbl_PurSummery.CashPaid, tbl_PurSummery.IDueAmount, tbl_PurSummery.CHQPaid, tbl_PurSummery.CardPaid, ");
        sqlBuilder.append("(tbl_PurSummery.CashPaid+tbl_PurSummery.CHQPaid+tbl_PurSummery.CardPaid+tbl_PurSummery.CreditNotePaid+tbl_PurSummery.OtherPaid+tbl_PurSummery.CreditPay) AS PaidAmount, ");
        sqlBuilder.append("tbl_PurSummery.OtherPaid, tbl_PurSummery.CreditPay, tbl_PurSummery.TotalPaidAmount, tbl_PurSummery.BalanceAmount, ");
        sqlBuilder.append("tbl_PurSummery.InvoiceDescription ");
        sqlBuilder.append("FROM tbl_PurSummery ");
        sqlBuilder.append("WHERE Left(tbl_PurSummery.SerialNo, 8)!='PCHM-SUP' AND Left(tbl_PurSummery.SerialNo, 8)!='PCHN-SUP' ");

        // Add filters only if they're not empty
        if (!paymentTypeFilter.isEmpty()) {
            sqlBuilder.append(paymentTypeFilter);
        }
        if (!invoiceFilter.isEmpty()) {
            sqlBuilder.append(invoiceFilter);
        }
        if (!supplierFilter.isEmpty()) {
            sqlBuilder.append(supplierFilter);
        }

        sqlBuilder.append("AND tbl_PurSummery.CreateDate >= ? AND tbl_PurSummery.CreateDate <= ? ");
        sqlBuilder.append("AND tbl_PurSummery.CompID=? ");

        if (!locationFilterPurSummery.isEmpty()) {
            sqlBuilder.append(locationFilterPurSummery).append(" ");
        }

        sqlBuilder.append("ORDER BY tbl_PurSummery.CreateDate DESC ");
        sqlBuilder.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        String dataSql = sqlBuilder.toString();

        System.out.println("Data SQL: " + dataSql);
        System.out.println("Data Params: " + dataParams);
        System.out.println("Search filters - Supplier: '" + searchSupplier + "', Invoice: '" + searchInvoice + "'");
        System.out.println("Payment Type Filter: '" + paymentTypeFilter + "'");
        System.out.println("Supplier Filter SQL: '" + supplierFilter + "'");
        System.out.println("Invoice Filter SQL: '" + invoiceFilter + "'");

        // Execute query and map results
        List<Object> purchaseSummaries = mainJdbcTemplate.query(dataSql, dataParams.toArray(), (rs, rowNum) -> {
            Map<String, Object> summary = new HashMap<>();
            summary.put("locaCode", rs.getString("LocaCode"));
            summary.put("createDate", rs.getDate("CreateDate"));
            summary.put("createBy", rs.getString("CreateBy"));
            summary.put("serialNo", rs.getString("SerialNo"));
            summary.put("invoiceNo", rs.getString("InvoiceNo"));
            summary.put("cusName", rs.getString("CusName"));
            summary.put("gTotal", rs.getDouble("GTotal"));
            summary.put("discountAmount", rs.getDouble("DiscountAmount"));
            summary.put("cashDiscount", rs.getDouble("CashDiscount"));
            summary.put("itemDiscount", rs.getDouble("ItemDiscount"));
            summary.put("nTotal", rs.getDouble("NTotal"));
            summary.put("gpValue", rs.getDouble("GPValue"));
            summary.put("gpPer", rs.getDouble("GPPer"));
            summary.put("extraCharges", rs.getDouble("ExtraCharges"));
            summary.put("serviceCharge1", rs.getDouble("ServiceCharge1"));
            summary.put("serviceCharge2", rs.getDouble("ServiceCharge2"));
            summary.put("serviceCharge3", rs.getDouble("ServiceCharge3"));
            summary.put("cashPaid", rs.getDouble("CashPaid"));
            summary.put("iDueAmount", rs.getDouble("IDueAmount"));
            summary.put("chqPaid", rs.getDouble("CHQPaid"));
            summary.put("cardPaid", rs.getDouble("CardPaid"));
            summary.put("paidAmount", rs.getDouble("PaidAmount"));
            summary.put("otherPaid", rs.getDouble("OtherPaid"));
            summary.put("creditPay", rs.getDouble("CreditPay"));
            summary.put("totalPaidAmount", rs.getDouble("TotalPaidAmount"));
            summary.put("balanceAmount", rs.getDouble("BalanceAmount"));
            summary.put("invoiceDescription", rs.getString("InvoiceDescription"));
            return summary;
        });

        // FIXED: Count query with correct parameter order (no pagination params)
        List<Object> countParams = new ArrayList<>();

        // Add supplier filter parameters first (if supplier search exists)
        if (searchSupplier != null && !searchSupplier.isEmpty() && !"All".equals(searchSupplier)) {
            String searchPattern = "%" + searchSupplier + "%";
            countParams.add(searchPattern);
            countParams.add(searchPattern);
        }

        // Add invoice filter parameters (if invoice search exists)
        if (searchInvoice != null && !searchInvoice.isEmpty() && !"All".equals(searchInvoice)) {
            String searchPattern = "%" + searchInvoice + "%";
            countParams.add(searchPattern);
            countParams.add(searchPattern);
        }

        // Add date parameters
        countParams.add(formattedDateFrom);
        countParams.add(formattedDateTo);

        // Add company ID
        countParams.add(companyId);

        // Add location parameter if needed
        if (!"All".equals(locaCode) && !locationFilterPurSummery.isEmpty()) {
            countParams.add(locaCode);
        }

        // Build count query with same filters
        StringBuilder countSqlBuilder = new StringBuilder();
        countSqlBuilder.append("SELECT COUNT(*) FROM tbl_PurSummery ");
        countSqlBuilder.append("WHERE Left(tbl_PurSummery.SerialNo, 8)!='PCHM-SUP' AND Left(tbl_PurSummery.SerialNo, 8)!='PCHN-SUP' ");

        // Add same filters as main query
        if (!paymentTypeFilter.isEmpty()) {
            countSqlBuilder.append(paymentTypeFilter);
        }
        if (!invoiceFilter.isEmpty()) {
            countSqlBuilder.append(invoiceFilter);
        }
        if (!supplierFilter.isEmpty()) {
            countSqlBuilder.append(supplierFilter);
        }

        countSqlBuilder.append("AND tbl_PurSummery.CreateDate >= ? AND tbl_PurSummery.CreateDate <= ? ");
        countSqlBuilder.append("AND tbl_PurSummery.CompID=? ");

        if (!locationFilterPurSummery.isEmpty()) {
            countSqlBuilder.append(locationFilterPurSummery);
        }

        String countSql = countSqlBuilder.toString();

        System.out.println("Count SQL: " + countSql);
        System.out.println("Count Params: " + countParams);

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
        return PaginatedResponsePurchaseSummaryDTO.builder()
                .count(totalCount)
                .data(purchaseSummaries)
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
     * Build supplier filter condition
     */
    private String buildSupplierFilter(String searchSupplier) {
        if (searchSupplier == null || searchSupplier.isEmpty() || "All".equals(searchSupplier)) {
            return "";
        }

        return "AND (tbl_PurSummery.CusCode LIKE ? OR tbl_PurSummery.CusName LIKE ?) ";
    }

    /**
     * Build invoice filter condition
     */
    private String buildInvoiceFilter(String searchInvoice) {
        if (searchInvoice == null || searchInvoice.isEmpty() || "All".equals(searchInvoice)) {
            return "";
        }

        return "AND (tbl_PurSummery.SerialNo LIKE ? OR tbl_PurSummery.InvoiceNo LIKE ?) ";
    }

    /**
     * Build payment type filter condition
     */
    private String buildPaymentTypeFilter(String paymentType) {
        if ("All".equals(paymentType)) {
            return "";
        } else if ("Cash".equals(paymentType)) {
            return "AND tbl_PurSummery.CashPaid > 0 ";
        } else if ("Credit".equals(paymentType)) {
            return "AND tbl_PurSummery.IDueAmount > 0 ";
        } else if ("Cheque".equals(paymentType)) {
            return "AND tbl_PurSummery.CHQPaid > 0 ";
        } else if ("Card".equals(paymentType)) {
            return "AND tbl_PurSummery.CardPaid > 0 ";
        } else if ("Advance".equals(paymentType)) {
            return "AND tbl_PurSummery.OtherPaid > 0 ";
        } else if ("Voucher".equals(paymentType)) {
            return "AND tbl_PurSummery.VoucherPaid > 0 ";
        } else if ("Bank Transfer".equals(paymentType)) {
            return "AND tbl_PurSummery.CreditNotePaid > 0 ";
        }

        return "";
    }
}