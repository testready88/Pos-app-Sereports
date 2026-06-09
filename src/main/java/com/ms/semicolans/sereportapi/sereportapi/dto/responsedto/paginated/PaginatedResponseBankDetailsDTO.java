package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;

@AllArgsConstructor
@RequiredArgsConstructor
@Data
@Builder
public class PaginatedResponseBankDetailsDTO {
    private Long count;
    private Double totalBankBalance;
    private List<Object> data;
}
