package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseIncomeOrExpensesDTO;

import java.util.List;

public class PaginatedResponseIncomeOrExpensesDTO {
    private Long count;
    private List<ResponseIncomeOrExpensesDTO> data;
}
