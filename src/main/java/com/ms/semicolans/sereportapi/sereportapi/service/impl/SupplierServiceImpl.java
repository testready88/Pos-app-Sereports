package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCommonNameAndCodeDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCreditorsDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponsePayableDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.supplierdto.ResponseCreditorsDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.SupplierService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SupplierServiceImpl implements SupplierService {
    private final CompanyUserService companyUserService;

    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate mainJdbcTemplate;

    @Override
    public List<ResponseCommonNameAndCodeDTO> getAllSuppliersNameList(String searchText, String token) throws SQLException {
        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);

        String sql;
        Object[] params;

        if (searchText == null || searchText.trim().isEmpty()) {
            // If search text is empty, just filter by compId
            sql = "SELECT SupCode, SupName FROM tbl_SupDet WHERE CompId = ? ORDER BY SupName";
            params = new Object[]{userAllData.getCompanyId()};
        } else {
            // If search text is provided, filter by both compId and name (using LIKE)
            sql = "SELECT SupCode, SupName FROM tbl_SupDet WHERE CompId = ? AND SupName LIKE ? ORDER BY SupName";
            String searchPattern = "%" + searchText + "%";
            params = new Object[]{userAllData.getCompanyId(), searchPattern};
        }

        return mainJdbcTemplate.query(sql, params, (rs, rowNum) -> {
            ResponseCommonNameAndCodeDTO dto = new ResponseCommonNameAndCodeDTO();
            dto.setCode(rs.getString("SupCode"));
            dto.setName(rs.getString("SupName"));
            return dto;
        });
    }

    public void getSupplierData(String searchText, String token) throws SQLException {
        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);

        String sql = "SELECT * FROM tbl_SupDet WHERE CompId = ? ORDER BY SupName";
        Object[] params = new Object[]{userAllData.getCompanyId()};

        mainJdbcTemplate.query(sql, params, rs -> {
            ResultSetMetaData metadata = rs.getMetaData();

            for (int i = 0; i < metadata.getColumnCount(); i++) {
                System.out.println(metadata.getColumnName(i));
            }

        });
    }

    @Override
    public PaginatedResponsePayableDTO getPayableDetails(String token, String locaCode, String searchSupplier, String searchInvoice, String invGap, LocalDate dateFrom, LocalDate dateTo, int page, int size) throws SQLException {
        // Get user data from token
        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();

        // Build filter conditions
        String locationFilter = buildLocationFilter(locaCode);
        String supplierFilter = buildSupplierFilter(searchSupplier);
        String invoiceFilter = buildInvoiceFilter(searchInvoice);
        String invGapFilter = buildInvGapFilter(invGap);
        String dateFilter = "AND tbl_PurSummery.CreateDate BETWEEN ? AND ?";

        // Prepare parameters for the queries
        List<Object> queryParams = new ArrayList<>();
        queryParams.add(companyId);

        // Add filter parameters if provided
        if (!"All".equals(locaCode) && !locationFilter.isEmpty()) {
            queryParams.add(searchSupplier); // Note: In original code, location code filter used searchSupplier text
        }

        if (searchSupplier != null && !searchSupplier.isEmpty()) {
            String searchPattern = "%" + searchSupplier + "%";
            queryParams.add(searchPattern);
            queryParams.add(searchPattern);
        }

        if (searchInvoice != null && !searchInvoice.isEmpty()) {
            String searchPattern = "%" + searchInvoice + "%";
            queryParams.add(searchPattern);
            queryParams.add(searchPattern);
            queryParams.add(searchPattern);
        }

        // Add date parameters
        queryParams.add(java.sql.Date.valueOf(dateFrom));
        queryParams.add(java.sql.Date.valueOf(dateTo));
        // Parameters for the main data query with pagination
        List<Object> dataParams = new ArrayList<>(queryParams);
        dataParams.add(page * size);
        dataParams.add(size);

        // Main query with pagination
        String dataSql = "SELECT " +
                "tbl_PurSummery.LocaCode, " +
                "tbl_PurSummery.CreateDate, " +
                "tbl_PurSummery.SerialNo, " +
                "tbl_PurSummery.InvoiceNo, " +
                "tbl_PurSummery.CusName, " +
                "tbl_PurSummery.NTotal, " +
                "tbl_PurSummery.IDueAmount, " +
                "tbl_PurSummery.InvoiceDescription, " +
                "DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE()) AS InvGap " +
                "FROM tbl_PurSummery " +
                "WHERE tbl_PurSummery.CompID = ? " +
                "AND tbl_PurSummery.IDueAmount != 0 " +
                locationFilter + " " + supplierFilter + " " + invoiceFilter + " " + invGapFilter + " " + dateFilter + " " +
                "ORDER BY tbl_PurSummery.CusName ASC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        // Execute query and map results
        List<Object> payables = mainJdbcTemplate.query(dataSql, dataParams.toArray(), (rs, rowNum) -> {
            Map<String, Object> payable = new HashMap<>();
            payable.put("locaCode", rs.getString("LocaCode"));
            payable.put("createDate", rs.getDate("CreateDate"));
            payable.put("serialNo", rs.getString("SerialNo"));
            payable.put("invoiceNo", rs.getString("InvoiceNo"));
            payable.put("cusName", rs.getString("CusName"));
            payable.put("nTotal", rs.getDouble("NTotal"));
            payable.put("iDueAmount", rs.getDouble("IDueAmount"));
            payable.put("invoiceDescription", rs.getString("InvoiceDescription"));
            payable.put("invGap", rs.getInt("InvGap"));
            return payable;
        });

        // Count query
        String countSql = "SELECT COUNT(*) FROM tbl_PurSummery " +
                "WHERE tbl_PurSummery.CompID = ? " +
                "AND tbl_PurSummery.IDueAmount != 0 " +
                locationFilter + " " + supplierFilter + " " + invoiceFilter + " " + invGapFilter + " " + dateFilter;

        Long totalCount = mainJdbcTemplate.queryForObject(countSql, queryParams.toArray(), Long.class);

        // Summary query for total outstanding amount
        String summarySql = "SELECT SUM(tbl_PurSummery.IDueAmount) AS TotalOutstandingAmount " +
                "FROM tbl_PurSummery " +
                "WHERE tbl_PurSummery.CompID = ? " +
                "AND tbl_PurSummery.IDueAmount != 0 " +
                locationFilter + " " + supplierFilter + " " + invoiceFilter + " " + invGapFilter + " " + dateFilter;

        Double totalOutstandingAmount = mainJdbcTemplate.queryForObject(summarySql, queryParams.toArray(), Double.class);

        // Build response
        return PaginatedResponsePayableDTO.builder()
                .count(totalCount)
                .data(payables)
                .totalOutstandingAmount(totalOutstandingAmount != null ? totalOutstandingAmount : 0.0)
                .build();
    }


    public PaginatedResponseCreditorsDetailsDTO getAllSuppliersList(String supplierSearch,
                                                                    String creditSearch,
                                                                    String invGapFilter,
                                                                    String settlementGapFilter,
                                                                    Integer page,
                                                                    Integer size,
                                                                    String token) throws SQLException {
        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);

        // Initialize filters
        String supplierFilter = buildSupplierFilter(supplierSearch);
        String creditAmountFilter = buildCreditAmountFilter(creditSearch);
        String invGapFind = buildInvoiceGapFilter(invGapFilter);
        String settlementGapFind = buildSettlementGapFilter(settlementGapFilter);

        int pageNumber = (page != null) ? page : 0;
        int pageSize = (size != null) ? size : 10;
        int offset = pageNumber * pageSize;

        // Build the main query for ALL suppliers (including 0.00 outstanding)
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT tbl_SupDet.SupCode, tbl_SupDet.SupUniqID, tbl_SupDet.SupName, ")
                .append("(tbl_SupDet.SupMob1+' '+tbl_SupDet.SupMob2+' '+tbl_SupDet.SupPhone+' '+tbl_SupDet.SupHPhone) AS ContactDetails, ")
                .append("(tbl_SupDet.SupAddress+' '+tbl_SupDet.SupAddress2+' '+ tbl_SupDet.SupAddress3) AS AddressDetails, ")
                .append("tbl_SupDet.LastInvDate, SUM(tbl_SupDet.LastInvAmount) AS LastInvAmount, DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE()) AS InvGap, ")
                .append("tbl_SupDet.LastPayDate, SUM(tbl_SupDet.LastPayAmount) AS LastPayAmount, DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE()) AS PaymentGap, ")
                .append("(SUM(tbl_SupDet.OpeningBalance) + SUM(tbl_SupDet.DueAmount) + SUM(tbl_SupDet.CreditAdjust) - SUM(tbl_SupDet.DebitAdjust) - SUM(tbl_SupDet.AdvanceAmount)) AS OutstandingAmount, ")
                .append("(SELECT COUNT(tbl_ChqDet.ChqNo) FROM tbl_ChqDet WHERE tbl_ChqDet.Status ='PENDING' AND tbl_ChqDet.ChqType ='OWN CHQ' AND tbl_ChqDet.VenCode=tbl_SupDet.SupCode) AS NoOfCHQ, ")
                .append("(SELECT SUM(tbl_ChqDet.PaidAmount) FROM tbl_ChqDet WHERE tbl_ChqDet.Status ='PENDING' AND tbl_ChqDet.ChqType ='OWN CHQ' AND tbl_ChqDet.VenCode=tbl_SupDet.SupCode) AS ChqAmount, ")
                .append("SUM(tbl_SupDet.TotalPurchase) AS TotalPurchase, SUM(tbl_SupDet.DiscountAmount) AS DiscountAmount, SUM(tbl_SupDet.CreditLimit) AS CreditLimit, ")
                .append("tbl_SupDet.CreateBy, tbl_SupDet.CreateDate ")
                .append("FROM tbl_SupDet ")
                .append("WHERE tbl_SupDet.CompID = ? ")
                .append("AND tbl_SupDet.ActiveSupplier = '1' ")
                .append(supplierFilter)
                .append(creditAmountFilter)
                .append(invGapFind)
                .append(settlementGapFind)
                .append("GROUP BY tbl_SupDet.SupCode, tbl_SupDet.SupUniqID, tbl_SupDet.SupName, tbl_SupDet.LastInvDate, tbl_SupDet.LastPayDate, ")
                .append("tbl_SupDet.SupPhone, tbl_SupDet.SupHPhone, tbl_SupDet.SupMob1, tbl_SupDet.SupMob2, ")
                .append("tbl_SupDet.SupAddress, tbl_SupDet.SupAddress2, tbl_SupDet.SupAddress3, tbl_SupDet.CreateBy, tbl_SupDet.CreateDate ")
                .append("ORDER BY tbl_SupDet.SupName ASC ")
                .append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        // Prepare parameters
        List<Object> params = buildParameters(userAllData.getCompanyId().trim(), supplierSearch, offset, pageSize);

        // Execute the query
        List<ResponseCreditorsDetailsDTO> suppliersList = mainJdbcTemplate.query(
                sqlBuilder.toString(),
                params.toArray(),
                this::mapSupplierRow
        );

        // Build summary query for ALL suppliers
        StringBuilder summaryQueryBuilder = new StringBuilder();
        summaryQueryBuilder.append("SELECT COUNT(DISTINCT tbl_SupDet.SupCode) AS NoOfSuppliers, ")
                .append("SUM(OpeningBalance+DueAmount+CreditAdjust-DebitAdjust-AdvanceAmount) AS TotalOutstandingAmount ")
                .append("FROM tbl_SupDet ")
                .append("WHERE tbl_SupDet.CompID = ? ")
                .append("AND tbl_SupDet.ActiveSupplier = '1' ")
                .append(supplierFilter)
                .append(creditAmountFilter)
                .append(invGapFind)
                .append(settlementGapFind);

        // Execute summary query
        List<Object> summaryParams = buildSummaryParameters(userAllData.getCompanyId().trim(), supplierSearch);
        Map<String, Object> summaryResult = mainJdbcTemplate.queryForMap(summaryQueryBuilder.toString(), summaryParams.toArray());

        Long totalSuppliers = ((Number) summaryResult.getOrDefault("NoOfSuppliers", 0L)).longValue();
        Double totalOutstandingAmount = ((Number) summaryResult.getOrDefault("TotalOutstandingAmount", 0.0)).doubleValue();

        return PaginatedResponseCreditorsDetailsDTO.builder()
                .count(totalSuppliers)
                .totalOutstandingAmount(totalOutstandingAmount)
                .data(suppliersList)
                .build();
    }

    private ResponseCreditorsDetailsDTO mapSupplierRow(ResultSet rs, int rowNum) throws SQLException {
        ResponseCreditorsDetailsDTO dto = new ResponseCreditorsDetailsDTO();
        dto.setSupCode(rs.getString("SupCode"));
        dto.setSupUniqID(rs.getString("SupUniqID"));
        dto.setSupName(rs.getString("SupName"));
        dto.setContactDetails(rs.getString("ContactDetails"));
        dto.setAddressDetails(rs.getString("AddressDetails"));
        dto.setLastInvDate(rs.getDate("LastInvDate") != null ? rs.getDate("LastInvDate").toLocalDate() : null);
        dto.setLastInvAmount(rs.getDouble("LastInvAmount"));
        dto.setInvGap(rs.getInt("InvGap"));
        dto.setLastPayDate(rs.getDate("LastPayDate") != null ? rs.getDate("LastPayDate").toLocalDate() : null);
        dto.setLastPayAmount(rs.getDouble("LastPayAmount"));
        dto.setPaymentGap(rs.getInt("PaymentGap"));
        dto.setOutstandingAmount(rs.getDouble("OutstandingAmount"));
        dto.setNoOfCHQ(rs.getInt("NoOfCHQ"));
        dto.setChqAmount(rs.getDouble("ChqAmount"));
        dto.setTotalPurchase(rs.getDouble("TotalPurchase"));
        dto.setDiscountAmount(rs.getDouble("DiscountAmount"));
        dto.setCreditLimit(rs.getDouble("CreditLimit"));
        dto.setCreateBy(rs.getString("CreateBy"));
        dto.setCreateDate(rs.getDate("CreateDate") != null ? rs.getDate("CreateDate").toLocalDate() : null);
        return dto;
    }

    private String buildSupplierFilter(String supplierSearch) {
        if (supplierSearch != null && !supplierSearch.trim().isEmpty()) {
            return "AND (tbl_SupDet.SupUniqID LIKE ? " +
                    "OR tbl_SupDet.SupName LIKE ? " +
                    "OR tbl_SupDet.SupMob1 LIKE ? " +
                    "OR tbl_SupDet.SupMob2 LIKE ? " +
                    "OR tbl_SupDet.SupAddress LIKE ? " +
                    "OR tbl_SupDet.SupAddress2 LIKE ? " +
                    "OR tbl_SupDet.SupAddress3 LIKE ?) ";
        }
        return "";
    }

    private String buildCreditAmountFilter(String creditSearch) {
        if (creditSearch != null && !creditSearch.trim().isEmpty()) {
            return "AND (SUM(tbl_SupDet.OpeningBalance) + SUM(tbl_SupDet.DueAmount) + " +
                    "SUM(tbl_SupDet.CreditAdjust) - SUM(tbl_SupDet.DebitAdjust) - " +
                    "SUM(tbl_SupDet.AdvanceAmount)) != 0 ";
        }
        return "";
    }

    private String buildInvoiceGapFilter(String invGapFilter) {
        if (invGapFilter == null || invGapFilter.equals("All")) return "";

        switch (invGapFilter) {
            case "0 to 10 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE())) >= 0 AND (DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE())) <= 10 ";
            case "10 to 20 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE())) >= 10 AND (DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE())) <= 20 ";
            case "20 to 30 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE())) >= 20 AND (DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE())) <= 30 ";
            case "Above 30 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE())) >= 30 ";
            case "Above 60 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE())) >= 60 ";
            case "Above 90 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE())) >= 90 ";
            case "Above 180 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastInvDate, GETDATE())) >= 180 ";
            default:
                return "";
        }
    }

    private String buildSettlementGapFilter(String settlementGapFilter) {
        if (settlementGapFilter == null || settlementGapFilter.equals("All")) return "";

        switch (settlementGapFilter) {
            case "0 to 10 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE())) >= 0 AND (DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE())) <= 10 ";
            case "10 to 20 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE())) >= 10 AND (DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE())) <= 20 ";
            case "20 to 30 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE())) >= 20 AND (DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE())) <= 30 ";
            case "Above 30 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE())) >= 30 ";
            case "Above 60 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE())) >= 60 ";
            case "Above 90 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE())) >= 90 ";
            case "Above 180 Days":
                return "AND (DATEDIFF(DAY, tbl_SupDet.LastPayDate, GETDATE())) >= 180 ";
            default:
                return "";
        }
    }

    private List<Object> buildParameters(String companyId, String supplierSearch, int offset, int pageSize) {
        List<Object> params = new ArrayList<>();
        params.add(companyId);

        if (supplierSearch != null && !supplierSearch.trim().isEmpty()) {
            String searchPattern = "%" + supplierSearch + "%";
            for (int i = 0; i < 7; i++) {
                params.add(searchPattern);
            }
        }

        params.add(offset);
        params.add(pageSize);
        return params;
    }

    private List<Object> buildSummaryParameters(String companyId, String supplierSearch) {
        List<Object> params = new ArrayList<>();
        params.add(companyId);

        if (supplierSearch != null && !supplierSearch.trim().isEmpty()) {
            String searchPattern = "%" + supplierSearch + "%";
            for (int i = 0; i < 7; i++) {
                params.add(searchPattern);
            }
        }
        return params;
    }

    /**
     * Build location filter condition
     */
    private String buildLocationFilter(String locaCode) {
        if ("All".equals(locaCode)) {
            return "";
        }
        return "AND (tbl_PurSummery.LocaCode = ?) ";
    }



    /**
     * Build invoice filter condition
     */
    private String buildInvoiceFilter(String searchInvoice) {
        if (searchInvoice == null || searchInvoice.isEmpty()) {
            return "";
        }
        return "AND (tbl_PurSummery.SerialNo LIKE ? OR tbl_PurSummery.InvoiceNo LIKE ? OR tbl_PurSummery.InvoiceDescription LIKE ?) ";
    }

    /**
     * Build invoice gap filter condition
     */
    private String buildInvGapFilter(String invGap) {
        if ("All".equals(invGap)) {
            return "";
        } else if ("0 to 10 Days".equals(invGap)) {
            return "AND (DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE())) >= 0 AND (DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE())) <= 10 ";
        } else if ("10 to 20 Days".equals(invGap)) {
            return "AND (DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE())) >= 10 AND (DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE())) <= 20 ";
        } else if ("20 to 30 Days".equals(invGap)) {
            return "AND (DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE())) >= 20 AND (DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE())) <= 30 ";
        } else if ("Above 30 Days".equals(invGap)) {
            return "AND (DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE())) >= 30 ";
        } else if ("Above 60 Days".equals(invGap)) {
            return "AND (DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE())) >= 60 ";
        } else if ("Above 90 Days".equals(invGap)) {
            return "AND (DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE())) >= 90 ";
        } else if ("Above 180 Days".equals(invGap)) {
            return "AND (DATEDIFF(DAY, tbl_PurSummery.CreateDate, GETDATE())) >= 180 ";
        }

        return "";
    }
}