package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;
@Data
@AllArgsConstructor
@RequiredArgsConstructor
@Builder
public class ResponseBankDTO {
    private List<ResponseBankDetailsDTO> bankDetails;
    private ResponseBankSummaryDTO responseBankSummaryDTO;
}
