package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

@Builder
@Data
@RequiredArgsConstructor
@AllArgsConstructor
public class ResponseSalesSummaryDTO {
    private double totalQtySold;
    private double grossSales;
    private double itemDiscount;
    private double netSales;
    private double profitBeforeDiscount;
    private double profitAfterDiscount;
    private double exCharges;
    private double costSales;
    private double cashPayment;
    private double creditPayment;
    private double cardPayment;
    private double chqPayment;
    private double cashDiscount;
    private double pointsRedeem;
}