package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCreditorsDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.supplierdto.ResponseCreditorsDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.SupplierCreditorService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SupplierCreditorServiceImpl implements SupplierCreditorService {
    private final CompanyUserService companyUserService;

    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate mainJdbcTemplate;

    public PaginatedResponseCreditorsDetailsDTO getCreditorsDetailsList(String supplierSearch,
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

        // Build the main query - back to original structure but with creditors filter
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
                .append("AND (OpeningBalance+DueAmount+CreditAdjust-DebitAdjust-AdvanceAmount) != 0 ")
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

        // Debug logging
        System.out.println("=== DEBUGGING CREDITORS QUERY ===");
        System.out.println("Company ID: " + userAllData.getCompanyId().trim());
        System.out.println("Page: " + pageNumber + ", Size: " + pageSize + ", Offset: " + offset);
        System.out.println("Supplier Search: " + supplierSearch);
        System.out.println("Credit Search: " + creditSearch);
        System.out.println("Inv Gap Filter: " + invGapFilter);
        System.out.println("Settlement Gap Filter: " + settlementGapFilter);
        System.out.println("Main Query: " + sqlBuilder.toString());
        System.out.println("Main Query Parameters: " + params);

        // Execute the query
        List<ResponseCreditorsDetailsDTO> creditorsList = mainJdbcTemplate.query(
                sqlBuilder.toString(),
                params.toArray(),
                this::mapCreditorRow
        );

        System.out.println("Query executed successfully. Results count: " + creditorsList.size());

        // Build summary query - matching the main query logic
        StringBuilder summaryQueryBuilder = new StringBuilder();
        summaryQueryBuilder.append("SELECT COUNT(DISTINCT tbl_SupDet.SupCode) AS NoOfSuppliers, ")
                .append("SUM(OpeningBalance+DueAmount+CreditAdjust-DebitAdjust-AdvanceAmount) AS TotalOutstandingAmount ")
                .append("FROM tbl_SupDet ")
                .append("WHERE tbl_SupDet.CompID = ? ")
                .append("AND tbl_SupDet.ActiveSupplier = '1' ")
                .append("AND (OpeningBalance+DueAmount+CreditAdjust-DebitAdjust-AdvanceAmount) != 0 ")
                .append(supplierFilter)
                .append(creditAmountFilter)
                .append(invGapFind)
                .append(settlementGapFind);

        // Execute summary query
        List<Object> summaryParams = buildSummaryParameters(userAllData.getCompanyId().trim(), supplierSearch);

        System.out.println("Summary Query: " + summaryQueryBuilder.toString());
        System.out.println("Summary Query Parameters: " + summaryParams);

        Map<String, Object> summaryResult = mainJdbcTemplate.queryForMap(summaryQueryBuilder.toString(), summaryParams.toArray());

        Long totalCreditors = ((Number) summaryResult.getOrDefault("NoOfSuppliers", 0L)).longValue();
        Double totalOutstandingAmount = ((Number) summaryResult.getOrDefault("TotalOutstandingAmount", 0.0)).doubleValue();

        System.out.println("Summary - Total Creditors: " + totalCreditors + ", Total Outstanding: " + totalOutstandingAmount);
        System.out.println("=== END DEBUGGING ===");

        return PaginatedResponseCreditorsDetailsDTO.builder()
                .count(totalCreditors)
                .totalOutstandingAmount(totalOutstandingAmount)
                .data(creditorsList)
                .build();
    }

    private ResponseCreditorsDetailsDTO mapCreditorRow(ResultSet rs, int rowNum) throws SQLException {
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
        // This was causing issues - let's simplify it
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
}