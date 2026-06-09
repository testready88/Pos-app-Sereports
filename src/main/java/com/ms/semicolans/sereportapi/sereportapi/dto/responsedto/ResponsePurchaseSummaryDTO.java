package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

@Builder
@Data
@RequiredArgsConstructor
@AllArgsConstructor
public class ResponsePurchaseSummaryDTO {
    private double totalQtyPur;
    private double grossPurchase;
    private double itemDiscountPur;
    private double netPurchase;
    private double cashDiscountPur;
    private double transportCharge;
    private double labourCharge;
}