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
public class ChequePaymentDTO {
    private String chequeNumber;
    private LocalDate createDate;
    private LocalDate chequeDate;
    private String status; // PENDING, CLEARED, BOUNCED
    private String transactionType; // IN HAND, RECEIVED
    private String chequeType; // OWN CHQ, RECEIVED CHQ, PARTY CHQ
    private String paymentType; // CROSS CHQ, CASH CHQ
    private String bankCode;
    private String bankName;
    private String branchCode;
    private String branchName;
    private String accountType;
    private String accountNo;
    private BigDecimal paidAmount;
    private String remark;
    // Party cheque fields (if chequeType is PARTY CHQ)
    private String serialNoChqFrom;
    private String venCodeChqFrom;
    private String venNameChqFrom;
}

