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
public class PaginatedResponsePurchaseSummaryDTO {
    private Long count;
    private Double totalQtyPur;
    private Double grossPurchase;
    private Double itemDiscountPur;
    private Double netPurchase;
    private Double cashDiscountPur;
    private Double advancePaymentPur;
    private Double chqPaymentPur;
    private Double cardPaymentPur;
    private Double creditPaymentPur;
    private Double cashPaymentPur;
    private Double transportCharge;
    private Double labourCharge;
    private List<Object> data;
}
