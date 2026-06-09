package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseExpensesDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.ExpensesService;
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
public class ExpensesServiceImpl implements ExpensesService {
    private final JdbcTemplate jdbcTemplate;
    private final CompanyUserService companyUserService;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");



    @Override
    public PaginatedResponseExpensesDTO getPaginatedExpensesDetails(
            String locaCode,
            String searchDescription,
            String searchVendor,
            String invType,
            LocalDate dateFrom,
            LocalDate dateTo,
            String token,
            int page,
            int size) throws SQLException {

        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);
        String companyId = userAllData.getCompanyId();

        StringBuilder dataSql = new StringBuilder();
        List<Object> dataParams = new ArrayList<>();
        buildBaseQuery(dataSql);
        applyCommonFilters(dataSql, dataParams, locaCode, searchDescription, searchVendor, invType, dateFrom, dateTo, companyId);

        dataSql.append("ORDER BY tbl_OIncsummery.CreateDate DESC ");
        dataSql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        dataParams.add(page * size);
        dataParams.add(size);

        StringBuilder countSql = new StringBuilder();
        List<Object> countParams = new ArrayList<>();
        countSql.append("SELECT COUNT(*) FROM tbl_OIncsummery ");
        applyCommonFilters(countSql, countParams, locaCode, searchDescription, searchVendor, invType, dateFrom, dateTo, companyId);

        List<Object> data = jdbcTemplate.query(
                dataSql.toString(),
                dataParams.toArray(),
                (rs, rowNum) -> {
                    Map<String, Object> row = new HashMap<>();
                    row.put("locaCode", rs.getString("LocaCode"));
                    row.put("createDate", rs.getString("CreateDate"));
                    row.put("id", rs.getString("ID"));
                    row.put("directIndirect", rs.getString("DirectIndirect"));
                    row.put("serialNo", rs.getString("SerialNo"));
                    row.put("descCode", rs.getString("DescCode"));
                    row.put("descBCode", rs.getString("DescBCode"));
                    row.put("descName", rs.getString("DescName"));
                    row.put("cusCode", rs.getString("CusCode"));
                    row.put("remark", rs.getString("Remark"));
                    row.put("cusName", rs.getString("CusName"));
                    row.put("gTotal", rs.getDouble("GTotal"));
                    row.put("cashPaid", rs.getDouble("CashPaid"));
                    row.put("chqPaid", rs.getDouble("CHQPaid"));
                    row.put("iDueamount", rs.getDouble("IDueamount"));
                    row.put("bankPaid", rs.getDouble("BankPaid"));
                    row.put("invoiceDescription", rs.getString("InvoiceDescription"));
                    return row;
                }
        );

        Long count = jdbcTemplate.queryForObject(
                countSql.toString(),
                countParams.toArray(),
                Long.class
        );

        // Get summary information
        Map<String, String> filters = buildFilters(locaCode, searchDescription, searchVendor, invType, dateFrom, dateTo);
        Double netIncome = getNetIncome(companyId, filters);
        Double netExpenses = getNetExpenses(companyId, filters);

        return PaginatedResponseExpensesDTO.builder()
                .data(data)
                .count(count != null ? count : 0)
                .netIncome(netIncome)
                .netExpenses(netExpenses)
                .build();
    }


    private String getCompanyIdFromToken(String token) throws SQLException {
        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);
        return userAllData.getCompanyId();
    }

    private void buildBaseQuery(StringBuilder sql) {
        sql.append("SELECT tbl_OIncsummery.LocaCode, tbl_OIncsummery.CreateDate, tbl_OIncsummery.ID, ");
        sql.append("tbl_OIncsummery.DirectIndirect, tbl_OIncsummery.SerialNo, tbl_OIncsummery.DescCode, ");
        sql.append("tbl_OIncsummery.DescBCode, tbl_OIncsummery.DescName, tbl_OIncsummery.CusCode, ");
        sql.append("(CASE WHEN tbl_OIncsummery.InvoiceDescription Is Null Or tbl_OIncsummery.InvoiceDescription='' THEN tbl_OIncsummery.CusName ELSE ");
        sql.append("CASE WHEN tbl_OIncsummery.CusName Is Null Or tbl_OIncsummery.CusName='Null' THEN tbl_OIncsummery.InvoiceDescription ");
        sql.append("ELSE tbl_OIncsummery.CusName + ' / ' + tbl_OIncsummery.InvoiceDescription END ");
        sql.append("END) AS Remark, tbl_OIncsummery.CusName, ");
        sql.append("tbl_OIncsummery.GTotal, tbl_OIncsummery.CashPaid, tbl_OIncsummery.CHQPaid, tbl_OIncsummery.IDueamount, ");
        sql.append("(CASE WHEN tbl_OIncsummery.BankPaid Is Null THEN 0 ELSE tbl_OIncsummery.BankPaid END) AS BankPaid, ");
        sql.append("tbl_OIncsummery.InvoiceDescription ");
        sql.append("FROM tbl_OIncsummery ");
    }

    private void applyCommonFilters(StringBuilder sql, List<Object> params,
                                    String locaCode, String searchDescription,
                                    String searchVendor, String invType,
                                    LocalDate dateFrom, LocalDate dateTo,
                                    String companyId) {
        sql.append("WHERE tbl_OIncsummery.CompID=? ");
        params.add(companyId);

        // Location filter
        if (!"All".equals(locaCode) && locaCode != null && !locaCode.isEmpty()) {
            sql.append("AND tbl_OIncsummery.LocaCode=? ");
            params.add(locaCode);
        }

        // Description filter
        if (searchDescription != null && !searchDescription.isEmpty()) {
            sql.append("AND (tbl_OIncsummery.DescCode LIKE ? ");
            sql.append("OR tbl_OIncsummery.DescName LIKE ? ");
            sql.append("OR tbl_OIncsummery.SerialNo LIKE ? ");
            sql.append("OR tbl_OIncsummery.InvoiceNo LIKE ? ");
            sql.append("OR tbl_OIncsummery.ReferenceNo LIKE ?) ");
            for (int i = 0; i < 5; i++) {
                params.add("%" + searchDescription + "%");
            }
        }

        // Vendor filter
        if (searchVendor != null && !searchVendor.isEmpty()) {
            sql.append("AND (tbl_OIncsummery.CusCode LIKE ? ");
            sql.append("OR tbl_OIncsummery.CusName LIKE ?) ");
            params.add("%" + searchVendor + "%");
            params.add("%" + searchVendor + "%");
        }

        // Type filter
        if (!"All".equals(invType) && invType != null && !invType.isEmpty()) {
            if ("Income".equals(invType)) {
                sql.append("AND tbl_OIncsummery.ID='INC' ");
            } else if ("Expenses".equals(invType)) {
                sql.append("AND tbl_OIncsummery.ID='EXP' ");
            }
        }

        // Method filter - always set to DIRECT
        sql.append("AND tbl_OIncsummery.DirectIndirect='DIRECT' ");

        // Date filter
        sql.append("AND tbl_OIncsummery.CreateDate BETWEEN ? AND ? ");
        params.add(dateFrom.format(DATE_FORMATTER));
        params.add(dateTo.format(DATE_FORMATTER));
    }

    private Map<String, String> buildFilters(
            String locaCode,
            String searchDescription,
            String searchVendor,
            String invType,
            LocalDate dateFrom,
            LocalDate dateTo) {

        Map<String, String> filters = new HashMap<>();

        // Location filter
        if ("All".equals(locaCode)) {
            filters.put("locaFilter", "");
        } else {
            filters.put("locaFilter", "AND tbl_OIncsummery.LocaCode='" + locaCode + "'");
        }

        // Description filter
        if (searchDescription == null || searchDescription.isEmpty()) {
            filters.put("descFilter", "");
        } else {
            filters.put("descFilter", "AND (tbl_OIncsummery.DescCode LIKE '%" + searchDescription + "%' " +
                    "OR tbl_OIncsummery.DescName LIKE '%" + searchDescription + "%' " +
                    "OR tbl_OIncsummery.SerialNo LIKE '%" + searchDescription + "%' " +
                    "OR tbl_OIncsummery.InvoiceNo LIKE '%" + searchDescription + "%' " +
                    "OR tbl_OIncsummery.ReferenceNo LIKE '%" + searchDescription + "%' )");
        }

        // Vendor filter
        if (searchVendor == null || searchVendor.isEmpty()) {
            filters.put("vendorFilter", "");
        } else {
            filters.put("vendorFilter", "AND (tbl_OIncsummery.CusCode LIKE '%" + searchVendor + "%' " +
                    "OR tbl_OIncsummery.CusName LIKE '%" + searchVendor + "%' )");
        }

        // Type filter
        if ("All".equals(invType)) {
            filters.put("typeFilter", "");
        } else if ("Income".equals(invType)) {
            filters.put("typeFilter", "AND tbl_OIncsummery.ID='INC'");
        } else if ("Expenses".equals(invType)) {
            filters.put("typeFilter", "AND tbl_OIncsummery.ID='EXP'");
        }

        // Method filter - in the original code this is always set to DIRECT
        filters.put("methodFilter", "AND tbl_OIncsummery.DirectIndirect='DIRECT'");

        // Date filter
        String formattedDateFrom = dateFrom.format(DATE_FORMATTER);
        String formattedDateTo = dateTo.format(DATE_FORMATTER);
        filters.put("dateFilter", "AND tbl_OIncsummery.CreateDate BETWEEN '" + formattedDateFrom + "' AND '" + formattedDateTo + "'");

        return filters;
    }

    private String buildExpensesDetailsQuery(Map<String, String> filters) {
        return "SELECT tbl_OIncsummery.LocaCode, tbl_OIncsummery.CreateDate, tbl_OIncsummery.ID, " +
                "tbl_OIncsummery.DirectIndirect, tbl_OIncsummery.SerialNo, tbl_OIncsummery.DescCode, " +
                "tbl_OIncsummery.DescBCode, tbl_OIncsummery.DescName, tbl_OIncsummery.CusCode, " +
                "(CASE WHEN tbl_OIncsummery.InvoiceDescription Is Null Or tbl_OIncsummery.InvoiceDescription='' THEN tbl_OIncsummery.CusName ELSE " +
                "CASE WHEN tbl_OIncsummery.CusName Is Null Or tbl_OIncsummery.CusName='Null' THEN tbl_OIncsummery.InvoiceDescription " +
                "ELSE tbl_OIncsummery.CusName + ' / ' + tbl_OIncsummery.InvoiceDescription END " +
                "END) AS Remark, tbl_OIncsummery.CusName, " +
                "tbl_OIncsummery.GTotal, tbl_OIncsummery.CashPaid, tbl_OIncsummery.CHQPaid, tbl_OIncsummery.IDueamount, " +
                "(CASE WHEN tbl_OIncsummery.BankPaid Is Null THEN 0 ELSE tbl_OIncsummery.BankPaid END) AS BankPaid, " +
                "tbl_OIncsummery.InvoiceDescription " +
                "FROM tbl_OIncsummery " +
                "WHERE tbl_OIncsummery.CompID=? " +
                filters.get("vendorFilter") + " " +
                filters.get("typeFilter") + " " +
                filters.get("descFilter") + " " +
                filters.get("methodFilter") + " " +
                filters.get("dateFilter") + " " +
                filters.get("locaFilter");
    }

    private Double getNetIncome(String companyId, Map<String, String> filters) {
        String query = "SELECT SUM(GTotal) AS NetIncome " +
                "FROM tbl_OIncsummery WHERE tbl_OIncsummery.ID='INC' AND tbl_OIncsummery.CompID=? " +
                filters.get("vendorFilter") + " " +
                filters.get("typeFilter") + " " +
                filters.get("descFilter") + " " +
                filters.get("methodFilter") + " " +
                filters.get("dateFilter") + " " +
                filters.get("locaFilter");

        Double netIncome = jdbcTemplate.queryForObject(query, Double.class, companyId);
        return netIncome != null ? netIncome : 0.0;
    }

    private Double getNetExpenses(String companyId, Map<String, String> filters) {
        String query = "SELECT SUM(GTotal) AS NetExpenses " +
                "FROM tbl_OIncsummery WHERE tbl_OIncsummery.ID='EXP' AND tbl_OIncsummery.CompID=? " +
                filters.get("typeFilter") + " " +
                filters.get("descFilter") + " " +
                filters.get("methodFilter") + " " +
                filters.get("dateFilter") + " " +
                filters.get("locaFilter");

        Double netExpenses = jdbcTemplate.queryForObject(query, Double.class, companyId);
        return netExpenses != null ? netExpenses : 0.0;
    }
}