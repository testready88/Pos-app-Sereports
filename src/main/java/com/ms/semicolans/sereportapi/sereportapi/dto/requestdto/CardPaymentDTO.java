package com.ms.semicolans.sereportapi.sereportapi.dto.requestdto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CardPaymentDTO {
    private String cardNumber;
    private String cardType; // VISA CARD, MASTER CARD, AMERICAN EXPRESS, IPAY, OTHER
    private Integer expMonth;
    private Integer expYear;
    private String cardHolderName;
    private String pin;
    private BigDecimal paidAmount;
    private String bankCode;
    private String bankName;
    private String branchCode;
    private String branchName;
    private String accountType;
    private String accountNo;
}

