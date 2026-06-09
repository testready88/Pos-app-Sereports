package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;

@Data
@AllArgsConstructor
@RequiredArgsConstructor
@Builder
public class ResponsePurchaseSummeryDTO {
    private LocalDate date;
    private int loca;
    private String invoiceNo;
    private String supName;
    private double gPurchase;
    private double discount;
    private double nPurchase;
    private double gP;
    private double paid;
    private double credit;
    private String remark;
}
