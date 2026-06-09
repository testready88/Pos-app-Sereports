package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

@Builder
@Data
@RequiredArgsConstructor
@AllArgsConstructor
public class ResponseOtherIncomeExpenseDTO {
    private double otherExpenses;
    private double otherIncome;
    private double cashPaymentExp;
    private double cashPaymentInc;
}