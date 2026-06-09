package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseEmployeeDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.EmployeeService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.*;


@Service
@RequiredArgsConstructor
public class EmployeeServiceImpl implements EmployeeService {

    private final JdbcTemplate mainJdbcTemplate;
    private final CompanyUserService companyUserService;

    @Override
    public PaginatedResponseEmployeeDTO getEmployeeDetails(
            String token,
            String searchText,
            int page,
            int size) throws SQLException {

        // Get user data from token
        ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
        String companyId = userData.getCompanyId();

        // Build employee search filter
        String employeeFilter = buildEmployeeSearchFilter(searchText);

        // Prepare parameters for the query
        List<Object> queryParams = new ArrayList<>();
        queryParams.add(companyId);

        // Add search parameter if provided
        if (searchText != null && !searchText.isEmpty()) {
            String searchPattern = "%" + searchText + "%";
            // Add the pattern 7 times for each field in the search
            for (int i = 0; i < 7; i++) {
                queryParams.add(searchPattern);
            }
        }

        // Pagination parameters
        List<Object> dataParams = new ArrayList<>(queryParams);
        dataParams.add(page * size);
        dataParams.add(size);

        // Main query with pagination
        String dataSql = "SELECT " +
                "tbl_EmpDet.LocaCode, " +
                "tbl_EmpDet.EmpCode, " +
                "tbl_EmpDet.EmpNIC, " +
                "tbl_EmpDet.EmpGroup, " +
                "tbl_EmpDet.EmpCategory, " +
                "tbl_EmpDet.EmpName, " +
                "(tbl_EmpDet.EmpMob1+' '+tbl_EmpDet.EmpMob2+' '+tbl_EmpDet.EmpPhone+' '+tbl_EmpDet.EmpHPhone) AS ContactDetails, " +
                "(tbl_EmpDet.EmpAddress+' '+tbl_EmpDet.EmpAddress2+' '+tbl_EmpDet.EmpAddress3) AS AddressDetails, " +
                "tbl_EmpDet.CreateBy, " +
                "tbl_EmpDet.CreateDate " +
                "FROM tbl_EmpDet " +
                "WHERE tbl_EmpDet.CompID = ? " +
                employeeFilter +
                "GROUP BY " +
                "tbl_EmpDet.LocaCode, " +
                "tbl_EmpDet.EmpCode, " +
                "tbl_EmpDet.EmpNIC, " +
                "tbl_EmpDet.EmpGroup, " +
                "tbl_EmpDet.EmpCategory, " +
                "tbl_EmpDet.EmpName, " +
                "tbl_EmpDet.EmpPhone, " +
                "tbl_EmpDet.EmpHPhone, " +
                "tbl_EmpDet.EmpMob1, " +
                "tbl_EmpDet.EmpMob2, " +
                "tbl_EmpDet.EmpAddress, " +
                "tbl_EmpDet.EmpAddress2, " +
                "tbl_EmpDet.EmpAddress3, " +
                "tbl_EmpDet.CreateBy, " +
                "tbl_EmpDet.CreateDate " +
                "ORDER BY tbl_EmpDet.EmpName ASC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        // Execute query and map results
        List<Object> employees = mainJdbcTemplate.query(dataSql, dataParams.toArray(), (rs, rowNum) -> {
            Map<String, Object> employee = new HashMap<>();
            employee.put("locaCode", rs.getString("LocaCode"));
            employee.put("empCode", rs.getString("EmpCode"));
            employee.put("empNIC", rs.getString("EmpNIC"));
            employee.put("empGroup", rs.getString("EmpGroup"));
            employee.put("empCategory", rs.getString("EmpCategory"));
            employee.put("empName", rs.getString("EmpName"));
            employee.put("contactDetails", rs.getString("ContactDetails"));
            employee.put("addressDetails", rs.getString("AddressDetails"));
            employee.put("createBy", rs.getString("CreateBy"));
            employee.put("createDate", rs.getDate("CreateDate"));
            return employee;
        });

        // Count query
        String countSql = "SELECT COUNT(*) FROM (" +
                "SELECT tbl_EmpDet.EmpCode " +
                "FROM tbl_EmpDet " +
                "WHERE tbl_EmpDet.CompID = ? " +
                employeeFilter +
                "GROUP BY " +
                "tbl_EmpDet.LocaCode, " +
                "tbl_EmpDet.EmpCode, " +
                "tbl_EmpDet.EmpNIC, " +
                "tbl_EmpDet.EmpGroup, " +
                "tbl_EmpDet.EmpCategory, " +
                "tbl_EmpDet.EmpName, " +
                "tbl_EmpDet.EmpPhone, " +
                "tbl_EmpDet.EmpHPhone, " +
                "tbl_EmpDet.EmpMob1, " +
                "tbl_EmpDet.EmpMob2, " +
                "tbl_EmpDet.EmpAddress, " +
                "tbl_EmpDet.EmpAddress2, " +
                "tbl_EmpDet.EmpAddress3, " +
                "tbl_EmpDet.CreateBy, " +
                "tbl_EmpDet.CreateDate" +
                ") AS CountQuery";

        Long totalCount = mainJdbcTemplate.queryForObject(countSql, queryParams.toArray(), Long.class);

        // Build response
        return PaginatedResponseEmployeeDTO.builder()
                .count(totalCount)
                .data(employees)
                .build();
    }

    /**
     * Build employee search filter condition
     */
    private String buildEmployeeSearchFilter(String searchText) {
        if (searchText == null || searchText.isEmpty()) {
            return "";
        }

        return " AND (tbl_EmpDet.EmpNIC LIKE ? " +
                "OR tbl_EmpDet.EmpName LIKE ? " +
                "OR tbl_EmpDet.EmpMob1 LIKE ? " +
                "OR tbl_EmpDet.EmpMob2 LIKE ? " +
                "OR tbl_EmpDet.EmpAddress LIKE ? " +
                "OR tbl_EmpDet.EmpAddress2 LIKE ? " +
                "OR tbl_EmpDet.EmpAddress3 LIKE ?) ";
    }
}