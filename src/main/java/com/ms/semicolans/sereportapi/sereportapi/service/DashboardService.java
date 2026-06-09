package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseDashboardSummaryDTO;

import java.sql.SQLException;

public interface DashboardService {
    ResponseDashboardSummaryDTO getDashboardSummary(String token, String dateFrom, String dateTo, String locationCode) throws SQLException;
}