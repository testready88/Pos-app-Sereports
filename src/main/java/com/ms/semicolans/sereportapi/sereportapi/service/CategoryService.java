package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.*;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCategoryDTO;

import java.sql.SQLException;
import java.util.List;

public interface CategoryService {
    PaginatedResponseCategoryDTO getCategories(String searchText, int page, int size);

    List<ResponseCommonNameAndCodeDTO> getAllCategoryNameList(String searchText, String token) throws SQLException;
}
