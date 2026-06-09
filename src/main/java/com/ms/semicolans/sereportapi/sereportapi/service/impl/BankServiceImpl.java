package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCommonNameAndCodeDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.bankdto.ResponseBankDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.bankdto.ResponseBankTransactionDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.bankdto.ResponseChqTransactionDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseBankDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseBankTransactionDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseChqTransactionDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.*;

@Service
@RequiredArgsConstructor
public class BankServiceImpl {

    private final CompanyUserService companyUserService;

    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate mainJdbcTemplate;

    public List<ResponseCommonNameAndCodeDTO> getBankDetails(String token) throws SQLException {
        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);

        // Query for data with pagination
        String dataSql = "SELECT * FROM tbl_BankDet WHERE CompId = ? ORDER BY tbl_BankDet.BnkName ASC;";
        Object[] dataParams = new Object[]{userAllData.getCompanyId()};

        List<ResponseCommonNameAndCodeDTO> bankDetailsList = mainJdbcTemplate.query(
                dataSql,
                dataParams,
                (rs, rowNum) -> {
                    return ResponseCommonNameAndCodeDTO.builder().name(rs.getString("BnkName")).code(rs.getString("BnkCode")).build();
                }
        );

        return bankDetailsList;
    }

    public PaginatedResponseBankDetailsDTO getBankDetailsWithSummary(
            String token, String locaCode, String bankFilter, String dateTo, int page, int size) throws SQLException {

        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();

        // Build filter conditions with parameter placeholders
        String locationFilterBankDet = "All".equals(locaCode) ? "" : "AND LocaCode = ?";
        String locationFilterBankTrans = "All".equals(locaCode) ? "" : "AND LocaCode = ?";
        String bankFilterBankDet = "All".equals(bankFilter) ? "" : "AND BnkName = ?";
        String bankFilterBankTrans = "All".equals(bankFilter) ? "" : "AND BnkName = ?";

        // Prepare parameters for main query
        List<Object> dataParams = new ArrayList<>();
        Collections.addAll(dataParams,
                companyId, dateTo, companyId, companyId, companyId, dateTo,
                companyId, companyId, companyId, companyId);

        if (!"All".equals(locaCode)) {
            dataParams.add(locaCode);
        }
        if (!"All".equals(bankFilter)) {
            dataParams.add(bankFilter);
        }
        dataParams.add(page * size);
        dataParams.add(size);

        // Main query with pagination
        String dataSql = "SELECT BankCode, BnkName, AcNo, AcType, " +
                         "(CASE WHEN AcNo='XXXX-XXXX-XXXX-XXXX' THEN BnkName ELSE (BnkName+'-'+AcNo) END) AS BankInfo, " +
                         "(SELECT SUM(CreditAmount - DebitAmount) FROM tbl_BankTransaction WHERE BnkCode = tbl_BankDet.BnkCode AND CompID=?) AS AmountInBank, " +
                         "(SELECT SUM(PaidAmount) FROM tbl_ChqDet WHERE BnkCode = tbl_BankDet.BnkCode AND Status='PENDING' AND ChqType='OWN CHQ' AND ChqDate<=? AND CompID=?) AS CHQPayableToday, " +
                         "(SELECT SUM(PaidAmount) FROM tbl_ChqDet WHERE BnkCode = tbl_BankDet.BnkCode AND Status='PENDING' AND ChqType='OWN CHQ' AND CompID=?) AS CHQPayableTotal, " +
                         "((SELECT SUM(CreditAmount - DebitAmount) FROM tbl_BankTransaction WHERE BnkCode = tbl_BankDet.BnkCode AND CompID=?) - " +
                         "(SELECT SUM(PaidAmount) FROM tbl_ChqDet WHERE BnkCode = tbl_BankDet.BnkCode AND Status='PENDING' AND ChqType='OWN CHQ' AND ChqDate<=? AND CompID=?)) AS AmountShortAccessToday, " +
                         "((SELECT SUM(CreditAmount - DebitAmount) FROM tbl_BankTransaction WHERE BnkCode = tbl_BankDet.BnkCode AND CompID=?) - " +
                         "(SELECT SUM(PaidAmount) FROM tbl_ChqDet WHERE BnkCode = tbl_BankDet.BnkCode AND Status='PENDING' AND ChqType='OWN CHQ' AND CompID=?)) AS AmountShortAccessTotal " +
                         "FROM tbl_BankDet WHERE CompID=? " + locationFilterBankDet + " " + bankFilterBankDet +
                         " ORDER BY BnkName OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        List<Object> bankDetails = mainJdbcTemplate.query(dataSql, dataParams.toArray(), (rs, rowNum) ->
                ResponseBankDetailsDTO.builder()
                        .bankInfo(rs.getString("BankInfo"))
                        .bnkName(rs.getString("BnkName"))
                        .acNo(rs.getString("AcNo"))
                        .acType(rs.getString("AcType"))
                        .bankCode(rs.getString("BankCode"))
                        .amountInBank(rs.getDouble("AmountInBank"))
                        .chqPayableToday(rs.getDouble("CHQPayableToday"))
                        .chqPayableTotal(rs.getDouble("CHQPayableTotal"))
                        .amountShortAccessToday(rs.getObject("AmountShortAccessToday", Double.class))
                        .amountShortAccessTotal(rs.getObject("AmountShortAccessTotal", Double.class))
                        .build()
        );

        // Prepare parameters for count query
        List<Object> countParams = new ArrayList<>();
        countParams.add(companyId);
        if (!"All".equals(locaCode)) {
            countParams.add(locaCode);
        }
        if (!"All".equals(bankFilter)) {
            countParams.add(bankFilter);
        }

        // Count query
        String countSql = "SELECT COUNT(*) FROM tbl_BankDet WHERE CompID=? " + locationFilterBankDet + " " + bankFilterBankDet;
        Long totalCount = mainJdbcTemplate.queryForObject(countSql, countParams.toArray(), Long.class);

        // Prepare parameters for summary query
        List<Object> summaryParams = new ArrayList<>();
        summaryParams.add(companyId);
        if (!"All".equals(locaCode)) {
            summaryParams.add(locaCode);
        }
        if (!"All".equals(bankFilter)) {
            summaryParams.add(bankFilter);
        }

        // Bank Balance Summary query
        String balanceSql = "SELECT SUM(CreditAmount - DebitAmount) AS TotalBankBalance " +
                            "FROM tbl_BankTransaction WHERE CompID=? " + locationFilterBankTrans + " " + bankFilterBankTrans;
        Double totalBankBalance = mainJdbcTemplate.queryForObject(balanceSql, summaryParams.toArray(), Double.class);

        return PaginatedResponseBankDetailsDTO.builder()
                .count(totalCount)
                .data(bankDetails)
                .totalBankBalance(totalBankBalance != null ? totalBankBalance : 0.0)
                .build();
    }

    public PaginatedResponseBankTransactionDTO getBankTransactions(
            String token,
            String locaCode,
            String bank,
            LocalDate dateFrom,
            LocalDate dateTo,
            String searchText,
            int page,
            int size) throws SQLException {

        System.out.println(searchText);

        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();

        // Build filter conditions with parameters
        List<String> whereClauses = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        whereClauses.add("CompID = ?");
        params.add(companyId.trim());

        // Location filter
        if (!locaCode.isEmpty() && !"All".equals(locaCode)) {
            whereClauses.add("LocaCode = ?");
            params.add(locaCode);
        }

        // Bank filter
        if (!bank.isEmpty() && !"All".equals(bank)) {
            whereClauses.add("BnkName = ?");
            params.add(bank);
        }

        // Date filter
        if (dateFrom != null && dateTo != null) {
            whereClauses.add("CreateDate BETWEEN ? AND ?");
            params.add(dateFrom);
            params.add(dateTo);
        }

        // Reference filter
        if (searchText != null && !searchText.isEmpty()) {
            String searchPattern = "%" + searchText + "%";
            whereClauses.add("(TranNo LIKE ? OR SerialNo LIKE ? OR VenName LIKE ? OR InvoiceDescription LIKE ?)");
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        String whereClause = String.join(" AND ", whereClauses);

        // Main query with pagination - updated to match ResponseBankTransactionDTO fields
        String dataSql = "SELECT CreateDate, SerialNo, TranType, PayMode, ID, BnkCode, " +
                         "BnkName, BranchName, AcType, TranNo, CreditAmount, DebitAmount, " +
                         "(CreditAmount - DebitAmount) AS TotalAmount, VenName, Status, " +
                         "InvoiceDescription, VenCode, CreateBy " +
                         "FROM tbl_BankTransaction " +
                         "WHERE " + whereClause + " " +
                         "ORDER BY RowNo DESC " +
                         "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        // Add pagination parameters
        List<Object> dataParams = new ArrayList<>(params);
        dataParams.add(page * size);
        dataParams.add(size);

        List<ResponseBankTransactionDTO> transactions = mainJdbcTemplate.query(dataSql, dataParams.toArray(), (rs, rowNum) ->
                ResponseBankTransactionDTO.builder()
                        .createDate(rs.getDate("CreateDate") != null ? rs.getDate("CreateDate").toLocalDate() : null)
                        .serialNo(rs.getString("SerialNo"))
                        .tranType(rs.getString("TranType"))
                        .payMode(rs.getString("PayMode"))
                        .id(rs.getString("ID"))
                        .bnkCode(rs.getString("BnkCode"))
                        .bnkName(rs.getString("BnkName"))
                        .branchName(rs.getString("BranchName"))
                        .acType(rs.getString("AcType"))
                        .tranNo(rs.getString("TranNo"))
                        .creditAmount(rs.getDouble("CreditAmount"))
                        .debitAmount(rs.getDouble("DebitAmount"))
                        .totalAmount(rs.getDouble("TotalAmount"))
                        .venName(rs.getString("VenName"))
                        .status(rs.getString("Status"))
                        .invoiceDescription(rs.getString("InvoiceDescription"))
                        .venCode(rs.getString("VenCode"))
                        .createBy(rs.getString("CreateBy"))
                        .build()
        );

        // Count query
        String countSql = "SELECT COUNT(*) FROM tbl_BankTransaction WHERE " + whereClause;
        Long totalCount = mainJdbcTemplate.queryForObject(countSql, params.toArray(), Long.class);

        // Bank balance calculation
        String balanceSql = "SELECT SUM(CreditAmount - DebitAmount) AS bankBalance " +
                            "FROM tbl_BankTransaction WHERE " + whereClause;
        Double bankBalance = mainJdbcTemplate.queryForObject(balanceSql, params.toArray(), Double.class);

        // Summary calculation (deposits and withdrawals)
        String summarySql = "SELECT SUM(CreditAmount) AS totalDeposits, SUM(DebitAmount) AS totalWithdrawals " +
                            "FROM tbl_BankTransaction WHERE " + whereClause;

        Map<String, Double> summary = mainJdbcTemplate.queryForObject(summarySql, params.toArray(), (rs, rowNum) -> {
            Map<String, Double> result = new HashMap<>();
            result.put("totalDeposits", rs.getDouble("totalDeposits"));
            result.put("totalWithdrawals", rs.getDouble("totalWithdrawals"));
            return result;
        });

        return PaginatedResponseBankTransactionDTO.builder()
                .count(totalCount)
                .data(transactions)
                .bankBalance(bankBalance != null ? bankBalance : 0.0)
                .totalDeposits(summary.get("totalDeposits"))
                .totalWithdrawals(summary.get("totalWithdrawals"))
                .build();
    }

    public PaginatedResponseChqTransactionDTO getChqTransactionDetails(
            String token, String locaCode, String bankName, Boolean dateFilter,
            String dateTo, String searchRef, String searchChqNo, String chqType,
            int page, int size) throws SQLException {

        // Get user data and company ID from token
        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();

        // Build filter conditions with parameter placeholders
        StringBuilder filterConditions = new StringBuilder();
        filterConditions.append("WHERE Status='PENDING' AND CompID=? ");

        // Location filter
        String locationFilter = "All".equals(locaCode) ? "" : "AND tbl_ChqDet.LocaCode=? ";
        filterConditions.append(locationFilter);

        // Bank filter
        String bankFilter = "All".equals(bankName) ? "" : "AND tbl_ChqDet.BnkName=? ";
        filterConditions.append(bankFilter);

        // Date filter
        String dateFilterStr = (dateFilter != null && dateFilter && dateTo != null && !dateTo.isEmpty()) ?
                "AND tbl_ChqDet.ChqDate<=? " : "";
        filterConditions.append(dateFilterStr);

        // Reference filter
        String refFilter = (searchRef != null && !searchRef.isEmpty()) ?
                "AND (tbl_ChqDet.ChqNo LIKE ? OR tbl_ChqDet.VenName LIKE ? " +
                "OR tbl_ChqDet.VenNameChqFrom LIKE ? OR tbl_ChqDet.InvoiceDescriptionChqFrom LIKE ?) " : "";
        filterConditions.append(refFilter);

        // Cheque number filter
        String chqNoFilter = (searchChqNo != null && !searchChqNo.isEmpty()) ? "AND tbl_ChqDet.ChqNo=? " : "";
        filterConditions.append(chqNoFilter);

        // Cheque type filter
        String typeFilter = "";
        if (!"All".equals(chqType)) {
            if ("Payable".equals(chqType)) {
                typeFilter = "AND tbl_ChqDet.ChqType='OWN CHQ' AND tbl_ChqDet.Status<>'UNKNOWN' ";
            } else if ("Receivable".equals(chqType)) {
                typeFilter = "AND tbl_ChqDet.ChqType='RECIEVED CHQ' AND tbl_ChqDet.Status<>'UNKNOWN' ";
            } else if ("Party CHQ".equals(chqType)) {
                typeFilter = "AND tbl_ChqDet.ChqType='PARTY CHQ' AND tbl_ChqDet.Status<>'UNKNOWN' ";
            }
        }
        filterConditions.append(typeFilter);

        // Prepare parameters for main query
        List<Object> dataParams = new ArrayList<>();
        dataParams.add(companyId);

        if (!"All".equals(locaCode)) {
            dataParams.add(locaCode);
        }

        if (!"All".equals(bankName)) {
            dataParams.add(bankName);
        }

        if (dateFilter != null && dateFilter && dateTo != null && !dateTo.isEmpty()) {
            dataParams.add(dateTo);
        }

        if (searchRef != null && !searchRef.isEmpty()) {
            String searchPattern = "%" + searchRef + "%";
            dataParams.add(searchPattern);
            dataParams.add(searchPattern);
            dataParams.add(searchPattern);
            dataParams.add(searchPattern);
        }

        if (searchChqNo != null && !searchChqNo.isEmpty()) {
            dataParams.add(searchChqNo);
        }

        // Add pagination parameters
        dataParams.add(page * size);
        dataParams.add(size);

        // Main query with pagination
        String transactionSql = "SELECT SerialNo, InvoiceNo, ID, ChqNo, Status, PaidAmount, ChqDate, ChqType, " +
                                "VenName, VenNameChqFrom, TransactionType, BnkCode, BnkName, BranchName, AcType, CreateDate, CreateBy, " +
                                "VenCode, InvoiceDescription, SerialNoChqFrom, VenCodeChqFrom, VenNameChqFrom, " +
                                "InvoiceDescriptionChqFrom, IDChqFrom, ReferenceNo " +
                                "FROM tbl_ChqDet " +
                                filterConditions +
                                "ORDER BY ChqDate ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        List<ResponseChqTransactionDTO> transactions = mainJdbcTemplate.query(transactionSql, dataParams.toArray(), (rs, rowNum) ->
                ResponseChqTransactionDTO.builder()
                        .serialNo(rs.getString("SerialNo"))
                        .invoiceNo(rs.getString("InvoiceNo"))
                        .id(rs.getString("ID"))
                        .chqNo(rs.getString("ChqNo"))
                        .status(rs.getString("Status"))
                        .paidAmount(rs.getDouble("PaidAmount"))
                        .chqDate(rs.getDate("ChqDate") != null ? rs.getDate("ChqDate").toLocalDate() : null)
                        .chqType(rs.getString("ChqType"))
                        .venName(rs.getString("VenName"))
                        .venNameChqFrom(rs.getString("VenNameChqFrom"))
                        .transactionType(rs.getString("TransactionType"))
                        .bnkCode(rs.getString("BnkCode"))
                        .bnkName(rs.getString("BnkName"))
                        .branchName(rs.getString("BranchName"))
                        .acType(rs.getString("AcType"))
                        .createDate(rs.getDate("CreateDate") != null ? rs.getDate("CreateDate").toLocalDate() : null)
                        .createBy(rs.getString("CreateBy"))
                        .venCode(rs.getString("VenCode"))
                        .invoiceDescription(rs.getString("InvoiceDescription"))
                        .serialNoChqFrom(rs.getString("SerialNoChqFrom"))
                        .venCodeChqFrom(rs.getString("VenCodeChqFrom"))
                        .invoiceDescriptionChqFrom(rs.getString("InvoiceDescriptionChqFrom"))
                        .idChqFrom(rs.getObject("IDChqFrom") != null ?
                                (rs.getString("IDChqFrom") != null && !rs.getString("IDChqFrom").isEmpty() ?
                                        rs.getLong("IDChqFrom") : null) :
                                null)
                        .referenceNo(rs.getString("ReferenceNo"))
                        .build()
        );

        // Prepare parameters for count query
        List<Object> countParams = new ArrayList<>(dataParams);
        countParams.remove(countParams.size() - 1);
        countParams.remove(countParams.size() - 1);

        // Count query
        String countSql = "SELECT COUNT(*) FROM tbl_ChqDet " + filterConditions;
        Long totalCount = mainJdbcTemplate.queryForObject(countSql, countParams.toArray(), Long.class);

        // Prepare parameters for summary queries (same as count params)
        List<Object> summaryParams = new ArrayList<>(countParams);

        // Payable amount query
        String payableConditions = filterConditions.toString().replace("WHERE ", "WHERE ChqType='OWN CHQ' AND Status<>'UNKNOWN' AND ");
        String payableSql = "SELECT SUM(PaidAmount) AS PayableAmount FROM tbl_ChqDet " + payableConditions;
        Double payableAmount = mainJdbcTemplate.queryForObject(payableSql, summaryParams.toArray(), (rs, rowNum) ->
                rs.getObject("PayableAmount") != null ? rs.getDouble("PayableAmount") : 0.0
        );

        // Receivable amount query
        String receivableConditions = filterConditions.toString().replace("WHERE ", "WHERE ChqType='RECIEVED CHQ' AND Status<>'UNKNOWN' AND ");
        String receivableSql = "SELECT SUM(PaidAmount) AS ReceivableAmount FROM tbl_ChqDet " + receivableConditions;
        Double receivableAmount = mainJdbcTemplate.queryForObject(receivableSql, summaryParams.toArray(), (rs, rowNum) ->
                rs.getObject("ReceivableAmount") != null ? rs.getDouble("ReceivableAmount") : 0.0
        );

        // Party cheque amount query
        String partyChqConditions = filterConditions.toString().replace("WHERE ", "WHERE ChqType='PARTY CHQ' AND Status<>'UNKNOWN' AND ");
        String partyChqSql = "SELECT SUM(PaidAmount) AS PartyChqAmount FROM tbl_ChqDet " + partyChqConditions;
        Double partyChqAmount = mainJdbcTemplate.queryForObject(partyChqSql, summaryParams.toArray(), (rs, rowNum) ->
                rs.getObject("PartyChqAmount") != null ? rs.getDouble("PartyChqAmount") : 0.0
        );

        return PaginatedResponseChqTransactionDTO.builder()
                .count(totalCount)
                .data(transactions)
                .payableAmount(payableAmount != null ? payableAmount : 0.0)
                .receivableAmount(receivableAmount != null ? receivableAmount : 0.0)
                .partyChqAmount(partyChqAmount != null ? partyChqAmount : 0.0)
                .build();
    }



}
