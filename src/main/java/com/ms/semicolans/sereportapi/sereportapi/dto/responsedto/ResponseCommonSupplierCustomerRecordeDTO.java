package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.time.OffsetDateTime;

@Data
@AllArgsConstructor
@RequiredArgsConstructor
public class ResponseCommonSupplierCustomerRecordeDTO {

    private String cusId;
    private String cusName;
    private double outstandingAmount;
    private String address;
    private String contact;
    private OffsetDateTime lastInvoiceDate;
    private OffsetDateTime lastPaidDate;
    private double lastPaidAmount;
    private int numberOfCHQ;
    private String CHQInHand;

}
