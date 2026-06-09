package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseSalesSummaryDTO;

import java.sql.SQLException;
import java.time.LocalDate;

public interface SalesSummaryService {
    PaginatedResponseSalesSummaryDTO getSalesSummary(String token, String locaCode, String searchCustomer, String paymentType, String dateFrom, String dateTo, int page, int size) throws SQLException;
}
