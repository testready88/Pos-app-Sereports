package com.ms.semicolans.sereportapi.sereportapi.service.impl;


import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.*;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCategoryDTO;
import com.ms.semicolans.sereportapi.sereportapi.entity.main.Category;
import com.ms.semicolans.sereportapi.sereportapi.repo.CategoryRepo;
import com.ms.semicolans.sereportapi.sereportapi.service.CategoryService;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.domain.PageRequest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {
    private final CompanyUserService companyUserService;

    @Qualifier("mainJdbcTemplate")
    private final JdbcTemplate mainJdbcTemplate;
    private final CategoryRepo categoryRepo;

    @Override
    public PaginatedResponseCategoryDTO getCategories(String searchText, int page, int size) {
        List<ResponseCategoryDTO> collect = categoryRepo.getCategories(searchText, PageRequest.of(page, size))
                .stream().map(this::converter).toList();
        long count = categoryRepo.countBrands(searchText);

        return PaginatedResponseCategoryDTO.builder().data(collect).count(count).build();
    }

    @Override
    public List<ResponseCommonNameAndCodeDTO> getAllCategoryNameList(String searchText, String token) throws SQLException {
        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);

        String sql;
        Object[] params;

        if (searchText == null || searchText.trim().isEmpty()) {
            // If search text is empty, just filter by compId
            sql = "SELECT CatCode, CatName FROM tbl_CatDet WHERE CompId = ? ORDER BY CatName";
            params = new Object[]{userAllData.getCompanyId()};
        } else {
            // If search text is provided, filter by both compId and name (using LIKE)
            sql = "SELECT CatCode, CatName FROM tbl_CatDet WHERE CompId = ? AND CatName LIKE ? ORDER BY CatName";
            String searchPattern = "%" + searchText + "%";
            params = new Object[]{userAllData.getCompanyId(), searchPattern};
        }

        List<ResponseCommonNameAndCodeDTO> data = mainJdbcTemplate.query(sql, params, (rs, rowNum) -> {
            ResponseCommonNameAndCodeDTO dto = new ResponseCommonNameAndCodeDTO();
            dto.setCode(rs.getString("CatCode"));
            dto.setName(rs.getString("CatName"));
            return dto;
        });

        return data;
    }

    public PaginatedResponseCategoryDTO getAllCategoryName(String searchText, String token, int size, int page) throws SQLException {
        ResponseCompanyUserDataDTO userAllData = companyUserService.getUserAllData(token);

        String sql;
        String countSql;
        Object[] params;
        Object[] countParams;

        if (searchText == null || searchText.trim().isEmpty()) {
            // If search text is empty, just filter by compId
            sql = "SELECT CatCode, CatName FROM tbl_CatDet WHERE CompId = ? ORDER BY CatName OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            countSql = "SELECT count(*) FROM tbl_CatDet WHERE CompId = ?";
            params = new Object[]{userAllData.getCompanyId(), page * size, size};
            countParams = new Object[]{userAllData.getCompanyId()};
        } else {
            // If search text is provided, filter by both compId and name (using LIKE)
            sql = "SELECT CatCode, CatName FROM tbl_CatDet WHERE CompId = ? AND CatName LIKE ? ORDER BY CatName OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            countSql = "SELECT count(*) FROM tbl_CatDet WHERE CompId = ? AND CatName LIKE ?";
            String searchPattern = "%" + searchText + "%";
            params = new Object[]{userAllData.getCompanyId(), searchPattern, page * size, size};
            countParams = new Object[]{userAllData.getCompanyId(),searchPattern};
        }

        List<ResponseCategoryDTO> data = mainJdbcTemplate.query(sql, params, (rs, rowNum) -> {
            ResponseCategoryDTO dto = new ResponseCategoryDTO();
            dto.setCode(rs.getString("CatCode"));
            dto.setName(rs.getString("CatName"));
            return dto;
        });

        Long count = mainJdbcTemplate.queryForObject(countSql, countParams, Long.class);

        return PaginatedResponseCategoryDTO.builder()
                .data(data)
                .count(count)
                .build();
    }

    private ResponseCategoryDTO converter(Category category) {

        return ResponseCategoryDTO.builder()
                .id(category.getId())
                .code(category.getCode())
                .name(category.getName())
                .build();

    }


}
