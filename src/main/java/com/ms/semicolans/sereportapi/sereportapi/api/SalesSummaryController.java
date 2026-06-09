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

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseSalesSummaryDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.SalesSummaryService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;
@RestController
@RequestMapping("/api/v1/sales-summary")
@RequiredArgsConstructor
public class SalesSummaryController {

    private final SalesSummaryService salesSummaryService;

    //////removed preauthorize
    @GetMapping(path = "/summary-details", params = {"page", "size"})
    public ResponseEntity<StandardResponse> getSalesSummary(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false, defaultValue = "All") String locaCode,
            @RequestParam(required = false) String searchCustomer,
            @RequestParam(required = false, defaultValue = "All") String paymentType,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo) throws SQLException {

        // Convert dates to simple string format
        String dateFromString = (dateFrom == null) ?
                LocalDate.now().toString() : dateFrom.toString();
        String dateToString = (dateTo == null) ?
                LocalDate.now().toString() : dateTo.toString();

        System.out.println("Controller - DateFrom: " + dateFromString);
        System.out.println("Controller - DateTo: " + dateToString);

        PaginatedResponseSalesSummaryDTO response = salesSummaryService.getSalesSummary(
                token,
                locaCode,
                searchCustomer,
                paymentType,
                dateFromString,  // "2024-05-21"
                dateToString,    // "2025-05-21"
                page,
                size
        );

        return new ResponseEntity<>(
                new StandardResponse(
                        200,
                        "Sales summary retrieved successfully",
                        response
                ),
                HttpStatus.OK
        );
    }
}
