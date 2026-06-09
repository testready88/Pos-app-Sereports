package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;

import java.sql.SQLException;

public interface CompanyUserService {
    public ResponseCompanyUserDataDTO getUserAllData(String token) throws SQLException;


}
