package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseReceivableDTO;

import java.sql.SQLException;
import java.time.LocalDate;

public interface ReceivableService {
    PaginatedResponseReceivableDTO getReceivableDetails(String token, String locaCode, String searchCustomer, String searchInvoice, String invGap, LocalDate dateFrom, LocalDate dateTo, int page, int size) throws SQLException;
}
