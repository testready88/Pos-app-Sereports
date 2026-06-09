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
public class ResponseIncomeOrExpensesDTO {
    private LocalDate date;
    private String loca;
    private String id;
    private String type;
    private String desc;
    private String vendor;
    private String amount;
    private double cash;
    private double chq;
    private double bank;
    private double credit;
    private String remark;

}
