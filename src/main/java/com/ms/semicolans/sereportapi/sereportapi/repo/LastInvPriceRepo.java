package com.ms.semicolans.sereportapi.sereportapi.repo;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Repository for last invoice price lookup from tbl_InvSummery and tbl_InvDet.
 * Filters by CompID from token to ensure correct company data.
 */
@RequiredArgsConstructor
@Repository
public class LastInvPriceRepo {

    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate jdbcTemplate;

    private static final RowMapper<Map<String, Object>> ROW_MAPPER = (ResultSet rs, int rowNum) -> {
        Map<String, Object> row = new HashMap<>();
        row.put("ItemDPrice", rs.getObject("ItemDPrice"));
        row.put("Qty", rs.getObject("Qty"));
        return row;
    };

    /**
     * Get last invoice price and qty when customer is selected.
     */
    public Map<String, Object> getLastInvPriceByCustomer(String cusCode, String itemCode, String barcode, String compId) {
        String sql = "SELECT TOP 1 tbl_InvDet.ItemDPrice AS ItemDPrice, tbl_InvDet.Qty AS Qty " +
                "FROM tbl_InvDet " +
                "INNER JOIN tbl_InvSummery ON tbl_InvSummery.SerialNo = tbl_InvDet.SerialNo " +
                "WHERE tbl_InvSummery.CompID = ? AND tbl_InvDet.CompID = ? " +
                "AND LEFT(tbl_InvDet.SerialNo, 8) NOT IN ('INVM-CUS', 'INVN-CUS') " +
                "AND ISNULL(tbl_InvSummery.CusCode,'') = ? " +
                "AND (RTRIM(LTRIM(ISNULL(tbl_InvDet.ItemCode,''))) = ? OR RTRIM(LTRIM(ISNULL(tbl_InvDet.ItemBarcode,''))) = ?) " +
                "ORDER BY tbl_InvDet.CreateDate DESC";
        String searchVal = (barcode != null && !barcode.isEmpty()) ? barcode.trim() : (itemCode != null ? itemCode.trim() : "");
        String itemVal = itemCode != null ? itemCode.trim() : "";
        String cusVal = cusCode != null ? cusCode : "";
        List<Map<String, Object>> rows = jdbcTemplate.query(sql, ROW_MAPPER, compId, compId, cusVal, itemVal, searchVal);
        if (!rows.isEmpty()) return rows.get(0);
        return null;
    }

    /**
     * Get last invoice price and qty when customer is NOT selected.
     * Always filters by CompID - no fallback (multiple businesses share same item codes).
     */
    public Map<String, Object> getLastInvPriceByItem(String itemCode, String barcode, String compId) {
        String searchTerm = (barcode != null && !barcode.isEmpty()) ? barcode.trim() : (itemCode != null ? itemCode.trim() : "");
        if (searchTerm.isEmpty()) return null;

        String sql = "SELECT TOP 1 tbl_InvDet.ItemDPrice AS ItemDPrice, tbl_InvDet.Qty AS Qty " +
                "FROM tbl_InvDet " +
                "INNER JOIN tbl_InvSummery ON tbl_InvSummery.SerialNo = tbl_InvDet.SerialNo " +
                "WHERE tbl_InvDet.CompID = ? AND tbl_InvSummery.CompID = ? " +
                "AND LEFT(tbl_InvDet.SerialNo, 8) NOT IN ('INVM-CUS', 'INVN-CUS') " +
                "AND (RTRIM(LTRIM(ISNULL(tbl_InvDet.ItemCode,''))) = ? OR RTRIM(LTRIM(ISNULL(tbl_InvDet.ItemBarcode,''))) = ?) " +
                "ORDER BY tbl_InvDet.CreateDate DESC";

        List<Map<String, Object>> rows = jdbcTemplate.query(sql, ROW_MAPPER, compId, compId, searchTerm, searchTerm);
        return rows.isEmpty() ? null : rows.get(0);
    }
}
