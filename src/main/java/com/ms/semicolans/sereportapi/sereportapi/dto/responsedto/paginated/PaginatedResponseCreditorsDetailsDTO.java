package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.supplierdto.ResponseCreditorsDetailsDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;

@Data
@RequiredArgsConstructor
@AllArgsConstructor
@Builder
public class PaginatedResponseCreditorsDetailsDTO {
    private Long count;
    private Double totalOutstandingAmount;
    private List<ResponseCreditorsDetailsDTO> data;
}
