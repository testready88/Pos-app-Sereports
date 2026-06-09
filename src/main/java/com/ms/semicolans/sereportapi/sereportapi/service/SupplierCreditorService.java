package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCreditorsDetailsDTO;

import java.sql.SQLException;

public interface SupplierCreditorService{
    PaginatedResponseCreditorsDetailsDTO getCreditorsDetailsList(String supplierSearch, String creditSearch, String invGap, String settlementGap, Integer page, Integer size, String token) throws SQLException;
}
