package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;

@AllArgsConstructor
@Data
@RequiredArgsConstructor
@Builder
public class ResponsePayableAndReceivableDTO {
    private LocalDate date;
    private Long loca;
    private String supName;
    private String invoiceNo;
    private double invoiceAmount;
    private double creditAmount;
    private double invoiceGap;
    private String remark;
}
