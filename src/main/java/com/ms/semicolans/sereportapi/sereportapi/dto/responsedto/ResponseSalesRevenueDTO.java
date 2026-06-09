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
public class ResponseSalesRevenueDTO {
    private LocalDate date;
    private String loca;
    private Long itemCode;
    private String itemName;
    private double costPrice;
    private double mrp;
    private double qty;
    private double soldPrice;
    private double total;
    private double gP;
    private String customerName;
}
