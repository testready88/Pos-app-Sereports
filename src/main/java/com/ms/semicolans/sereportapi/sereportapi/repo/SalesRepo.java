package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseSalesSummaryDTO;
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
public class SalesRepo {
    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate jdbcTemplate;

    public ResponseSalesSummaryDTO getSalesSummary(String dateFrom, String dateTo, String locationCode, String companyId) {
        // Get Sales Details
      try {
          String detailsSql = "SELECT " +
                  "COALESCE(SUM(tbl_InvDet.Qty), 0) AS totalQtySold, " +
                  "COALESCE(SUM(tbl_InvDet.Qty * tbl_InvDet.ItemSPrice), 0) AS grossSales, " +
                  "COALESCE(SUM(tbl_InvDet.Qty * (tbl_InvDet.ItemSPrice - tbl_InvDet.ItemDPrice)), 0) AS itemDiscount, " +
                  "COALESCE(SUM(tbl_InvDet.Qty * tbl_InvDet.ItemDPrice), 0) AS netSales, " +
                  "COALESCE(SUM(tbl_InvDet.Qty * ((tbl_InvDet.ItemSPrice + tbl_InvDet.ExCharges) - tbl_InvDet.ItemUPrice)), 0) AS profitBeforeDiscount, " +
                  "COALESCE(SUM(tbl_InvDet.Qty * ((tbl_InvDet.ItemDPrice + tbl_InvDet.ExCharges) - tbl_InvDet.ItemUPrice)), 0) AS profitAfterDiscount, " +
                  "COALESCE(SUM(tbl_InvDet.Qty * tbl_InvDet.ExCharges), 0) AS exCharges, " +
                  "COALESCE(SUM(tbl_InvDet.Qty * tbl_InvDet.ItemUPrice), 0) AS costSales " +
                  "FROM tbl_InvDet " +
                  "INNER JOIN tbl_InvSummery ON tbl_InvSummery.SerialNo = tbl_InvDet.SerialNo " +
                  "WHERE LEFT(tbl_InvDet.SerialNo, 8) NOT IN ('INVM-CUS', 'INVN-CUS') " +
                  "AND tbl_InvDet.CreateDate BETWEEN ? AND ? " +
                  "AND tbl_InvDet.CompID = ? AND tbl_InvSummery.CompID = ?" +
                  buildLocationFilter(locationCode, "tbl_InvSummery");

          List<Object> params = new ArrayList<>();
          params.add(dateFrom);
          params.add(dateTo);
          params.add(companyId);
          params.add(companyId);
          if (!locationCode.equals("All")) {
              params.add(locationCode);
          }

          ResponseSalesSummaryDTO dto = jdbcTemplate.queryForObject(detailsSql, params.toArray(), new SalesSummaryRowMapper());

          // Get Sales Payment Details
          String paymentSql = "SELECT " +
                  "COALESCE(SUM(tbl_InvSummery.OtherPaid), 0) AS advancePayment, " +
                  "COALESCE(SUM(tbl_InvSummery.CHQPaid), 0) AS chqPayment, " +
                  "COALESCE(SUM(tbl_InvSummery.CardPaid), 0) AS cardPayment, " +
                  "COALESCE(SUM(tbl_InvSummery.IDueAmount), 0) AS creditPayment, " +
                  "COALESCE(SUM(tbl_InvSummery.CashPaid), 0) AS cashPayment, " +
                  "COALESCE(SUM(tbl_InvSummery.CreditPay), 0) AS creditSettlement, " +
                  "COALESCE(SUM(tbl_InvSummery.DiscountForTot), 0) AS cashDiscount, " +
                  "COALESCE(SUM(tbl_InvSummery.PointsRedeem), 0) AS pointsRedeem, " +
                  "COALESCE(SUM(tbl_InvSummery.VoucherPaid), 0) AS voucherPaid " +
                  "FROM tbl_InvSummery " +
                  "WHERE LEFT(tbl_InvSummery.SerialNo, 8) NOT IN ('INVM-CUS', 'INVN-CUS') " +
                  "AND tbl_InvSummery.CreateDate BETWEEN ? AND ? " +
                  "AND tbl_InvSummery.CompID = ? " +
                  buildLocationFilter(locationCode, "tbl_InvSummery");
          List<Object> paramsPayment = new ArrayList<>();
          paramsPayment.add(dateFrom);
          paramsPayment.add(dateTo);
          paramsPayment.add(companyId);

          if (!locationCode.equals("All")) {
              paramsPayment.add(locationCode);
          }
          jdbcTemplate.query(paymentSql, paramsPayment.toArray(), rs -> {
              double cashDiscount = rs.getDouble("cashDiscount");
              double pointsRedeem = rs.getDouble("pointsRedeem");

              dto.setCashPayment(rs.getDouble("cashPayment"));
              dto.setCreditPayment(rs.getDouble("creditPayment"));
              dto.setCardPayment(rs.getDouble("cardPayment"));
              dto.setChqPayment(rs.getDouble("chqPayment"));
              dto.setCashDiscount(cashDiscount);
              dto.setPointsRedeem(pointsRedeem);

              // Recalculate profits based on discounts
              dto.setProfitAfterDiscount(
                      dto.getNetSales() + dto.getExCharges() - cashDiscount - pointsRedeem - dto.getCostSales()
              );
              dto.setProfitBeforeDiscount(
                      dto.getGrossSales() + dto.getExCharges() - cashDiscount - pointsRedeem - dto.getCostSales()
              );
              dto.setNetSales(
                      dto.getNetSales() + dto.getExCharges() - cashDiscount - pointsRedeem
              );
          });
          return dto;
      }catch(Exception e){
          System.out.println(e.getMessage());
          throw new RuntimeException(e);
      }

    }

    private static class SalesSummaryRowMapper implements RowMapper<ResponseSalesSummaryDTO> {
        @Override
        public ResponseSalesSummaryDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            return ResponseSalesSummaryDTO.builder()
                    .totalQtySold(rs.getDouble("totalQtySold"))
                    .grossSales(rs.getDouble("grossSales"))
                    .itemDiscount(rs.getDouble("itemDiscount"))
                    .netSales(rs.getDouble("netSales"))
                    .profitBeforeDiscount(rs.getDouble("profitBeforeDiscount"))
                    .profitAfterDiscount(rs.getDouble("profitAfterDiscount"))
                    .exCharges(rs.getDouble("exCharges"))
                    .costSales(rs.getDouble("costSales"))
                    .build();
        }
    }

//    private List<Object> buildParams(String dateFrom, String dateTo, String companyId,String locationCode) {
//        List<Object> params = new ArrayList<>();
//        params.add(dateFrom);
//        params.add(dateTo);
//        params.add(companyId);
//        params.add(companyId);
//        if (!locationCode.equals("All")) {
//            params.add(locationCode);
//        }
//        return params;
//    }

    private String buildLocationFilter(String locationCode, String tableName) {
        return locationCode.equals("All") ? "" : " AND " + tableName + ".LocaCode = ?";
    }
}