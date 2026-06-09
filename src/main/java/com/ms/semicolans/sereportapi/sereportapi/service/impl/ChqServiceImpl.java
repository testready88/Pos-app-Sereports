package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ChqResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseChqDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.ChqService;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.time.LocalDate;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ChqServiceImpl implements ChqService {
    private final JdbcTemplate jdbcTemplate;
    private final CompanyUserService companyUserService;
    @Override
    public PaginatedResponseChqDTO getCheques(String locaCode, String bankName, LocalDate dateTo,
                                              String searchRef, String chqNo, String chqType,
                                              int page, int size, String token) throws SQLException {

        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();

        List<Object> params = new ArrayList<>();
        StringBuilder whereClause = new StringBuilder("WHERE Status='PENDING' AND CompID=? ");
        params.add(companyId);

        // ... [keep all existing filter logic unchanged] ...

        // Modified data retrieval using ColumnMapRowMapper
        List<Object> dataParams = new ArrayList<>(params);
        dataParams.add(page * size);
        dataParams.add(size);

        String dataSql = "SELECT * FROM tbl_ChqDet " + whereClause +
                "ORDER BY ChqDate ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        List<Map<String, Object>> cheques = jdbcTemplate.query(
                dataSql,
                dataParams.toArray(),
                new ColumnMapRowMapper()
        );

        // Count query remains unchanged
        String countSql = "SELECT COUNT(*) FROM tbl_ChqDet " + whereClause;
        Long count = jdbcTemplate.queryForObject(countSql, params.toArray(), Long.class);

        // Calculate totals (keep existing logic)
        Double payable = calculateTotal("OWN CHQ", params);
        Double receivable = calculateTotal("RECIEVED CHQ", params);
        Double partyChq = calculateTotal("PARTY CHQ", params);

        return PaginatedResponseChqDTO.builder()
                .count(count)
                .data(new ArrayList<>(cheques))  // Convert List<Map> to List<Object>
                .totalPayable(payable)
                .totalReceivable(receivable)
                .totalPartyChq(partyChq)
                .build();
    }

    private Double calculateTotal(String chqType, List<Object> baseParams) {
        // Create new parameters list with only required values
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COALESCE(SUM(PaidAmount), 0) FROM tbl_ChqDet " +
                "WHERE Status='PENDING' AND ChqType=? " +
                "AND CompID=?";

        params.add(chqType);
        params.add(baseParams.get(0)); // companyId from baseParams

        return jdbcTemplate.queryForObject(sql, params.toArray(), Double.class);
    }

    private static class ChqRowMapper implements RowMapper<ChqResponseDTO> {
        @Override
        public ChqResponseDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            return ChqResponseDTO.builder()
                    .serialNo(rs.getString("SerialNo"))
                    .invoiceNo(rs.getString("InvoiceNo"))
                    .chqNo(rs.getString("ChqNo"))
                    .status(rs.getString("Status"))
                    .paidAmount(rs.getDouble("PaidAmount"))
                    .chqDate(rs.getDate("ChqDate").toLocalDate())
                    .chqType(rs.getString("ChqType"))
                    .venName(rs.getString("VenName"))
                    .transactionType(rs.getString("TransactionType"))
                    .bnkCode(rs.getString("BnkCode"))
                    .bnkName(rs.getString("BnkName"))
                    .branchName(rs.getString("BranchName"))
                    .acType(rs.getString("AcType"))
                    .createDate(rs.getDate("CreateDate").toLocalDate())
                    .referenceNo(rs.getString("ReferenceNo"))
                    .build();
        }
    }
}
