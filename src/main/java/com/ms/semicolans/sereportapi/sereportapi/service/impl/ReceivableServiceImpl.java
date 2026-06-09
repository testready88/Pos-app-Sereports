package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.*;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseReceivableDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.ReceivableService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.*;


@Service
@Repository
@RequiredArgsConstructor
public class ReceivableServiceImpl implements ReceivableService {
    private final CompanyUserService companyUserService;
    private final JdbcTemplate mainJdbcTemplate;
    @Override
    public PaginatedResponseReceivableDTO getReceivableDetails(
            String token,
            String locaCode,
            String searchCustomer,
            String searchInvoice,
            String invGap,
            LocalDate dateFrom,
            LocalDate dateTo,
            int page,
            int size) throws SQLException {

        // Get user data from token
        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();

        // Build filter conditions
        Map<String, Object> filterParams = new HashMap<>();
        filterParams.put("companyId", companyId);

        StringBuilder filterConditions = new StringBuilder();
        List<Object> queryParams = new ArrayList<>();

        // Add company ID parameter (always included)
        queryParams.add(companyId);

        // Location code filter
        String locationFilter = buildLocationFilter(locaCode);
        filterConditions.append(locationFilter);
        if (!"All".equals(locaCode) && !locationFilter.isEmpty()) {
            queryParams.add(locaCode);
        }

        // Customer filter
        String customerFilter = buildCustomerFilter(searchCustomer);
        filterConditions.append(customerFilter);
        if (searchCustomer != null && !searchCustomer.isEmpty()) {
            String searchPattern = "%" + searchCustomer + "%";
            queryParams.add(searchPattern);
            queryParams.add(searchPattern);
        }

        // Invoice filter
        String invoiceFilter = buildInvoiceFilter(searchInvoice);
        filterConditions.append(invoiceFilter);
        if (searchInvoice != null && !searchInvoice.isEmpty()) {
            String searchPattern = "%" + searchInvoice + "%";
            queryParams.add(searchPattern);
            queryParams.add(searchPattern);
            queryParams.add(searchPattern);
        }

        // Invoice Gap filter
        String invGapFilter = buildInvGapFilter(invGap);
        filterConditions.append(invGapFilter);

        // Date range filter
        String dateFilter = " AND tbl_InvSummery.CreateDate BETWEEN ? AND ?";
        filterConditions.append(dateFilter);
        queryParams.add(dateFrom.toString());
        queryParams.add(dateTo.toString());

        // Main query parameters
        List<Object> dataParams = new ArrayList<>(queryParams);
        dataParams.add(page * size);
        dataParams.add(size);

        // Data query with pagination
        String dataSql = "SELECT " +
                "tbl_InvSummery.LocaCode, " +
                "tbl_InvSummery.CreateDate, " +
                "tbl_InvSummery.SerialNo, " +
                "tbl_InvSummery.InvoiceNo, " +
                "tbl_InvSummery.CusName, " +
                "tbl_InvSummery.NTotal, " +
                "tbl_InvSummery.IDueAmount, " +
                "tbl_InvSummery.InvoiceDescription, " +
                "DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE()) AS InvGap " +
                "FROM tbl_InvSummery " +
                "WHERE tbl_InvSummery.CompID = ? " +
                "AND tbl_InvSummery.IDueAmount != 0 " +
                filterConditions +
                " ORDER BY tbl_InvSummery.CusName ASC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        // Execute query and map results
        List<Object> receivables = mainJdbcTemplate.query(dataSql, dataParams.toArray(), (rs, rowNum) -> {
            Map<String, Object> receivable = new HashMap<>();
            receivable.put("locaCode", rs.getString("LocaCode"));
            receivable.put("createDate", rs.getDate("CreateDate"));
            receivable.put("serialNo", rs.getString("SerialNo"));
            receivable.put("invoiceNo", rs.getString("InvoiceNo"));
            receivable.put("cusName", rs.getString("CusName"));
            receivable.put("nTotal", rs.getDouble("NTotal"));
            receivable.put("iDueAmount", rs.getDouble("IDueAmount"));
            receivable.put("invoiceDescription", rs.getString("InvoiceDescription"));
            receivable.put("invGap", rs.getInt("InvGap"));
            return receivable;
        });

        // Count query
        String countSql = "SELECT COUNT(*) FROM tbl_InvSummery " +
                "WHERE tbl_InvSummery.CompID = ? " +
                "AND tbl_InvSummery.IDueAmount != 0 " +
                filterConditions;

        Long totalCount = mainJdbcTemplate.queryForObject(countSql, queryParams.toArray(), Long.class);

        // Summary query for total outstanding amount
        String summarySql = "SELECT SUM(tbl_InvSummery.IDueAmount) AS TotalOutstandingAmount " +
                "FROM tbl_InvSummery " +
                "WHERE tbl_InvSummery.CompID = ? " +
                "AND tbl_InvSummery.IDueAmount != 0 " +
                filterConditions;

        Double totalOutstandingAmount = mainJdbcTemplate.queryForObject(summarySql, queryParams.toArray(), Double.class);

        // Build response
        return PaginatedResponseReceivableDTO.builder()
                .count(totalCount)
                .data(receivables)
                .totalOutstandingAmount(totalOutstandingAmount != null ? totalOutstandingAmount : 0.0)
                .build();
    }

    /**
     * Build location code filter condition
     */
    private String buildLocationFilter(String locaCode) {
        if ("All".equals(locaCode)) {
            return "";
        }
        return " AND (tbl_InvSummery.LocaCode = ?) ";
    }

    /**
     * Build customer filter condition
     */
    private String buildCustomerFilter(String searchCustomer) {
        if (searchCustomer == null || searchCustomer.isEmpty()) {
            return "";
        }
        return " AND (tbl_InvSummery.CusName LIKE ? OR tbl_InvSummery.CusCode LIKE ?) ";
    }

    /**
     * Build invoice filter condition
     */
    private String buildInvoiceFilter(String searchInvoice) {
        if (searchInvoice == null || searchInvoice.isEmpty()) {
            return "";
        }
        return " AND (tbl_InvSummery.SerialNo LIKE ? OR tbl_InvSummery.InvoiceNo LIKE ? OR tbl_InvSummery.InvoiceDescription LIKE ?) ";
    }

    /**
     * Build invoice gap filter condition
     */
    private String buildInvGapFilter(String invGap) {
        if ("All".equals(invGap)) {
            return "";
        } else if ("0 to 10 Days".equals(invGap)) {
            return " AND (DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE())) >= 0 AND (DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE())) <= 10 ";
        } else if ("10 to 20 Days".equals(invGap)) {
            return " AND (DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE())) >= 10 AND (DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE())) <= 20 ";
        } else if ("20 to 30 Days".equals(invGap)) {
            return " AND (DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE())) >= 20 AND (DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE())) <= 30 ";
        } else if ("Above 30 Days".equals(invGap)) {
            return " AND (DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE())) >= 30 ";
        } else if ("Above 60 Days".equals(invGap)) {
            return " AND (DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE())) >= 60 ";
        } else if ("Above 90 Days".equals(invGap)) {
            return " AND (DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE())) >= 90 ";
        } else if ("Above 180 Days".equals(invGap)) {
            return " AND (DATEDIFF(DAY, tbl_InvSummery.CreateDate, GETDATE())) >= 180 ";
        }

        return "";
    }
}
