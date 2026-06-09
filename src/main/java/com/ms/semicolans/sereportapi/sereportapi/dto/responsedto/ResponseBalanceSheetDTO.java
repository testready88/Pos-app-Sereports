package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

@Builder
@Data
@RequiredArgsConstructor
@AllArgsConstructor
public class ResponseBalanceSheetDTO {
    private double cashInHand;
    private double amountInBank;
    private double inventory;
    private double amountReceivable;
    private double chqReceivable;
    private double otherCurrentAsset;
    private double totalCurrentAssets;
    private double totalFixedAssets;
    private double totalAssets;
    private double totalCash;
    private double amountPayable;
    private double chqPayable;
    private double advanceReceived;
    private double totalCurrentLiabilities;
    private double capital;
    private double netProfit;
    private double totalLiabilities;
    private double assetsLiabilitiesDifference;
}