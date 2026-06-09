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

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseSalesDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.SalesService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/sales")
@RequiredArgsConstructor
public class SalesController {
    private final SalesService salesService;

    //////removed preauthorize
    @GetMapping(path = "/sales-details", params = {"page", "size"})
    public ResponseEntity<StandardResponse> getSalesDetails(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false, defaultValue = "All") String locaCode,
            @RequestParam(required = false) String searchItem,
            @RequestParam(required = false) String searchCategory,
            @RequestParam(required = false) String searchSupplier,
            @RequestParam(required = false, defaultValue = "All") String salesType,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo) throws SQLException {

        // If dates are not provided, set to current date
        if (dateFrom == null) {
            dateFrom = LocalDate.now();
        }
        if (dateTo == null) {
            dateTo = LocalDate.now(); // Default to today
        }

        System.out.println("Controller - DateFrom: " + dateFrom);
        System.out.println("Controller - DateTo: " + dateTo);

        PaginatedResponseSalesDTO response = salesService.getSalesDetails(
                token,
                locaCode,
                searchItem,
                searchCategory,
                searchSupplier,
                salesType,
                dateFrom,
                dateTo,
                page,
                size
        );

        return new ResponseEntity<>(
                new StandardResponse(
                        200,
                        "Sales details retrieved successfully",
                        response
                ),
                HttpStatus.OK
        );
    }
}
