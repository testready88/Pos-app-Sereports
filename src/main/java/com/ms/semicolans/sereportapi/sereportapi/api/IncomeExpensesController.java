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

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseExpensesDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.ExpensesService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/income-expenses")
@RequiredArgsConstructor
public class IncomeExpensesController {
    private final ExpensesService expensesService;

    //////removed preauthorize
    @GetMapping(path = "/details")
    public ResponseEntity<StandardResponse> getExpensesDetails(
            @RequestParam(required = false, defaultValue = "All") String locaCode,
            @RequestParam(required = false, defaultValue = "") String searchDescription,
            @RequestParam(required = false, defaultValue = "") String searchVendor,
            @RequestParam(required = false, defaultValue = "All") String invType,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateTo,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "10") int size,
            @RequestHeader("Authorization") String token) throws SQLException {

        // If dates are not provided, default to current date for both
        if (dateFrom == null) {
            dateFrom = LocalDate.now();
        }
        if (dateTo == null) {
            dateTo = LocalDate.now(); // Default to today
        }

        PaginatedResponseExpensesDTO expensesDetails = expensesService.getPaginatedExpensesDetails(
                locaCode,
                searchDescription,
                searchVendor,
                invType,
                dateFrom,
                dateTo,
                token,
                page,
                size
        );

        return new ResponseEntity<>(
                new StandardResponse(200, "Expenses Data", expensesDetails),
                HttpStatus.OK);
    }
}