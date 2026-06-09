package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseChqDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.AccountsChqService;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AccountsChqServiceImpl implements AccountsChqService {
    private final JdbcTemplate jdbcTemplate;
    private final CompanyUserService companyUserService;

    @Override
    public PaginatedResponseChqDTO getAllCheques(String locaCode, String bankName, LocalDate dateFrom, LocalDate dateTo,
                                                  String searchRef, String chqNo, String chqType,
                                                  String statusFilter, int page, int size, String token) throws SQLException {
        ResponseCompanyUserDataDTO user = companyUserService.getUserAllData(token);
        String companyId = user.getCompanyId();

        List<Object> params = new ArrayList<>();
        StringBuilder where = new StringBuilder("WHERE CompID=? ");
        params.add(companyId);

        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            where.append("AND Status=? ");
            params.add(statusFilter);
        }
        if (locaCode != null && !"All".equals(locaCode) && !locaCode.isEmpty()) {
            where.append("AND LocaCode=? ");
            params.add(locaCode);
        }
        if (bankName != null && !"All".equals(bankName) && !bankName.isEmpty()) {
            where.append("AND BnkName=? ");
            params.add(bankName);
        }
        if (dateFrom != null) {
            where.append("AND ChqDate>=? ");
            params.add(dateFrom);
        }
        if (dateTo != null) {
            where.append("AND ChqDate<=? ");
            params.add(dateTo);
        }
        if (searchRef != null && !searchRef.isEmpty()) {
            where.append("AND ReferenceNo LIKE '%' + ? + '%' ");
            params.add(searchRef);
        }
        if (chqNo != null && !chqNo.isEmpty()) {
            where.append("AND ChqNo LIKE '%' + ? + '%' ");
            params.add(chqNo);
        }
        if (chqType != null && !"All".equalsIgnoreCase(chqType)) {
            String chqTypeCondition = getChqTypeCondition(chqType);
            if (chqTypeCondition != null) {
                where.append("AND ").append(chqTypeCondition).append(" ");
            }
        }

        List<Object> dataParams = new ArrayList<>(params);
        dataParams.add(page * size);
        dataParams.add(size);

        String dataSql = "SELECT * FROM tbl_ChqDet " + where + "ORDER BY ChqDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        List<Map<String, Object>> cheques = jdbcTemplate.query(dataSql, dataParams.toArray(), new ColumnMapRowMapper());

        String countSql = "SELECT COUNT(*) FROM tbl_ChqDet " + where;
        Long count = jdbcTemplate.queryForObject(countSql, params.toArray(), Long.class);

        Double payable = calculateTotalRaw("OWN CHQ", companyId);
        Double receivable = calculateTotalRaw("RECIEVED CHQ", companyId);
        Double partyChq = calculateTotalRaw("PARTY CHQ", companyId);

        return PaginatedResponseChqDTO.builder()
                .count(count)
                .data(new ArrayList<>(cheques))
                .totalPayable(payable)
                .totalReceivable(receivable)
                .totalPartyChq(partyChq)
                .build();
    }

    private String getChqTypeCondition(String chqType) {
        switch (chqType.toUpperCase()) {
            case "OWN CHQ": return "(ChqType='OWN CHQ' AND Status<>'UNKNOWN')";
            case "RECEIVED CHQ": return "(ChqType='RECIEVED CHQ' AND Status<>'UNKNOWN')";
            case "PARTY CHQ": return "(ChqType='PARTY CHQ' AND Status<>'UNKNOWN')";
            case "CHQ IN HAND": return "(TransactionType='IN HAND' AND Status<>'RETURN')";
            case "CROSS CHQ": return "(PaymentType='CROSS CHQ' AND Status<>'UNKNOWN')";
            case "CASH CHQ": return "(PaymentType='CASH CHQ' AND Status<>'UNKNOWN')";
            case "RETURN CHQ": return "Status='RETURN'";
            case "UNKNOWN CHQ": return "Status='UNKNOWN'";
            default: return null;
        }
    }

    private Double calculateTotalRaw(String chqType, String companyId) {
        String sql = "SELECT COALESCE(SUM(PaidAmount),0) FROM tbl_ChqDet WHERE Status='PENDING' AND ChqType=? AND CompID=?";
        return jdbcTemplate.queryForObject(sql, Double.class, chqType, companyId);
    }
}
