package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponsePurchaseSummaryDTO;

import java.sql.SQLException;
import java.time.LocalDate;

public interface PurchaseSummaryService {
    PaginatedResponsePurchaseSummaryDTO getPurchaseSummary(String token, String locaCode, String searchSupplier, String searchInvoice, String paymentType, LocalDate dateFrom, LocalDate dateTo, int page, int size) throws SQLException;
}
