package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.bankdto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

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
    private Double amountInBank;
    private Double chqPayableToday;
    private Double chqPayableTotal;
    private Double amountShortAccessToday;
    private Double amountShortAccessTotal;
}
