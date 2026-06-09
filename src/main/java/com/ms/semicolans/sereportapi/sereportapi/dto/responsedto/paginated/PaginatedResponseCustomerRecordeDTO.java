package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.customerdto.ResponseCustomerDetailsDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@RequiredArgsConstructor
@Builder
public class PaginatedResponseCustomerRecordeDTO {

    private Long count;
    private Double totalOutstandingAmount;
    private List<ResponseCustomerDetailsDTO> data;
}
