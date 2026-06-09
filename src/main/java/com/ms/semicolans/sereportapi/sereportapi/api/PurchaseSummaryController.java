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

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponsePurchaseSummaryDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.PurchaseSummaryService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/purchase-summary")
@RequiredArgsConstructor
public class PurchaseSummaryController {
    private final PurchaseSummaryService purchaseSummaryService;

    //////removed preauthorize
    @GetMapping(path = "/summary-details", params = {"page", "size"})
    public ResponseEntity<StandardResponse> getPurchaseSummary(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false, defaultValue = "All") String locaCode,
            @RequestParam(required = false, defaultValue = "") String searchSupplier,
            @RequestParam(required = false, defaultValue = "") String searchInvoice,
            @RequestParam(required = false, defaultValue = "All") String paymentType,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo) throws SQLException {

        // If dates are not provided, set defaults
        if (dateFrom == null) {
            dateFrom = LocalDate.now();
        }
        if (dateTo == null) {
            dateTo = LocalDate.now(); // Default to today
        }
        PaginatedResponsePurchaseSummaryDTO response = purchaseSummaryService.getPurchaseSummary(
                token, locaCode, searchSupplier, searchInvoice, paymentType,
                dateFrom, dateTo, page, size
        );

        return new ResponseEntity<>(new StandardResponse(
                200,
                "Purchase summary retrieved successfully",
                response
        ), HttpStatus.OK);
    }
}