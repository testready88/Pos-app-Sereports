package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MobileInvoiceListResponseDTO {
    private Long id;
    private String clientId;
    private String serialNo;
    private String invoiceNo;
    private String locaCode;
    private String unitNo;
    private String compId;
    private String invType;
    private String customerCode;
    private BigDecimal grandTotal;
    private Integer itemCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String mergeStatus;
    private Boolean itMerged;
    private LocalDateTime mergeTime;
    private Boolean merged;
}

