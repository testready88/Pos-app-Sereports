package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseSalesDTO;

import java.sql.SQLException;
import java.time.LocalDate;

public interface SalesService {
    PaginatedResponseSalesDTO getSalesDetails(String token, String locaCode,
                                              String searchItem, String searchCategory,
                                              String searchSupplier, String salesType,
                                              LocalDate dateFrom, LocalDate dateTo, int page, int size) throws SQLException;
}
