package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseChqDTO;

import java.sql.SQLException;
import java.time.LocalDate;

public interface AccountsChqService {
    PaginatedResponseChqDTO getAllCheques(String locaCode, String bankName, LocalDate dateFrom, LocalDate dateTo, String searchRef, String chqNo, String chqType, String statusFilter, int page, int size, String token) throws SQLException;
}
