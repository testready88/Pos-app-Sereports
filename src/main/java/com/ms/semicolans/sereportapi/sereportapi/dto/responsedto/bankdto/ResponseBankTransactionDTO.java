package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.bankdto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;

@Data
@AllArgsConstructor
@Builder
@RequiredArgsConstructor
public class ResponseBankTransactionDTO {
    private LocalDate createDate;
    private String serialNo;
    private String tranType;
    private String payMode;
    private String id;
    private String bnkCode;
    private String bnkName;
    private String branchName;
    private String acType;
    private String tranNo;
    private Double creditAmount;
    private Double debitAmount;
    private Double totalAmount;
    private String venName;
    private String status;
    private String invoiceDescription;
    private String venCode;
    private String createBy;
}
