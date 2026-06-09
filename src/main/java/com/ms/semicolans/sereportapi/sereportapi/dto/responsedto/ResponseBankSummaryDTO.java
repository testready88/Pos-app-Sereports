package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.math.BigDecimal;
@Data
@AllArgsConstructor
@RequiredArgsConstructor
@Builder
public class ResponseBankSummaryDTO {
    private BigDecimal totalBankBalance;
}
