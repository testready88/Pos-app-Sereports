package com.ms.semicolans.sereportapi.sereportapi.dto.requestdto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class InvoiceCreateRequestDTO {
    private String clientId; // Mobile-generated UUID for merge tracking
    private String locaCode;
    private String unitNo;
    private String compId;
    private Boolean boolInvCodeM; // true -> INVN, false -> INVM
    private String invType;
    private String customerCode;
    private List<InvoiceItemCreateDTO> items;
    
    // Payment information
    private String paymentType; // CASH, CARD, CHEQUE, CREDIT
    private BigDecimal cashPaid;
    private BigDecimal creditPaid;
    private BigDecimal cardPaid;
    private String cardNo;
    private String cardBank;
    private BigDecimal chqPaid;
    private String chqNo;
    private java.time.LocalDate chqDate;
    private String chqBnk;
}


