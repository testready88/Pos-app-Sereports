package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Response DTO for last invoice price lookup.
 * Returns ItemDPrice and Qty from the most recent invoice for the given item.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LastInvPriceResponseDTO {
    private BigDecimal itemDPrice;
    private Integer qty;
}
