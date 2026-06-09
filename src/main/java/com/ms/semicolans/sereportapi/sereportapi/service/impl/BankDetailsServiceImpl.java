package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseBankDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseBankDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseBankSummaryDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.BankDetailsService;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BankDetailsServiceImpl implements BankDetailsService {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final CompanyUserService companyUserService;

    @Override
    public List<String> getAllBankNames(String token) throws SQLException {
        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);
        String companyId = userAllData.getCompanyId();
        String sql = "SELECT BnkName FROM tbl_BankDet WHERE CompID = ? ORDER BY BnkName ASC";
        return jdbcTemplate.queryForList(sql, String.class, companyId);
    }

    @Override
    public ResponseBankDTO getBankDetails(String token, String bankName, String locationCode, String dateTo) throws SQLException {
        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);
        String companyId = userAllData.getCompanyId();
        // Create bank filter and location filter strings
        String locationFilter = createLocationFilter(locationCode);
        String bankFilter = createBankFilter(bankName);

        // Location filter for bank transactions
        String locationFilterBankTransaction = createLocationFilterForBankTransaction(locationCode);

        // Bank filter for bank transactions
        String bankFilterBankTransaction = createBankFilterForBankTransaction(bankName);

        // Format date for SQL
        String formattedDate = dateTo;

        // Get bank details
        List<ResponseBankDetailsDTO> bankDetails = getBankDetailsData(
                companyId,
                locationFilter,
                bankFilter,
                formattedDate
        );

        // Get bank summary
        ResponseBankSummaryDTO summary = getBankSummary(
                companyId,
                locationFilterBankTransaction,
                bankFilterBankTransaction
        );

        // Create response
        ResponseBankDTO response = new ResponseBankDTO();
        response.setBankDetails(bankDetails);
        response.setResponseBankSummaryDTO(summary);

        return response;
    }

    private String createLocationFilter(String locationCode) {
        if ("All".equals(locationCode)) {
            return "";
        } else {
            return "AND tbl_BankDet.LocaCode='" + locationCode + "'";
        }
    }

    private String createBankFilter(String bankName) {
        if ("All".equals(bankName)) {
            return "";
        } else {
            return "AND (tbl_BankDet.BnkName = '" + bankName + "' ) ";
        }
    }

    private String createLocationFilterForBankTransaction(String locationCode) {
        if ("All".equals(locationCode)) {
            return "";
        } else {
            return "AND tbl_BankTransaction.LocaCode='" + locationCode + "'";
        }
    }

    private String createBankFilterForBankTransaction(String bankName) {
        if ("All".equals(bankName)) {
            return "";
        } else {
            return "AND (tbl_BankTransaction.BnkName = '" + bankName + "' ) ";
        }
    }

    private List<ResponseBankDetailsDTO> getBankDetailsData(String companyId, String locationFilter, String bankFilter, String dateTo) {
        String sql = "SELECT " +
                "(CASE WHEN AcNo='XXXX-XXXX-XXXX-XXXX' THEN BnkName ELSE (BnkName+'-'+AcNo) END) AS BankInfo, " +
                "BnkName, " +
                "(CASE WHEN AcNo='XXXX-XXXX-XXXX-XXXX' THEN '' ELSE AcNo END) AS AcNo, " +
                "AcType, BankCode, " +
                "(SELECT SUM(CreditAmount - DebitAmount) FROM tbl_BankTransaction WHERE tbl_BankDet.BnkCode = tbl_BankTransaction.BnkCode AND CompID=?) AS AmountInBank, " +
                "(SELECT SUM(PaidAmount) FROM tbl_ChqDet WHERE tbl_BankDet.BnkCode = tbl_ChqDet.BnkCode AND Status = 'PENDING' AND ChqType = 'OWN CHQ' AND ChqDate<=? AND CompID=?) AS CHQPayableToday, " +
                "(SELECT SUM(PaidAmount) FROM tbl_ChqDet WHERE tbl_BankDet.BnkCode = tbl_ChqDet.BnkCode AND Status = 'PENDING' AND ChqType = 'OWN CHQ' AND CompID=?) AS CHQPayableTotal, " +
                "((SELECT SUM(CreditAmount - DebitAmount) FROM tbl_BankTransaction WHERE tbl_BankDet.BnkCode = tbl_BankTransaction.BnkCode AND CompID=?)- " +
                "(SELECT SUM(PaidAmount) FROM tbl_ChqDet WHERE tbl_BankDet.BnkCode = tbl_ChqDet.BnkCode AND Status = 'PENDING' AND ChqType = 'OWN CHQ' AND ChqDate<=? AND CompID=?)) AS AmountShortAccessToday, " +
                "((SELECT SUM(CreditAmount - DebitAmount) FROM tbl_BankTransaction WHERE tbl_BankDet.BnkCode = tbl_BankTransaction.BnkCode AND CompID=?)- " +
                "(SELECT SUM(PaidAmount) FROM tbl_ChqDet WHERE tbl_BankDet.BnkCode = tbl_ChqDet.BnkCode AND Status = 'PENDING' AND ChqType = 'OWN CHQ' AND CompID=?)) AS AmountShortAccessTotal " +
                "FROM tbl_BankDet WHERE tbl_BankDet.CompID=? " + locationFilter + " " + bankFilter;

        return jdbcTemplate.query(sql, new BankDetailsRowMapper(),
                companyId, dateTo, companyId, companyId, companyId, dateTo, companyId,
                companyId, companyId, companyId);
    }

    private ResponseBankSummaryDTO getBankSummary(String companyId, String locationFilter, String bankFilter) {
        String sql = "SELECT SUM(CreditAmount - DebitAmount) AS TotalBankBalance " +
                "FROM tbl_BankTransaction " +
                "WHERE tbl_BankTransaction.CompID=? " + locationFilter + " " + bankFilter;

        return jdbcTemplate.queryForObject(sql, new BankSummaryRowMapper(), companyId);
    }

    private static class BankDetailsRowMapper implements RowMapper<ResponseBankDetailsDTO> {
        @Override
        public ResponseBankDetailsDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            ResponseBankDetailsDTO bank = new ResponseBankDetailsDTO();
            bank.setBankInfo(rs.getString("BankInfo"));
            bank.setBnkName(rs.getString("BnkName"));
            bank.setAcNo(rs.getString("AcNo"));
            bank.setAcType(rs.getString("AcType"));
            bank.setBankCode(rs.getString("BankCode"));

            // Handle possible NULL values from database
            double amountInBank = rs.getDouble("AmountInBank");
            bank.setAmountInBank(amountInBank);


            BigDecimal chqPayableToday = rs.getBigDecimal("CHQPayableToday");
            bank.setChqPayableToday(chqPayableToday != null ? chqPayableToday : BigDecimal.ZERO);

            BigDecimal chqPayableTotal = rs.getBigDecimal("CHQPayableTotal");
            bank.setChqPayableTotal(chqPayableTotal != null ? chqPayableTotal : BigDecimal.ZERO);

            BigDecimal amountShortAccessToday = rs.getBigDecimal("AmountShortAccessToday");
            bank.setAmountShortAccessToday(amountShortAccessToday != null ? amountShortAccessToday : BigDecimal.ZERO);

            BigDecimal amountShortAccessTotal = rs.getBigDecimal("AmountShortAccessTotal");
            bank.setAmountShortAccessTotal(amountShortAccessTotal != null ? amountShortAccessTotal : BigDecimal.ZERO);

            return bank;
        }
    }

    private static class BankSummaryRowMapper implements RowMapper<ResponseBankSummaryDTO> {
        @Override
        public ResponseBankSummaryDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            ResponseBankSummaryDTO summary = new ResponseBankSummaryDTO();
            BigDecimal totalBalance = rs.getBigDecimal("TotalBankBalance");
            summary.setTotalBankBalance(totalBalance != null ? totalBalance : BigDecimal.ZERO);
            return summary;
        }
    }


}
