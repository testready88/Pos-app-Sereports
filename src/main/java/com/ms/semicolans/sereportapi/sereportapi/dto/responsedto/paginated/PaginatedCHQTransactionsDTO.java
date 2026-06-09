package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCHQTransactionsDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@RequiredArgsConstructor
@Builder
public class PaginatedCHQTransactionsDTO {
    private Long count;
    private List<ResponseCHQTransactionsDTO> data;
}
