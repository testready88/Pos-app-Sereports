package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.bankdto.ResponseChqTransactionDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;

@AllArgsConstructor
@Data
@Builder
@RequiredArgsConstructor
public class PaginatedResponseChqTransactionDTO {
    private Long count;
    private List<ResponseChqTransactionDTO> data;
    private Double payableAmount;
    private Double receivableAmount;
    private Double partyChqAmount;
}
