package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChqResponseDTO {
    private String serialNo;
    private String invoiceNo;
    private String chqNo;
    private String status;
    private Double paidAmount;
    private LocalDate chqDate;
    private String chqType;
    private String venName;
    private String transactionType;
    private String bnkCode;
    private String bnkName;
    private String branchName;
    private String acType;
    private LocalDate createDate;
    private String referenceNo;
}