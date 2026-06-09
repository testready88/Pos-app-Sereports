package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseBankDTO;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

public interface BankDetailsService {
    List<String> getAllBankNames(String token) throws SQLException;

    ResponseBankDTO getBankDetails(String token, String bankName, String locationCode, String dateTo) throws SQLException;
}
