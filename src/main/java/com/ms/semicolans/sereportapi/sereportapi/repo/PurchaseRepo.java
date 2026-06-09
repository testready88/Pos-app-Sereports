package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponsePurchaseSummaryDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


@RequiredArgsConstructor
@Repository
public class PurchaseRepo {
    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate jdbcTemplate;

    public ResponsePurchaseSummaryDTO getPurchaseSummary(String dateFrom, String dateTo, String locationCode, String companyId) {
        // Get Purchase Details
        String detailsSql = "SELECT " +
                "COALESCE(SUM((tbl_PurDet.Qty + tbl_PurDet.FreeQty)), 0) AS totalQtyPur, " +
                "COALESCE(SUM((tbl_PurDet.Qty + tbl_PurDet.FreeQty) * tbl_PurDet.ItemSPrice), 0) AS grossPurchase, " +
                "COALESCE(SUM((tbl_PurDet.Qty + tbl_PurDet.FreeQty) * (tbl_PurDet.ItemSPrice - tbl_PurDet.ItemUPrice)), 0) AS itemDiscountPur, " +
                "COALESCE(SUM((tbl_PurDet.Qty + tbl_PurDet.FreeQty) * tbl_PurDet.ItemUPrice), 0) AS netPurchase " +
                "FROM tbl_PurDet " +
                "INNER JOIN tbl_PurSummery ON tbl_PurSummery.SerialNo = tbl_PurDet.SerialNo " +
                "WHERE LEFT(tbl_PurDet.SerialNo, 8) NOT IN ('PCHM-SUP', 'PCHN-SUP') " +
                "AND tbl_PurDet.CreateDate BETWEEN ? AND ? " +
                "AND tbl_PurDet.CompID = ? AND tbl_PurSummery.CompID = ? " +
                buildLocationFilter(locationCode, "tbl_PurDet");

        List<Object> params = new ArrayList<>();
        params.add(dateFrom);
        params.add(dateTo);
        params.add(companyId);
        params.add(companyId);
        if (!locationCode.equals("All")) {
            params.add(locationCode);
        }

        ResponsePurchaseSummaryDTO dto = jdbcTemplate.queryForObject(detailsSql, params.toArray(), new PurchaseSummaryRowMapper());

        // Get Purchase Payment Details
        String paymentSql = "SELECT " +
                "COALESCE(SUM(tbl_PurSummery.DiscountForTot), 0) AS cashDiscountPur, " +
                "COALESCE(SUM(tbl_PurSummery.OtherPaid), 0) AS advancePaymentPur, " +
                "COALESCE(SUM(tbl_PurSummery.CHQPaid), 0) AS chqPaymentPur, " +
                "COALESCE(SUM(tbl_PurSummery.CardPaid), 0) AS cardPaymentPur, " +
                "COALESCE(SUM(tbl_PurSummery.IDueAmount), 0) AS creditPaymentPur, " +
                "COALESCE(SUM(tbl_PurSummery.CashPaid), 0) AS cashPaymentPur, " +
                "COALESCE(SUM(tbl_PurSummery.ServiceCharge1), 0) AS transportCharge, " +
                "COALESCE(SUM(tbl_PurSummery.ServiceCharge2), 0) AS labourCharge " +
                "FROM tbl_PurSummery " +
                "WHERE LEFT(tbl_PurSummery.SerialNo, 8) NOT IN ('PCHM-SUP', 'PCHN-SUP') " +
                "AND tbl_PurSummery.CreateDate BETWEEN ? AND ? " +
                "AND tbl_PurSummery.CompID = ? " +
                buildLocationFilter(locationCode, "tbl_PurSummery");
        List<Object> paramsPayment = new ArrayList<>();
        paramsPayment.add(dateFrom);
        paramsPayment.add(dateTo);
        paramsPayment.add(companyId);
        if (!locationCode.equals("All")) {
            paramsPayment.add(locationCode);
        }
        jdbcTemplate.query(paymentSql, paramsPayment.toArray(), rs -> {
            double transportCharge = rs.getDouble("transportCharge");
            double labourCharge = rs.getDouble("labourCharge");
            double cashDiscountPur = rs.getDouble("cashDiscountPur");

            dto.setCashDiscountPur(cashDiscountPur);
            dto.setTransportCharge(transportCharge);
            dto.setLabourCharge(labourCharge);

            // Recalculate netPurchase with charges and discounts
            dto.setNetPurchase(
                    dto.getNetPurchase() + transportCharge + labourCharge - cashDiscountPur
            );
        });

        return dto;
    }

    private static class PurchaseSummaryRowMapper implements RowMapper<ResponsePurchaseSummaryDTO> {
        @Override
        public ResponsePurchaseSummaryDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            return ResponsePurchaseSummaryDTO.builder()
                    .totalQtyPur(rs.getDouble("totalQtyPur"))
                    .grossPurchase(rs.getDouble("grossPurchase"))
                    .itemDiscountPur(rs.getDouble("itemDiscountPur"))
                    .netPurchase(rs.getDouble("netPurchase"))
                    .build();
        }
    }



    private String buildLocationFilter(String locationCode, String tableName) {
        return locationCode.equals("All") ? "" : " AND " + tableName + ".LocaCode = ?";
    }
}