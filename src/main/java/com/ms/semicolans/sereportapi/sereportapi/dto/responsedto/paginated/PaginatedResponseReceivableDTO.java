package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;
@AllArgsConstructor
@Data
@Builder
@RequiredArgsConstructor
public class PaginatedResponseReceivableDTO {
    private Long count;
    private Double totalOutstandingAmount;
    private List<Object> data;
}
