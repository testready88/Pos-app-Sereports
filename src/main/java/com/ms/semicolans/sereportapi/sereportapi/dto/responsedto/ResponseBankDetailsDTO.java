package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.math.BigDecimal;
@Data
@AllArgsConstructor
@RequiredArgsConstructor
@Builder
public class ResponseBankDetailsDTO {
    private String bankInfo;
    private String bnkName;
    private String acNo;
    private String acType;
    private String bankCode;
    private double amountInBank;
    private BigDecimal chqPayableToday;
    private BigDecimal chqPayableTotal;
    private BigDecimal amountShortAccessToday;
    private BigDecimal amountShortAccessTotal;
    private double chqPayableOverall;
    private double amountShortAccess;
}
