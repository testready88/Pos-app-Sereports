package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseSalesSummery;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;

@AllArgsConstructor
@Data
@Builder
@RequiredArgsConstructor
public class PaginatedResponseSalesSummery {
    private Long count;
    private List<ResponseSalesSummery> data;
}
