package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.supplierdto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;

@Data
@AllArgsConstructor
@Builder
@RequiredArgsConstructor
public class ResponseCreditorsDetailsDTO {
    private String supCode;
    private String supUniqID;
    private String supName;
    private String contactDetails;
    private String addressDetails;
    private LocalDate lastInvDate;
    private Double lastInvAmount;
    private Integer invGap;
    private LocalDate lastPayDate;
    private Double lastPayAmount;
    private Integer paymentGap;
    private Double outstandingAmount;
    private Integer noOfCHQ;
    private Double chqAmount;
    private Double totalPurchase;
    private Double discountAmount;
    private Double creditLimit;
    private String createBy;
    private LocalDate createDate;
}
