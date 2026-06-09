package com.ms.semicolans.sereportapi.sereportapi.api;

import java.sql.SQLException;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCommonNameAndCodeDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseSubCategoryDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.SubCategoryService;
import com.ms.semicolans.sereportapi.sereportapi.service.impl.SubCategoryServiceImpl;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/sub-categories")
@RequiredArgsConstructor
public class SubCategoryController {
    private final SubCategoryService subCategoryService;
    private final SubCategoryServiceImpl subCategoryServiceImpl;

    //////removed preauthorize
    @GetMapping(path = {"/get-all-sub-category-name-list"}, params = {"searchText", "categoryId"})
    public ResponseEntity<StandardResponse> getAllSubCategoryNameList(@RequestParam String searchText, @RequestParam String categoryId, @RequestHeader("Authorization") String token) throws SQLException {

        List<ResponseCommonNameAndCodeDTO> supplierDTOList = subCategoryService.getAllSubCategoryNameList(searchText, categoryId, token);

        return new ResponseEntity<>(
                new StandardResponse(200,
                        "All Sub category list", supplierDTOList),
                HttpStatus.OK);

    }

    @PreAuthorize("hasRole('ROLE_ADMIN')")
    @GetMapping(path = {"/get-all-sub-category-names"}, params = {"searchText", "categoryId", "page", "size"})
    public ResponseEntity<StandardResponse> getAllSubCategoryNamesList(@RequestParam String searchText, @RequestParam String categoryId, int page, int size, @RequestHeader("Authorization") String token) throws SQLException {
        PaginatedResponseSubCategoryDTO dto = subCategoryServiceImpl.getAllSubCategoryName(searchText, categoryId, token, size, page);

        return new ResponseEntity<>(new StandardResponse(200, "All Paginated Sub category list", dto), HttpStatus.OK);
    }
}