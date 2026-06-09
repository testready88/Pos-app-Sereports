package com.ms.semicolans.sereportapi.sereportapi.api;

import java.sql.SQLException;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCustomerRecordeDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.impl.CustomerServiceImpl;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("api/v1/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerServiceImpl customerService;

    //////removed preauthorize
    @GetMapping(path = {"/get-customers-details"})
    public ResponseEntity<StandardResponse> getCustomerDetails(
            @RequestParam(required = false) String searchText,
            @RequestParam(required = false, defaultValue = "All") String invGap,
            @RequestParam(required = false, defaultValue = "false") boolean filterCreditAmount,
            @RequestParam(required = false, defaultValue = "All") String settlement,
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token
    ) throws SQLException {

        PaginatedResponseCustomerRecordeDTO response = customerService.getCustomerDetails(
                token,
                searchText,
                filterCreditAmount,
                invGap,
                settlement,
                page,
                size
        );

        return new ResponseEntity<>(
                new StandardResponse(
                        HttpStatus.OK.value(),
                        "Customer details",
                        response
                ),
                HttpStatus.OK
        );
    }

    //////removed preauthorize
    @GetMapping(path = {"/get-debtor-details"})
    public ResponseEntity<StandardResponse> getDebtorDetails(
            @RequestParam(required = false) String searchText,
            @RequestParam(required = false, defaultValue = "All") String invGap,
            @RequestParam(required = false, defaultValue = "All") String settlement,
            @RequestParam(required = false) String creditAmount,
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token
    ) throws SQLException {

        PaginatedResponseCustomerRecordeDTO response = customerService.getDebtorsDetails(
                token,
                searchText,
                creditAmount,
                invGap,
                settlement,
                page,
                size
        );

        return new ResponseEntity<>(
                new StandardResponse(
                        HttpStatus.OK.value(),
                        "Debtor details",
                        response
                ),
                HttpStatus.OK
        );
    }
}