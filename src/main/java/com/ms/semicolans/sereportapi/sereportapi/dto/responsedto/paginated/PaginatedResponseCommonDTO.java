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
public class PaginatedResponseCommonDTO {
    private Long count;
    private List<Object> data;
}
