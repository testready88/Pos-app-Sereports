package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;

@Data
@RequiredArgsConstructor
@AllArgsConstructor
@Builder
public class PaginatedResponseExpensesDTO {
    private Long count;                    // Total records count
    private List<Object> data; // Paginated data
    private Double netIncome;              // Summary data
    private Double netExpenses;
}
