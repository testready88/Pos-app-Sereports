package com.ms.semicolans.sereportapi.sereportapi.api;


import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.*;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCategoryDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.CategoryService;
import com.ms.semicolans.sereportapi.sereportapi.service.impl.CategoryServiceImpl;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.List;

@RestController
@RequestMapping("/api/v1/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;
    private final CategoryServiceImpl categoryServiceImpl;

    @GetMapping(path = {"/visitor/get-all"}, params = {"page", "size", "searchText"})
    public ResponseEntity<StandardResponse> getCategories(@RequestParam String searchText, @RequestParam int page,
                                                          @RequestParam int size) {


        PaginatedResponseCategoryDTO dtoList = categoryService.getCategories(searchText, page, size);
        return new ResponseEntity<>(
                new StandardResponse(200,
                        "All Categories list", dtoList),
                HttpStatus.OK
        );
    }

    @GetMapping(path = {"/get-all-category-name-list"}, params = {"searchText"})
    public ResponseEntity<StandardResponse> getAllCategoryNameList(@RequestParam String searchText, @RequestHeader("Authorization") String token) throws SQLException {

        List<ResponseCommonNameAndCodeDTO> supplierDTOList = categoryService.getAllCategoryNameList(searchText, token);
        return new ResponseEntity<>(
                new StandardResponse(200,
                        "All category list", supplierDTOList),
                HttpStatus.OK     );

    }

    @GetMapping(path = {"/get-all-category-name"}, params = {"searchText", "page", "size"})
    public ResponseEntity<StandardResponse> getAllCategoryName(@RequestParam String searchText, int page, int size, @RequestHeader("Authorization") String token) throws SQLException {

        System.out.println("category" + searchText);
        PaginatedResponseCategoryDTO supplierDTOList = categoryServiceImpl.getAllCategoryName(searchText, token, size, page);
        return new ResponseEntity<>(
                new StandardResponse(200,
                        "All category list", supplierDTOList),
                HttpStatus.OK);

    }

}
