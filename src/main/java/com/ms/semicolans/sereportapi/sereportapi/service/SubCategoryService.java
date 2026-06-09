package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCommonNameAndCodeDTO;

import java.sql.SQLException;
import java.util.List;

public interface SubCategoryService {
    List<ResponseCommonNameAndCodeDTO> getAllSubCategoryNameList(String searchText,String categoryId, String token) throws SQLException;
}
