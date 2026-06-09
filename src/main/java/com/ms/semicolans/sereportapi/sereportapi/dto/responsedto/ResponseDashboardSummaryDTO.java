package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

@Builder
@Data
@RequiredArgsConstructor
@AllArgsConstructor
public class ResponseDashboardSummaryDTO {
    private ResponseSalesSummaryDTO salesSummary;
    private ResponsePurchaseSummaryDTO purchaseSummary;
    private ResponseOtherIncomeExpenseDTO otherIncomeExpense;
    private ResponseStockSummaryDTO stockSummary;
    private ResponseBalanceSheetDTO balanceSheet;
}