package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.AccountQueryService;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class AccountQueryServiceImpl implements AccountQueryService {
    private final JdbcTemplate jdbcTemplate;
    private final CompanyUserService companyUserService;

    private String companyId(String token) throws SQLException {
        return companyUserService.getUserAllData(token).getCompanyId();
    }

    private List<Map<String, Object>> safeQuery(String sql, Object... args) {
        try {
            return jdbcTemplate.query(sql, new ColumnMapRowMapper(), args);
        } catch (Exception e) {
            log.warn("AccountQuery SQL failed: {} args={} error={}", sql.substring(0, Math.min(80, sql.length())), args, e.getMessage());
            return Collections.emptyList();
        }
    }

    private Map<String, Object> safeQueryForObject(String sql, Object... args) {
        try {
            return jdbcTemplate.queryForObject(sql, new ColumnMapRowMapper(), args);
        } catch (Exception e) {
            log.warn("AccountQuery single-row SQL failed: {} args={} error={}", sql.substring(0, Math.min(80, sql.length())), args, e.getMessage());
            Map<String, Object> empty = new HashMap<>();
            empty.put("totalCredit", 0);
            empty.put("totalDebit", 0);
            empty.put("totalBalance", 0);
            return empty;
        }
    }

    @Override
    public List<Map<String, Object>> getAssetLedger(String filters, String token) throws SQLException {
        String sql = "SELECT * FROM tbl_AssetDet WHERE CompID=? AND " + filters;
        return safeQuery(sql, companyId(token));
    }

    @Override
    public List<Map<String, Object>> getAssetBreakdown(String filters, String token) throws SQLException {
        String sql = "SELECT AcName, COALESCE(SUM(CreditAmount),0) AS totalCredit, COALESCE(SUM(DebitAmount),0) AS totalDebit, COALESCE(SUM(DebitAmount-CreditAmount),0) AS balanceAmount FROM tbl_AssetDet WHERE CompID=? AND " + filters + " GROUP BY AcName";
        return safeQuery(sql, companyId(token));
    }

    @Override
    public Map<String, Object> getAssetSummary(String filters, String token) throws SQLException {
        String sql = "SELECT COALESCE(SUM(CreditAmount),0) AS totalCredit, COALESCE(SUM(DebitAmount),0) AS totalDebit, COALESCE(SUM(DebitAmount-CreditAmount),0) AS totalBalance FROM tbl_AssetDet WHERE CompID=? AND " + filters;
        return safeQueryForObject(sql, companyId(token));
    }

    @Override
    public List<Map<String, Object>> getCapitalLedger(String filters, String token) throws SQLException {
        String sql = "SELECT * FROM tbl_CapitalACDet WHERE CompID=? AND " + filters;
        return safeQuery(sql, companyId(token));
    }

    @Override
    public List<Map<String, Object>> getCapitalBreakdown(String filters, String token) throws SQLException {
        String sql = "SELECT AcName, COALESCE(SUM(CASE WHEN ID='CA' THEN CreditAmount-DebitAmount ELSE 0 END),0) AS ca, COALESCE(SUM(CASE WHEN ID='CAC' THEN CreditAmount-DebitAmount ELSE 0 END),0) AS cac, COALESCE(SUM(CASE WHEN ID='DA' THEN DebitAmount-CreditAmount ELSE 0 END),0) AS da, COALESCE(SUM(CASE WHEN ID='CA' OR ID='CAC' THEN CreditAmount-DebitAmount ELSE 0 END),0) AS caTotal FROM tbl_CapitalACDet WHERE CompID=? AND " + filters + " GROUP BY AcName";
        return safeQuery(sql, companyId(token));
    }

    @Override
    public Map<String, Object> getCapitalSummary(String filters, String token) throws SQLException {
        String sql = "SELECT COALESCE(SUM(CreditAmount),0) AS totalCredit, COALESCE(SUM(DebitAmount),0) AS totalDebit, COALESCE(SUM(CASE WHEN ID='DA' THEN DebitAmount-CreditAmount ELSE CreditAmount-DebitAmount END),0) AS totalBalance FROM tbl_CapitalACDet WHERE CompID=? AND " + filters;
        return safeQueryForObject(sql, companyId(token));
    }

    @Override
    public void adjustCardBalance(Map<String, Object> body, String token) throws SQLException {
        String acCode = (String) body.get("acCode");
        String acName = (String) body.get("acName");
        double adjustAmount = Double.parseDouble(body.get("adjustAmount").toString());
        String remark = (String) body.get("remark");
        double deductionRate = body.containsKey("deductionRate")
            ? Double.parseDouble(body.get("deductionRate").toString()) : 0;
        String cid = companyId(token);

        List<Map<String, Object>> account = jdbcTemplate.query(
            "SELECT LocaCode, BalanceAmount FROM tbl_CardAccount WHERE CompID=? AND AcCode=?",
            new ColumnMapRowMapper(), cid, acCode
        );
        if (account.isEmpty()) return;

        String locaCode = account.get(0).get("LocaCode").toString();
        double currentBalance = ((Number) account.get(0).get("BalanceAmount")).doubleValue();
        double newBalance = currentBalance + adjustAmount;

        if (adjustAmount != 0) {
            jdbcTemplate.update(
                "INSERT INTO tbl_CardAccountLedger (CompID,LocaCode,UnitNo,SerialNo,InvoiceNo,ID,AcCode,AcName," +
                "CreditAmount,Debitamount,BalanceAmount,InvoiceDescription,CreateDate,CreateTime,CreateBy,ServerUpdateStatus) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,CONVERT(date,GETDATE()),CONVERT(time,GETDATE()),?,?)",
                cid, locaCode, "", "00001", "00001", "INV", acCode, acName,
                adjustAmount > 0 ? adjustAmount : 0, adjustAmount < 0 ? -adjustAmount : 0,
                newBalance, "Card Balance Adjustment - " + remark, "", "PENDING"
            );
        }

        jdbcTemplate.update(
            "UPDATE tbl_CardAccount SET BalanceAmount=BalanceAmount+?, DeductionRate=?, ServerUpdateStatus='MODIFIED' WHERE CompID=? AND AcCode=?",
            adjustAmount, deductionRate, cid, acCode
        );
    }

    @Override
    public List<Map<String, Object>> getCardAccounts(String filters, String token) throws SQLException {
        String cid = companyId(token);
        String sql = "SELECT * FROM tbl_CardAccount WHERE CompID=? AND LocaCode<>''";
        if (filters != null && !filters.isEmpty()) {
            sql += " " + filters;
        }
        sql += " ORDER BY AcName ASC";
        return safeQuery(sql, cid);
    }

    @Override
    public List<Map<String, Object>> getCardLedger(String filters, String token) throws SQLException {
        String cid = companyId(token);
        String sql = "SELECT * FROM tbl_CardAccountLedger WHERE CompID=? AND " + filters;
        return safeQuery(sql, cid);
    }

    @Override
    public List<Map<String, Object>> getCashAccounts(String filters, String token) throws SQLException {
        if (filters != null && !filters.isEmpty()) {
            String sql = "SELECT * FROM tbl_CashAccount WHERE CompID=? AND " + filters;
            return safeQuery(sql, companyId(token));
        }
        String sql = "SELECT * FROM tbl_CashAccount WHERE CompID=? ORDER BY BalanceAmount DESC";
        return safeQuery(sql, companyId(token));
    }

    @Override
    public List<Map<String, Object>> getCashLedger(String filters, String token) throws SQLException {
        String cid = companyId(token);
        String sql = "SELECT * FROM tbl_CashAccountLedger WHERE CompID=? AND " + filters;
        return safeQuery(sql, cid);
    }

    @Override
    public List<Map<String, Object>> getLiabilityLedger(String filters, String token) throws SQLException {
        String sql = "SELECT * FROM tbl_LiabilityDet WHERE CompID=? AND " + filters;
        return safeQuery(sql, companyId(token));
    }

    @Override
    public List<Map<String, Object>> getLiabilityBreakdown(String filters, String token) throws SQLException {
        String sql = "SELECT AcName, COALESCE(SUM(CreditAmount),0) AS totalCredit, COALESCE(SUM(DebitAmount),0) AS totalDebit, COALESCE(SUM(CreditAmount-DebitAmount),0) AS balanceAmount FROM tbl_LiabilityDet WHERE CompID=? AND " + filters + " GROUP BY AcName";
        return safeQuery(sql, companyId(token));
    }

    @Override
    public Map<String, Object> getLiabilitySummary(String filters, String token) throws SQLException {
        String sql = "SELECT COALESCE(SUM(CreditAmount),0) AS totalCredit, COALESCE(SUM(DebitAmount),0) AS totalDebit, COALESCE(SUM(CreditAmount-DebitAmount),0) AS totalBalance FROM tbl_LiabilityDet WHERE CompID=? AND " + filters;
        return safeQueryForObject(sql, companyId(token));
    }
}
