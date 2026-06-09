package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseExpensesDTO;

import java.sql.SQLException;
import java.util.Map;
import java.util.List;
import java.time.LocalDate;

public interface ExpensesService {
    PaginatedResponseExpensesDTO getPaginatedExpensesDetails(
            String locaCode,
            String searchDescription,
            String searchVendor,
            String invType,
            LocalDate dateFrom,
            LocalDate dateTo,
            String token,
            int page,
            int size) throws SQLException;

   }
