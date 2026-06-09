package com.ms.semicolans.sereportapi.sereportapi.dto.requestdto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class BankTransferDTO {
    private String referenceNo;
    private LocalDate createDate;
    private BigDecimal paidAmount;
    private BigDecimal serviceCharge;
    private String bankCode;
    private String bankName;
    private String branchCode;
    private String branchName;
    private String accountType;
    private String accountNo;
}

