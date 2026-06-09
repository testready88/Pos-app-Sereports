package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseEmployeeDTO;

import java.sql.SQLException;

public interface EmployeeService {
    PaginatedResponseEmployeeDTO getEmployeeDetails(String token, String searchText, int page, int size) throws SQLException;
}
