package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseOtherIncomeExpenseDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@RequiredArgsConstructor
@Repository
public class OtherIncomeExpenseRepo {
    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate jdbcTemplate;

    public ResponseOtherIncomeExpenseDTO getOtherIncomeExpense(String dateFrom, String dateTo, String locationCode, String companyId) {
        ResponseOtherIncomeExpenseDTO dto = new ResponseOtherIncomeExpenseDTO();

        // Get Other Expenses
        String expenseSql = "SELECT " +
                "COALESCE(SUM(NTotal), 0) AS otherExpenses, " +
                "COALESCE(SUM(CashPaid), 0) AS cashPaymentExp, " +
                "COALESCE(SUM(CHQPaid), 0) AS chqPaymentExp, " +
                "COALESCE(SUM(IDueamount), 0) AS creditPaymentExp, " +
                "COALESCE(SUM(BankPaid), 0) AS bankPaymentExp " +
                "FROM tbl_OIncSummery " +
                "WHERE (LEFT(SerialNo, 4) = 'EXPM' OR LEFT(SerialNo, 4) = 'EXPN') " +
                "AND chkFS = '1' AND DirectIndirect = 'DIRECT' " +
                "AND CreateDate BETWEEN ? AND ? " +
                "AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> expenseParams = buildParams(dateFrom, dateTo, companyId, locationCode);

        jdbcTemplate.query(expenseSql, expenseParams.toArray(), rs -> {
            dto.setOtherExpenses(rs.getDouble("otherExpenses"));
            dto.setCashPaymentExp(rs.getDouble("cashPaymentExp"));
        });

        // Get Other Income
        String incomeSql = "SELECT " +
                "COALESCE(SUM(NTotal), 0) AS otherIncome, " +
                "COALESCE(SUM(CashPaid), 0) AS cashPaymentInc, " +
                "COALESCE(SUM(CHQPaid), 0) AS chqPaymentInc, " +
                "COALESCE(SUM(IDueamount), 0) AS creditPaymentInc, " +
                "COALESCE(SUM(BankPaid), 0) AS bankPaymentInc " +
                "FROM tbl_OIncSummery " +
                "WHERE (LEFT(SerialNo, 4) = 'INCM' OR LEFT(SerialNo, 4) = 'INCN') " +
                "AND chkFS = '1' AND DirectIndirect = 'DIRECT' " +
                "AND CreateDate BETWEEN ? AND ? " +
                "AND CompID = ? " +
                buildLocationFilter(locationCode);

        List<Object> incomeParams = buildParams(dateFrom, dateTo, companyId, locationCode);

        jdbcTemplate.query(incomeSql, incomeParams.toArray(), rs -> {
            dto.setOtherIncome(rs.getDouble("otherIncome"));
            dto.setCashPaymentInc(rs.getDouble("cashPaymentInc"));
        });

        return dto;
    }

    private List<Object> buildParams(String dateFrom, String dateTo, String companyId, String locationCode) {
        List<Object> params = new ArrayList<>();
        params.add(dateFrom);
        params.add(dateTo);
        params.add(companyId);
        if (!locationCode.equals("All")) {
            params.add(locationCode);
        }
        return params;
    }

    private String buildLocationFilter(String locationCode) {
        return locationCode.equals("All") ? "" : " AND LocaCode = ?";
    }
}