package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCommonNameAndCodeDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseSubCategoryDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.SubCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SubCategoryServiceImpl implements SubCategoryService {
    private final CompanyUserService companyUserService;

    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate mainJdbcTemplate;
    @Override
    public List<ResponseCommonNameAndCodeDTO> getAllSubCategoryNameList(String searchText,String categoryId, String token) throws SQLException {
        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);

        String sql;
        Object[] params;


        if (searchText == null || searchText.trim().isEmpty()) {
            if (categoryId == null || categoryId.trim().isEmpty()) {
                // No search text and no category ID
                sql = "SELECT SubCatCode, SubCatName FROM tbl_SubCatDet WHERE CompId = ? ORDER BY SubCatName";
                params = new Object[]{userAllData.getCompanyId()};
            } else {
                // No search text but has category ID
                sql = "SELECT SubCatCode, SubCatName FROM tbl_SubCatDet WHERE CompId = ? AND CatCode = ? ORDER BY SubCatName";
                params = new Object[]{userAllData.getCompanyId(), categoryId};
            }
        } else {
            if (categoryId == null || categoryId.trim().isEmpty()) {
                // Has search text but no category ID
                sql = "SELECT SubCatCode, SubCatName FROM tbl_SubCatDet WHERE CompId = ? AND SubCatName LIKE ? ORDER BY SubCatName";
                String searchPattern = "%" + searchText + "%";
                params = new Object[]{userAllData.getCompanyId(), searchPattern};
            } else {
                // Has both search text and category ID
                sql = "SELECT SubCatCode, SubCatName FROM tbl_SubCatDet WHERE CompId = ? AND CatCode = ? AND SubCatName LIKE ? ORDER BY SubCatName";
                String searchPattern = "%" + searchText + "%";
                params = new Object[]{userAllData.getCompanyId(), categoryId, searchPattern};
            }
        }

        return mainJdbcTemplate.query(sql, params, (rs, rowNum) -> {
            ResponseCommonNameAndCodeDTO dto = new ResponseCommonNameAndCodeDTO();
            dto.setCode(rs.getString("SubCatCode"));
            dto.setName(rs.getString("SubCatName"));
            return dto;
        });
    }

    public PaginatedResponseSubCategoryDTO getAllSubCategoryName(
            String searchText, String categoryId, String token, int size, int page) throws SQLException {

        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);

        String sql;
        String countSql;
        Object[] params;
        Object[] countParams;

        if (searchText == null || searchText.trim().isEmpty()) {
            if (categoryId == null || categoryId.trim().isEmpty()) {
                // No search text and no category ID
                sql = "SELECT SubCatCode, SubCatName FROM tbl_SubCatDet WHERE CompId = ? ORDER BY SubCatName OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
                countSql = "SELECT count(*) FROM tbl_SubCatDet WHERE CompId = ?";
                params = new Object[]{userAllData.getCompanyId(), page * size, size};
                countParams = new Object[]{userAllData.getCompanyId()};
            } else {
                // No search text but has category ID
                sql = "SELECT SubCatCode, SubCatName FROM tbl_SubCatDet WHERE CompId = ? AND CatCode = ? ORDER BY SubCatName OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
                countSql = "SELECT count(*) FROM tbl_SubCatDet WHERE CompId = ? AND CatCode = ?";
                params = new Object[]{userAllData.getCompanyId(), categoryId, page * size, size};
                countParams = new Object[]{userAllData.getCompanyId(), categoryId};
            }
        } else {
            if (categoryId == null || categoryId.trim().isEmpty()) {
                // Has search text but no category ID
                sql = "SELECT SubCatCode, SubCatName FROM tbl_SubCatDet WHERE CompId = ? AND SubCatName LIKE ? ORDER BY SubCatName OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
                countSql = "SELECT count(*) FROM tbl_SubCatDet WHERE CompId = ? AND SubCatName LIKE ?";
                String searchPattern = "%" + searchText + "%";
                params = new Object[]{userAllData.getCompanyId(), searchPattern, page * size, size};
                countParams = new Object[]{userAllData.getCompanyId(), searchPattern};
            } else {
                // Has both search text and category ID
                sql = "SELECT SubCatCode, SubCatName FROM tbl_SubCatDet WHERE CompId = ? AND CatCode = ? AND SubCatName LIKE ? ORDER BY SubCatName OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
                countSql = "SELECT count(*) FROM tbl_SubCatDet WHERE CompId = ? AND CatCode = ? AND SubCatName LIKE ?";
                String searchPattern = "%" + searchText + "%";
                params = new Object[]{userAllData.getCompanyId(), categoryId, searchPattern, page * size, size};
                countParams = new Object[]{userAllData.getCompanyId(), categoryId, searchPattern};
            }
        }

        List<ResponseCommonNameAndCodeDTO> data = mainJdbcTemplate.query(sql, params, (rs, rowNum) -> {
            ResponseCommonNameAndCodeDTO dto = new ResponseCommonNameAndCodeDTO();
            dto.setCode(rs.getString("SubCatCode"));
            dto.setName(rs.getString("SubCatName"));
            return dto;
        });

        Long count = mainJdbcTemplate.queryForObject(countSql, countParams, Long.class);

        return PaginatedResponseSubCategoryDTO.builder()
                .data(data)
                .count(count)
                .build();
    }
}
