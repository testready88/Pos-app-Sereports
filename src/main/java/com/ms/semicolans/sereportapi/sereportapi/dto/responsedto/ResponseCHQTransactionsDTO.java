package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;

@Builder
@Data
@RequiredArgsConstructor
@AllArgsConstructor
public class ResponseCHQTransactionsDTO {
    private LocalDate date;
    private String id;
    private Long chqNo;
    private String chqType;
    private String vendor;
    private String bank;
    private String remarks;
    private double amount;
}
