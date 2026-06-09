package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.bankdto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;

@AllArgsConstructor
@Data
@Builder
@RequiredArgsConstructor
public class ResponseChqTransactionDTO {
    private String serialNo;
    private String invoiceNo;
    private String id;
    private String chqNo;
    private String status;
    private Double paidAmount;
    private LocalDate chqDate;
    private String chqType;
    private String venName;
    private String venNameChqFrom;
    private String transactionType;
    private String bnkCode;
    private String bnkName;
    private String branchName;
    private String acType;
    private LocalDate createDate;
    private String createBy;
    private String venCode;
    private String invoiceDescription;
    private String serialNoChqFrom;
    private String venCodeChqFrom;
    private String invoiceDescriptionChqFrom;
    private Long idChqFrom;
    private String referenceNo;
}
