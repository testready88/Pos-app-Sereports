package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;
@Data
@AllArgsConstructor
@RequiredArgsConstructor
@Builder
public class PaginatedResponseChqDTO {
    private Long count;                    // Total records count
    private List<Object> data; // Paginated data
    private Double totalPayable;              // Summary data
    private Double totalReceivable;
    private Double totalPartyChq;
}
