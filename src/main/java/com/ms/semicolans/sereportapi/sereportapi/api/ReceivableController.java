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

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseReceivableDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.ReceivableService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/receivables")
@RequiredArgsConstructor
public class ReceivableController {
    private final ReceivableService receivableService;

    //////removed preauthorize
    @GetMapping(path = "/receivable-details", params = {"page", "size"})
    public ResponseEntity<StandardResponse> getReceivableDetails(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false, defaultValue = "All") String locaCode,
            @RequestParam(required = false) String searchCustomer,
            @RequestParam(required = false) String searchInvoice,
            @RequestParam(required = false, defaultValue = "All") String invGap,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo) throws SQLException {

        // If dates are not provided, set default values (12 months ago to current date)
        if (dateFrom == null) {
            dateFrom = LocalDate.now().minusMonths(12);
        }

        if (dateTo == null) {
            dateTo = LocalDate.now();
        }

        PaginatedResponseReceivableDTO response = receivableService.getReceivableDetails(
                token,
                locaCode,
                searchCustomer,
                searchInvoice,
                invGap,
                dateFrom,
                dateTo,
                page,
                size
        );


        return new ResponseEntity<>(new StandardResponse(
                200,
                "Receivable details retrieved successfully",
                response
        ), HttpStatus.OK);
    }
}
