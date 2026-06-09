package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.time.OffsetDateTime;

@Data
@AllArgsConstructor
@RequiredArgsConstructor
@Builder
public class ResponseDebtorsDetailsDTO {
    private String cusId;
    private String cusName;
    private double outstandingAmount;
    private String contact;
    private OffsetDateTime lastInvoiceDate;
    private OffsetDateTime lastPaidDate;
    private double lastPaidAmount;
    private double paymentGap;
    private int numberOfCHQ;
    private String CHQInHand;
}
