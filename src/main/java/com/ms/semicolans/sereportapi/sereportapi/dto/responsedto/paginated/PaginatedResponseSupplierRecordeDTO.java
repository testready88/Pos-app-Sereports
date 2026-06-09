package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCommonSupplierCustomerRecordeDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@Builder
@RequiredArgsConstructor
public class PaginatedResponseSupplierRecordeDTO {

    private Long count;
    private List<ResponseCommonSupplierCustomerRecordeDTO> data;

}
