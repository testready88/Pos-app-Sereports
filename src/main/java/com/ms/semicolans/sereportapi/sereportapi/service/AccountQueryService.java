package com.ms.semicolans.sereportapi.sereportapi.service;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public interface AccountQueryService {
    List<Map<String, Object>> getAssetLedger(String filters, String token) throws SQLException;
    List<Map<String, Object>> getAssetBreakdown(String filters, String token) throws SQLException;
    Map<String, Object> getAssetSummary(String filters, String token) throws SQLException;
    List<Map<String, Object>> getCapitalLedger(String filters, String token) throws SQLException;
    List<Map<String, Object>> getCapitalBreakdown(String filters, String token) throws SQLException;
    Map<String, Object> getCapitalSummary(String filters, String token) throws SQLException;
    List<Map<String, Object>> getCardAccounts(String filters, String token) throws SQLException;
    List<Map<String, Object>> getCardLedger(String filters, String token) throws SQLException;
    List<Map<String, Object>> getCashAccounts(String filters, String token) throws SQLException;
    List<Map<String, Object>> getCashLedger(String filters, String token) throws SQLException;
    List<Map<String, Object>> getLiabilityLedger(String filters, String token) throws SQLException;
    List<Map<String, Object>> getLiabilityBreakdown(String filters, String token) throws SQLException;
    Map<String, Object> getLiabilitySummary(String filters, String token) throws SQLException;
    void adjustCardBalance(Map<String, Object> body, String token) throws SQLException;
}
