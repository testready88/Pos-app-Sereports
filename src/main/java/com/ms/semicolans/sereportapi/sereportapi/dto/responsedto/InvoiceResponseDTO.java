package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class InvoiceResponseDTO {
    private String serialNo;
    private String invoiceNo;
    private String locaCode;
    private String compId;
    private LocalDate createDate;
    private String invType;
    private String invStatus;
    private String invMethod;
    private BigDecimal gTotal;
    private BigDecimal nTotal;
    private BigDecimal nTotalCashDiscount;
    private BigDecimal nTotalCusDiscount;
    private BigDecimal nTotalStaffDiscount;
    private BigDecimal nTotalForLoyaltyPoints;
    private BigDecimal cTotal;
    private BigDecimal cTotalAfterDiscount;
    private BigDecimal vatAmountInTotal;
    private BigDecimal nbtAmountInTotal;
    private BigDecimal totalAmountAfterVat;
    private BigDecimal balanceAmount;
    private BigDecimal paidAmount;
    private BigDecimal pointsEarned;
    private BigDecimal pointsRedeem;
    private String customerCode;
    private String customerName;
    private List<InvoiceDetailResponseDTO> items;
}

