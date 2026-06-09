package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@AllArgsConstructor
@Getter
@Setter
@Builder
public class PaginatedResponsePayableDTO {

    private Long count;
    private Double totalOutstandingAmount;
    private List<Object> data;
}
