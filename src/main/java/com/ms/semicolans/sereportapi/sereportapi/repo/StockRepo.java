package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseStockSummaryDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@RequiredArgsConstructor
@Repository
public class StockRepo {
    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate jdbcTemplate;

    public ResponseStockSummaryDTO getStockSummary(String companyId, String locationCode) {
        String sql = "SELECT " +
                "COALESCE(SUM(tbl_PriceLink1.QtyRemain), 0) AS qtyRemain, " +
                "COALESCE(SUM(tbl_PriceLink1.QtyRemain * tbl_PriceLink1.ItemUPrice), 0) AS costValue, " +
                "COALESCE(SUM(tbl_PriceLink1.QtyRemain * tbl_PriceLink1.ItemSPrice), 0) AS salesValue " +
                "FROM tbl_PriceLink1 " +
                "INNER JOIN tbl_ItemDet ON tbl_PriceLink1.ItemCode = tbl_ItemDet.ItemCode " +
                "AND tbl_PriceLink1.LocaCode = tbl_ItemDet.LocaCode " +
                "WHERE tbl_PriceLink1.ItemUPrice > 0 " +
                "AND tbl_ItemDet.chkActiveItem = '1' " +
                "AND tbl_ItemDet.ActiveItem = '1' " +
                "AND tbl_ItemDet.ItemCatCode <> 'CAT-11-000000' " +
                "AND tbl_ItemDet.CompID = ? AND tbl_PriceLink1.CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> params = new ArrayList<>();
        params.add(companyId);
        params.add(companyId);
        if (!locationCode.equals("All")) {
            params.add(locationCode);
        }

        return jdbcTemplate.queryForObject(sql, params.toArray(), new StockSummaryRowMapper());
    }

    private static class StockSummaryRowMapper implements RowMapper<ResponseStockSummaryDTO> {
        @Override
        public ResponseStockSummaryDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            return ResponseStockSummaryDTO.builder()
                    .qtyRemain(rs.getDouble("qtyRemain"))
                    .costValue(rs.getDouble("costValue"))
                    .salesValue(rs.getDouble("salesValue"))
                    .build();
        }
    }

    private String buildLocationFilter(String locationCode) {
        return locationCode.equals("All") ? "" : " AND tbl_PriceLink1.LocaCode = ?";
    }
}
