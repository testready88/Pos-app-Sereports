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
public class ResponseSalesSummeryDTO {
    private LocalDate date;
    private int loca;
    private String serialNo;
    private String customerName;
    private double gSales;
    private double itemDiscount;
    private double cashDiscount;
    private double nSales;
    private double gP;
    private double paid;
    private double credit;
}
