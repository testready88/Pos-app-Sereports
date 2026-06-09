package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;

@AllArgsConstructor
@RequiredArgsConstructor
@Data
@Builder
public class PaginatedResponseSalesSummaryDTO {
    private Long count;
    private Double totalQtySold;
    private Double grossSales;
    private Double itemDiscount;
    private Double netSales;
    private Double profitBeforeDiscount;
    private Double profitAfterDiscount;
    private Double costSales;
    private Double exCharges;
    private Double advancePayment;
    private Double chqPayment;
    private Double cardPayment;
    private Double creditPayment;
    private Double cashPayment;
    private Double creditSettlement;
    private Double cashDiscount;
    private Double pointsRedeem;
    private Double voucherPaid;
    private Double cashSales;
    private Double profitByCashSales;
    private Double creditSales;
    private Double profitByCreditSales;
    private List<Object> data;
}
