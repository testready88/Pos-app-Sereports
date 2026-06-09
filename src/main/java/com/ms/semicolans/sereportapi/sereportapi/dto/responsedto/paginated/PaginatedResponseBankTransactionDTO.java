package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.bankdto.ResponseBankTransactionDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@RequiredArgsConstructor
@Builder
public class PaginatedResponseBankTransactionDTO {
    private Long count;
    private Double totalDeposits;
    private Double totalWithdrawals;
    private Double bankBalance;
    private List<ResponseBankTransactionDTO> data;
}
