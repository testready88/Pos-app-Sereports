package com.ms.semicolans.sereportapi.sereportapi.api;

import java.sql.SQLException;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseProductInventoryDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.impl.ProductServiceImpl;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("api/v1/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductServiceImpl productService;

    //////removed preauthorize
    @GetMapping(path = "/get-all-product")
    public ResponseEntity<StandardResponse> getFilteredProducts(
            @RequestParam(required = false) String searchProduct,
            @RequestParam(required = false) String categoryName,
            @RequestParam(required = false) String subCategoryName,
            @RequestParam(required = false) String supplierName,
            @RequestParam(required = false) String stockLevel,
            @RequestParam(required = false) String itemSaleType,
            @RequestParam(required = false) int page,
            @RequestParam(required = false) int size,
            @RequestHeader("Authorization") String token) throws SQLException{

            PaginatedResponseProductInventoryDTO filteredProducts = productService.getPaginatedInventoryItems(
                    searchProduct,
                    categoryName,
                    subCategoryName,
                    supplierName,
                    stockLevel,
                    itemSaleType,
                    token,
                    page,
                    size
            );
        System.out.println(page);
        System.out.println(filteredProducts.getCount());
            return new ResponseEntity<>(new StandardResponse(200, "Product Data", filteredProducts), HttpStatus.OK);

    }
}