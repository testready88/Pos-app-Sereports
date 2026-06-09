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
public class PaginatedResponseEmployeeDTO {
    private Long count;
    private List<Object> data;
}