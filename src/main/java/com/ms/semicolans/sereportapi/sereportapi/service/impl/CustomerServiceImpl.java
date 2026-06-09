package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.customerdto.ResponseCustomerDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCustomerRecordeDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class CustomerServiceImpl {

    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate mainJdbcTemplate;

    private final CompanyUserService companyUserService;

    public PaginatedResponseCustomerRecordeDTO getCustomerDetails(
            String token,
            String searchText,
            boolean filterCreditAmount,
            String invGapFilter,
            String settlementGapFilter,
            int page,
            int size) throws SQLException {

        // Get company ID from token
        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId().trim();

        // Build SQL filters based on parameters
        StringBuilder whereClause = new StringBuilder();
        List<Object> params = new ArrayList<>();

        // Base conditions
        whereClause.append("tbl_CusDet.CompID = ? AND tbl_CusDet.ActiveCustomer = '1' ");
        params.add(companyId);

        // Customer search filter
        if (searchText != null && !searchText.isEmpty()) {
            whereClause.append("AND (tbl_CusDet.CusNIC LIKE ? ")
                    .append("OR tbl_CusDet.CusName LIKE ? ")
                    .append("OR tbl_CusDet.CusMob1 LIKE ? ")
                    .append("OR tbl_CusDet.CusMob2 LIKE ? ")
                    .append("OR tbl_CusDet.CusAddress LIKE ? ")
                    .append("OR tbl_CusDet.CusAddress2 LIKE ? ")
                    .append("OR tbl_CusDet.CusAddress3 LIKE ?) ");

            String searchPattern = "%" + searchText + "%";
            for (int i = 0; i < 7; i++) { // Add 7 parameters for the LIKE conditions
                params.add(searchPattern);
            }
        }

        // Credit Amount Filter
        StringBuilder havingClause = new StringBuilder();
        if (filterCreditAmount) {
            havingClause.append("HAVING (SUM(tbl_CusDet.OpeningBalance) + SUM(tbl_CusDet.DueAmount) + ")
                    .append("SUM(tbl_CusDet.CreditAdjust) - SUM(tbl_CusDet.DebitAdjust) - SUM(tbl_CusDet.AdvanceAmount)) != 0 ");
        }


        // Invoice Gap Filter
        if (invGapFilter != null && !invGapFilter.equals("All")) {
            switch (invGapFilter) {
                case "0 to 10 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 0 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) <= 10 ");
                    break;
                case "10 to 20 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 10 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) <= 20 ");
                    break;
                case "20 to 30 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 20 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) <= 30 ");
                    break;
                case "Above 30 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 30 ");
                    break;
                case "Above 60 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 60 ");
                    break;
                case "Above 90 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 90 ");
                    break;
                case "Above 180 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 180 ");
                    break;
            }
        }

        // Settlement Gap Filter
        if (settlementGapFilter != null && !settlementGapFilter.equals("All")) {
            switch (settlementGapFilter) {
                case "0 to 10 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 0 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) <= 10 ");
                    break;
                case "10 to 20 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 10 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) <= 20 ");
                    break;
                case "20 to 30 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 20 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) <= 30 ");
                    break;
                case "Above 30 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 30 ");
                    break;
                case "Above 60 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 60 ");
                    break;
                case "Above 90 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 90 ");
                    break;
                case "Above 180 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 180 ");
                    break;
            }
        }

        // First, get the total count of records (without pagination)
        String countSql = "SELECT COUNT(DISTINCT tbl_CusDet.CusCode) FROM tbl_CusDet WHERE " + whereClause.toString();
        Long totalRecords = mainJdbcTemplate.queryForObject(countSql, params.toArray(), Long.class);

        // Main query to get paginated customer details
        String customerDetailsSql =
                "SELECT tbl_CusDet.CusCode, tbl_CusDet.CusNIC, tbl_CusDet.CusName,tbl_CusDet.CusPriceCategory, " +
                "(tbl_CusDet.CusMob1 + ' ' + tbl_CusDet.CusMob2 + ' ' + tbl_CusDet.CusPhone + ' ' + tbl_CusDet.CusHPhone) AS ContactDetails, " +
                "(tbl_CusDet.CusAddress + ' ' + tbl_CusDet.CusAddress2 + ' ' + tbl_CusDet.CusAddress3) AS AddressDetails, " +
                "tbl_CusDet.LastInvDate, SUM(tbl_CusDet.LastInvAmount) AS LastInvAmount, " +
                "DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE()) AS InvGap, " +
                "tbl_CusDet.LastPayDate, SUM(tbl_CusDet.LastPayAmount) AS LastPayAmount, " +
                "DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE()) AS PaymentGap, " +
                "(SUM(tbl_CusDet.OpeningBalance) + SUM(tbl_CusDet.DueAmount) + SUM(tbl_CusDet.CreditAdjust) " +
                "- SUM(tbl_CusDet.DebitAdjust) - SUM(tbl_CusDet.AdvanceAmount)) AS OutstandingAmount, " +
                "(SELECT COUNT(tbl_ChqDet.ChqNo) FROM tbl_ChqDet WHERE tbl_ChqDet.Status = 'PENDING' " +
                "AND tbl_ChqDet.ChqType = 'IN HAND' AND tbl_ChqDet.VenCode = tbl_CusDet.CusCode) AS NoOfCHQ, " +
                "(SELECT SUM(tbl_ChqDet.PaidAmount) FROM tbl_ChqDet WHERE tbl_ChqDet.Status = 'PENDING' " +
                "AND tbl_ChqDet.ChqType = 'IN HAND' AND tbl_ChqDet.VenCode = tbl_CusDet.CusCode) AS ChqAmount, " +
                "SUM(tbl_CusDet.TotalPurchase) AS TotalPurchase, " +
                "SUM(tbl_CusDet.DiscountAmount) AS DiscountAmount, " +
                "SUM(tbl_CusDet.CreditLimit) AS CreditLimit, " +
                "tbl_CusDet.CreateBy, tbl_CusDet.CreateDate " +
                "FROM tbl_CusDet WHERE " + whereClause.toString() +
                "GROUP BY tbl_CusDet.CusCode, tbl_CusDet.CusNIC, tbl_CusDet.CusName,tbl_CusDet.CusPriceCategory, tbl_CusDet.LastInvDate, " +
                "tbl_CusDet.LastPayDate, tbl_CusDet.CusPhone, tbl_CusDet.CusHPhone, tbl_CusDet.CusMob1, " +
                "tbl_CusDet.CusMob2, tbl_CusDet.CusAddress, tbl_CusDet.CusAddress2, tbl_CusDet.CusAddress3, " +
                "tbl_CusDet.CreateBy, tbl_CusDet.CreateDate " +
                "ORDER BY tbl_CusDet.CusName ASC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        // pagination parameters
        params.add((page) * size);
        params.add(size);

        // Execute query and map results
        List<ResponseCustomerDetailsDTO> customers = mainJdbcTemplate.query(
                customerDetailsSql,
                params.toArray(),
                (rs, rowNum) -> ResponseCustomerDetailsDTO.builder()
                        .customerCode(rs.getString("CusCode"))
                        .customerNic(rs.getString("CusNIC"))
                        .customerName(rs.getString("CusName"))
                        .contactDetails(rs.getString("ContactDetails"))
                        .addressDetails(rs.getString("AddressDetails"))
                        .lastInvoiceDate(rs.getDate("LastInvDate"))
                        .lastInvoiceAmount(rs.getDouble("LastInvAmount"))
                        .invoiceGap(rs.getInt("InvGap"))
                        .lastPaymentDate(rs.getDate("LastPayDate"))
                        .lastPaymentAmount(rs.getDouble("LastPayAmount"))
                        .paymentGap(rs.getInt("PaymentGap"))
                        .outstandingAmount(rs.getDouble("OutstandingAmount"))
                        .numberOfCheques(rs.getInt("NoOfCHQ"))
                        .chequeAmount(rs.getDouble("ChqAmount"))
                        .totalPurchase(rs.getDouble("TotalPurchase"))
                        .discountAmount(rs.getDouble("DiscountAmount"))
                        .creditLimit(rs.getDouble("CreditLimit"))
                        .createdBy(rs.getString("CreateBy"))
                        .createdDate(rs.getTimestamp("CreateDate"))
                        .priceCategory(rs.getString("CusPriceCategory")) // Default to RETAIL since PriceCategory column doesn't exist in tbl_CusDet
                        .build()
        );

        // Summary query to get total outstanding amount
        String summarySql =
                "SELECT SUM(OpeningBalance + DueAmount + CreditAdjust - DebitAdjust - AdvanceAmount) AS TotalOutstandingAmount " +
                "FROM tbl_CusDet WHERE " + whereClause.toString();

        // Create new parameters list without pagination parameters for summary query
        List<Object> summaryParams = new ArrayList<>(params);
        summaryParams.remove(summaryParams.size() - 1);
        summaryParams.remove(summaryParams.size() - 1);

        // Execute summary query
        Double totalOutstandingAmount = mainJdbcTemplate.queryForObject(
                summarySql,
                summaryParams.toArray(),
                Double.class
        );
        System.out.println("customers"+ customers);
        // Build and return the paginated response
        return PaginatedResponseCustomerRecordeDTO.builder()
                .count(totalRecords)
                .data(customers)
                .totalOutstandingAmount(totalOutstandingAmount)
                .build();
    }

    public PaginatedResponseCustomerRecordeDTO getDebtorsDetails(
            String token,
            String searchText,
            String creditAmount,
            String invGap,
            String settlementGap,
            int page,
            int size) throws SQLException {

        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId().trim();

        // Build SQL filters based on parameters
        StringBuilder whereClause = new StringBuilder();
        List<Object> params = new ArrayList<>();

        // Base conditions
        whereClause.append("tbl_CusDet.CompID = ? AND tbl_CusDet.ActiveCustomer = '1' ");
        params.add(companyId);

        // Customer search filter
        if (searchText != null && !searchText.isEmpty()) {
            whereClause.append("AND (tbl_CusDet.CusName LIKE ? ")
                    .append("OR tbl_CusDet.CusMob1 LIKE ? ")
                    .append("OR tbl_CusDet.CusMob2 LIKE ? ")
                    .append("OR tbl_CusDet.CusAddress LIKE ? ")
                    .append("OR tbl_CusDet.CusAddress2 LIKE ? ")
                    .append("OR tbl_CusDet.CusAddress3 LIKE ?) ");

            String searchPattern = "%" + searchText + "%";
            for (int i = 0; i < 6; i++) {
                params.add(searchPattern);
            }
        }

        // Credit Amount Filter
        if (creditAmount != null && !creditAmount.isEmpty()) {
            whereClause.append("AND (SUM(tbl_CusDet.OpeningBalance) + SUM(tbl_CusDet.DueAmount) + ")
                    .append("SUM(tbl_CusDet.CreditAdjust) - SUM(tbl_CusDet.DebitAdjust) - ")
                    .append("SUM(tbl_CusDet.AdvanceAmount)) != 0 ");
        }

        // Invoice Gap Filter
        applyInvoiceGapFilter(invGap, whereClause);

        // Settlement Gap Filter
        applySettlementGapFilter(settlementGap, whereClause);

        // Count total records
        String countSql = "SELECT COUNT(DISTINCT tbl_CusDet.CusCode) FROM tbl_CusDet WHERE " + whereClause;
        Long totalRecords = mainJdbcTemplate.queryForObject(countSql, params.toArray(), Long.class);

        // Main query for customer details
        String customerDetailsSql = buildCustomerDetailsSql(whereClause);

        // Add pagination parameters
        params.add(page * size);
        params.add(size);

        // Execute query and map results
        List<ResponseCustomerDetailsDTO> customers = mainJdbcTemplate.query(
                customerDetailsSql,
                params.toArray(),
                (rs, rowNum) -> mapToCustomerDetailsDTO(rs)
        );
        System.out.println("customers" + customers);
        // Get summary information - total outstanding amount
        Double totalOutstandingAmount = getTotalOutstandingAmount(whereClause, params);

        // Build and return the paginated response
        return PaginatedResponseCustomerRecordeDTO.builder()
                .count(totalRecords)
                .data(customers)
                .totalOutstandingAmount(totalOutstandingAmount)
                .build();
    }

    private void applyInvoiceGapFilter(String invGap, StringBuilder whereClause) {
        if (invGap != null && !invGap.equals("All")) {
            switch (invGap) {
                case "0 to 10 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 0 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) <= 10 ");
                    break;
                case "10 to 20 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 10 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) <= 20 ");
                    break;
                case "20 to 30 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 20 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) <= 30 ");
                    break;
                case "Above 30 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 30 ");
                    break;
                case "Above 60 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 60 ");
                    break;
                case "Above 90 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 90 ");
                    break;
                case "Above 180 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE())) >= 180 ");
                    break;
            }
        }
    }

    private void applySettlementGapFilter(String settlementGap, StringBuilder whereClause) {
        if (settlementGap != null && !settlementGap.equals("All")) {
            switch (settlementGap) {
                case "0 to 10 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 0 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) <= 10 ");
                    break;
                case "10 to 20 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 10 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) <= 20 ");
                    break;
                case "20 to 30 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 20 ")
                            .append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) <= 30 ");
                    break;
                case "Above 30 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 30 ");
                    break;
                case "Above 60 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 60 ");
                    break;
                case "Above 90 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 90 ");
                    break;
                case "Above 180 Days":
                    whereClause.append("AND (DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE())) >= 180 ");
                    break;
            }
        }
    }

    private String buildCustomerDetailsSql(StringBuilder whereClause) {
        return "SELECT tbl_CusDet.CusCode, tbl_CusDet.CusNIC, tbl_CusDet.CusName,tbl_CusDet.CusPriceCategory, " +
                "(tbl_CusDet.CusMob1 + ' ' + tbl_CusDet.CusMob2 + ' ' + tbl_CusDet.CusPhone + ' ' + tbl_CusDet.CusHPhone) AS ContactDetails, " +
                "(tbl_CusDet.CusAddress + ' ' + tbl_CusDet.CusAddress2 + ' ' + tbl_CusDet.CusAddress3) AS AddressDetails, " +
                "tbl_CusDet.LastInvDate, SUM(tbl_CusDet.LastInvAmount) AS LastInvAmount, " +
                "DATEDIFF(DAY, tbl_CusDet.LastInvDate, GETDATE()) AS InvGap, " +
                "tbl_CusDet.LastPayDate, SUM(tbl_CusDet.LastPayAmount) AS LastPayAmount, " +
                "DATEDIFF(DAY, tbl_CusDet.LastPayDate, GETDATE()) AS PaymentGap, " +
                "(SUM(tbl_CusDet.OpeningBalance) + SUM(tbl_CusDet.DueAmount) + SUM(tbl_CusDet.CreditAdjust) " +
                "- SUM(tbl_CusDet.DebitAdjust) - SUM(tbl_CusDet.AdvanceAmount)) AS OutstandingAmount, " +
                "(SELECT COUNT(tbl_ChqDet.ChqNo) FROM tbl_ChqDet WHERE tbl_ChqDet.Status = 'PENDING' " +
                "AND tbl_ChqDet.ChqType = 'OWN CHQ' AND tbl_ChqDet.VenCode = tbl_CusDet.CusCode) AS NoOfCHQ, " +
                "(SELECT SUM(tbl_ChqDet.PaidAmount) FROM tbl_ChqDet WHERE tbl_ChqDet.Status = 'PENDING' " +
                "AND tbl_ChqDet.ChqType = 'OWN CHQ' AND tbl_ChqDet.VenCode = tbl_CusDet.CusCode) AS ChqAmount, " +
                "SUM(tbl_CusDet.TotalPurchase) AS TotalPurchase, " +
                "SUM(tbl_CusDet.DiscountAmount) AS DiscountAmount, " +
                "SUM(tbl_CusDet.CreditLimit) AS CreditLimit, " +
                "tbl_CusDet.CreateBy, tbl_CusDet.CreateDate " +
                "FROM tbl_CusDet WHERE " + whereClause +
                "GROUP BY tbl_CusDet.CusCode, tbl_CusDet.CusNIC, tbl_CusDet.CusName,tbl_CusDet.CusPriceCategory, tbl_CusDet.LastInvDate, " +
                "tbl_CusDet.LastPayDate, tbl_CusDet.CusPhone, tbl_CusDet.CusHPhone, tbl_CusDet.CusMob1, " +
                "tbl_CusDet.CusMob2, tbl_CusDet.CusAddress, tbl_CusDet.CusAddress2, tbl_CusDet.CusAddress3, " +
                "tbl_CusDet.CreateBy, tbl_CusDet.CreateDate " +
                "ORDER BY tbl_CusDet.CusName ASC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
    }

    private ResponseCustomerDetailsDTO mapToCustomerDetailsDTO(java.sql.ResultSet rs) throws java.sql.SQLException {
        return ResponseCustomerDetailsDTO.builder()
                .customerCode(rs.getString("CusCode"))
                .customerNic(rs.getString("CusNIC"))
                .customerName(rs.getString("CusName"))
                .contactDetails(rs.getString("ContactDetails"))
                .addressDetails(rs.getString("AddressDetails"))
                .lastInvoiceDate(rs.getDate("LastInvDate"))
                .lastInvoiceAmount(rs.getDouble("LastInvAmount"))
                .invoiceGap(rs.getInt("InvGap"))
                .lastPaymentDate(rs.getDate("LastPayDate"))
                .lastPaymentAmount(rs.getDouble("LastPayAmount"))
                .paymentGap(rs.getInt("PaymentGap"))
                .outstandingAmount(rs.getDouble("OutstandingAmount"))
                .numberOfCheques(rs.getInt("NoOfCHQ"))
                .chequeAmount(rs.getDouble("ChqAmount"))
                .totalPurchase(rs.getDouble("TotalPurchase"))
                .discountAmount(rs.getDouble("DiscountAmount"))
                .creditLimit(rs.getDouble("CreditLimit"))
                .createdBy(rs.getString("CreateBy"))
                .createdDate(rs.getTimestamp("CreateDate"))
                .priceCategory(rs.getString("CusPriceCategory")) // Default to RETAIL since PriceCategory column doesn't exist in tbl_CusDet
                .build();
    }

    private Double getTotalOutstandingAmount(StringBuilder whereClause, List<Object> params) {
        // Create a new list without pagination parameters for summary query
        List<Object> summaryParams = new ArrayList<>(params.subList(0, params.size() - 2));

        String summarySql =
                "SELECT SUM(OpeningBalance + DueAmount + CreditAdjust - DebitAdjust - AdvanceAmount) AS TotalOutstandingAmount " +
                        "FROM tbl_CusDet WHERE " + whereClause;

        return mainJdbcTemplate.queryForObject(
                summarySql,
                summaryParams.toArray(),
                Double.class
        );
    }

}
