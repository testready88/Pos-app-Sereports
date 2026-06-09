package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseChqDTO;

import java.sql.SQLException;
import java.time.LocalDate;

public interface ChqService {
    PaginatedResponseChqDTO getCheques(String locaCode, String bankName, LocalDate dateTo, String searchRef, String chqNo, String chqType, int page, int size, String token) throws SQLException;
}
