package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseBalanceSheetDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;

@RequiredArgsConstructor
@Repository
public class BalanceSheetRepo {
    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate jdbcTemplate;

    public ResponseBalanceSheetDTO getBalanceSheet(String companyId, String locationCode) {
        ResponseBalanceSheetDTO dto = new ResponseBalanceSheetDTO();

        // Cash in Hand
        dto.setCashInHand(getCashInHand(companyId, locationCode));

        // Amount in Bank
        dto.setAmountInBank(getAmountInBank(companyId, locationCode));

        // Inventory (from stock summary)
        dto.setInventory(getInventory(companyId, locationCode));

        // Amount Receivable
        dto.setAmountReceivable(getAmountReceivable(companyId, locationCode));

        // CHQ Receivable
        dto.setChqReceivable(getChqReceivable(companyId, locationCode));

        // Amount Payable
        dto.setAmountPayable(getAmountPayable(companyId, locationCode));

        // CHQ Payable
        dto.setChqPayable(getChqPayable(companyId, locationCode));

        // Other Current Assets
        dto.setOtherCurrentAsset(getOtherCurrentAssets(companyId, locationCode));

        // Advance Received
        dto.setAdvanceReceived(getAdvanceReceived(companyId, locationCode));

        // Fixed Assets
        dto.setTotalFixedAssets(getFixedAssets(companyId, locationCode));

        // Capital
        dto.setCapital(getCapital(companyId, locationCode));

        // Calculate totals
        calculateTotals(dto);

        return dto;
    }

    private double getCashInHand(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(BalanceAmount), 0) AS cashInHand " +
                "FROM tbl_CashAccount " +
                "WHERE CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private double getAmountInBank(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(CreditAmount - DebitAmount), 0) AS amountInBank " +
                "FROM tbl_BankTransaction " +
                "WHERE Status = 'SUCCESS' AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private double getInventory(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(tbl_PriceLink1.QtyRemain * tbl_PriceLink1.ItemUPrice), 0) AS inventory " +
                "FROM tbl_PriceLink1 " +
                "INNER JOIN tbl_ItemDet ON tbl_PriceLink1.ItemCode = tbl_ItemDet.ItemCode " +
                "AND tbl_PriceLink1.LocaCode = tbl_ItemDet.LocaCode " +
                "WHERE tbl_PriceLink1.ItemUPrice > 0 AND tbl_ItemDet.chkActiveItem = '1' " +
                "AND tbl_ItemDet.ActiveItem = '1' AND tbl_ItemDet.ItemCatCode <> 'CAT-11-000000' " +
                "AND tbl_ItemDet.CompID = ? AND tbl_PriceLink1.CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private double getAmountReceivable(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(OpeningBalance + DueAmount + CreditAdjust - DebitAdjust - AdvanceAmount), 0) AS amountReceivable " +
                "FROM tbl_CusDet WHERE ActiveCustomer = '1' AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private double getChqReceivable(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(PaidAmount), 0) AS chqReceivable " +
                "FROM tbl_ChqDet " +
                "WHERE Status = 'PENDING' AND ChqType = 'RECIEVED CHQ' " +
                "AND TransactionType = 'IN HAND' AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private double getAmountPayable(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(OpeningBalance + DueAmount + CreditAdjust - DebitAdjust - AdvanceAmount), 0) AS amountPayable " +
                "FROM tbl_SupDet WHERE ActiveSupplier = '1' AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private double getChqPayable(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(PaidAmount), 0) AS chqPayable " +
                "FROM tbl_ChqDet " +
                "WHERE Status = 'PENDING' AND ChqType = 'OWN CHQ' AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private double getOtherCurrentAssets(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(DebitAmount - CreditAmount), 0) AS otherCurrentAsset " +
                "FROM tbl_AssetDet " +
                "WHERE ID = 'AST' AND Status = 'Available' AND AcMethod = 'Current' " +
                "AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private double getAdvanceReceived(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(OtherPaid), 0) AS advanceReceived " +
                "FROM tbl_QuotSummery " +
                "WHERE InvMethod = 'ADVANCE' AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private double getFixedAssets(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(DebitAmount - CreditAmount), 0) AS fixedAssets " +
                "FROM tbl_AssetDet " +
                "WHERE ID = 'AST' AND Status = 'Available' AND AcMethod = 'Fixed' " +
                "AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private double getCapital(String companyId, String locationCode) {
        String sql = "SELECT COALESCE(SUM(CreditAmount - DebitAmount), 0) AS capital " +
                "FROM tbl_CapitalACDet " +
                "WHERE ID = 'CA' AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        if (!locationCode.equals("All")) params.add(locationCode);

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private void calculateTotals(ResponseBalanceSheetDTO dto) {
        // Total Cash
        double totalCash = dto.getCashInHand() + dto.getAmountInBank();
        dto.setTotalCash(totalCash);

        // Total Current Assets
        double totalCurrentAssets = totalCash + dto.getInventory() + dto.getAmountReceivable() +
                dto.getChqReceivable() + dto.getOtherCurrentAsset();
        dto.setTotalCurrentAssets(totalCurrentAssets);

        // Total Assets
        double totalAssets = totalCurrentAssets + dto.getTotalFixedAssets();
        dto.setTotalAssets(totalAssets);

        // Total Current Liabilities
        double totalCurrentLiabilities = dto.getAmountPayable() + dto.getChqPayable() +
                dto.getAdvanceReceived();
        dto.setTotalCurrentLiabilities(totalCurrentLiabilities);

        // Total Liabilities
        double totalLiabilities = totalCurrentLiabilities + dto.getCapital() + dto.getNetProfit();
        dto.setTotalLiabilities(totalLiabilities);

        // Assets vs Liabilities Difference
        dto.setAssetsLiabilitiesDifference(totalAssets - totalLiabilities);
    }

    private String buildLocationFilter(String locationCode) {
        return locationCode.equals("All") ? "" : " AND LocaCode = ?";
    }
}