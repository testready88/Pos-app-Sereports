package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponsePurchaseDTO;

import java.sql.SQLException;
import java.time.LocalDate;

public interface PurchaseService {
    PaginatedResponsePurchaseDTO getPurchaseDetails(String token, String locaCode, String searchItem, String searchCategory, String searchSupplier, String purchaseType, LocalDate dateFrom, LocalDate dateTo, int page, int size) throws SQLException;
}
