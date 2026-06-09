package com.ms.semicolans.sereportapi.sereportapi.api;

import com.ms.semicolans.sereportapi.sereportapi.service.BankDetailsService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/bank-details")
@RequiredArgsConstructor
public class BankDetailsController {
    private final BankDetailsService bankDetailsService;

    @GetMapping(path = {"/get-all-bank-names"})
    public ResponseEntity<StandardResponse> getAllBankNames
            (@RequestHeader("Authorization") String token) throws SQLException {
        return new ResponseEntity<>(
                new StandardResponse(200, "All Bank Names", bankDetailsService.getAllBankNames(token))
                , HttpStatus.OK);
    }


    @GetMapping(path = {"/get-all-bank-details"})
    public ResponseEntity<StandardResponse> getBankDetails

            (@RequestParam(required = false, defaultValue = "All") String bankName,
             @RequestParam(required = false, defaultValue = "All") String locationCode,
             @RequestParam String dateTo, @RequestHeader("Authorization") String token) throws SQLException {
        return new ResponseEntity<>(
                new StandardResponse(200, "All Bank Details", bankDetailsService.getBankDetails(token,bankName,locationCode,dateTo))
                , HttpStatus.OK);
    }
}
