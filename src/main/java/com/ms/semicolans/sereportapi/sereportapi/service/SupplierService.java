package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.*;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCreditorsDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponsePayableDTO;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

public interface SupplierService {
    List<ResponseCommonNameAndCodeDTO> getAllSuppliersNameList(String searchText, String token) throws SQLException;

    void getSupplierData(String searchText, String token) throws SQLException;

    PaginatedResponseCreditorsDetailsDTO getAllSuppliersList(String supplierSearch, String creditSearch, String invGap, String settlementGap, Integer page, Integer size, String token) throws SQLException;

    PaginatedResponsePayableDTO getPayableDetails(String token, String locaCode, String searchSupplier, String searchInvoice, String invGap, LocalDate dateFrom, LocalDate dateTo, int page, int size) throws SQLException;
}
