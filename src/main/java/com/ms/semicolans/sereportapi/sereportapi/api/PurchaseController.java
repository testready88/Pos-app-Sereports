package com.ms.semicolans.sereportapi.sereportapi.api;

import java.sql.SQLException;
import java.time.LocalDate;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponsePurchaseDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.PurchaseService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/purchases")
@RequiredArgsConstructor
public class PurchaseController {
    private final PurchaseService purchaseService;

    //////removed preauthorize
    @GetMapping(path = "/purchase-details", params = {"page", "size"})
    public ResponseEntity<StandardResponse> getPurchaseDetails(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false, defaultValue = "All") String locaCode,
            @RequestParam(required = false, defaultValue = "") String searchItem,
            @RequestParam(required = false, defaultValue = "") String searchCategory,
            @RequestParam(required = false, defaultValue = "") String searchSupplier,
            @RequestParam(required = false, defaultValue = "All") String purchaseType,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo) throws SQLException {



        // If dates are not provided, set defaults
        if (dateFrom == null) {
            dateFrom = LocalDate.now();
        }
        if (dateTo == null) {
            dateTo = LocalDate.now(); // Default to today
        }

        PaginatedResponsePurchaseDTO response = purchaseService.getPurchaseDetails(
                token, locaCode, searchItem, searchCategory, searchSupplier, purchaseType,
                dateFrom, dateTo, page, size
        );

        return new ResponseEntity<>(new StandardResponse(
                200,
                "Purchase details retrieved successfully",
                response
        ), HttpStatus.OK);
    }
}