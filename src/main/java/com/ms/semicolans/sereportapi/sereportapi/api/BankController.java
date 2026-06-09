package com.ms.semicolans.sereportapi.sereportapi.api;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseBankDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseBankTransactionDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseChqTransactionDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.impl.BankServiceImpl;
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
@RequestMapping("/api/v1/banking")
@RequiredArgsConstructor
public class BankController {

    private final BankServiceImpl bankService;

    @GetMapping(path = {"/get-all-bank-names"})
    public ResponseEntity<StandardResponse> getAllBankDetails
            (@RequestHeader("Authorization") String token) throws SQLException {
        return new ResponseEntity<>(
                new StandardResponse(200, "All Bank Names", bankService.getBankDetails(token))
                , HttpStatus.OK);
    }

    @GetMapping(path = "/bank-details-with-summary", params = {"page", "size", "locaCode", "bank", "dateTo"})
    public ResponseEntity<StandardResponse> getBankDetailsWithSummary(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false, defaultValue = "All") String locaCode,
            @RequestParam(required = false, defaultValue = "All") String bank,
            @RequestParam  String dateTo) throws SQLException {

        PaginatedResponseBankDetailsDTO response = bankService.getBankDetailsWithSummary(
                token,
                locaCode,
                bank,
                dateTo,
                page,
                size
        );

        return ResponseEntity.ok(
                new StandardResponse(
                        200,
                        "Bank details with summary",
                        response
                )
        );
    }

    @GetMapping(path = "/bank-transaction-details", params = {"page", "size"})
    public ResponseEntity<StandardResponse> getBankTransactions(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false, defaultValue = "All") String locaCode,
            @RequestParam(required = false, defaultValue = "All") String bankName,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo,
            @RequestParam(required = false) String searchText) throws SQLException {

        System.out.println(searchText);

        PaginatedResponseBankTransactionDTO response = bankService.getBankTransactions(
                token,
                locaCode,
                bankName,
                dateFrom,
                dateTo,
                searchText,
                page,
                size
        );


        return new ResponseEntity<>(new StandardResponse(
                200,
                "   \"Bank transactions retrieved successfully\",",
                response
        ), HttpStatus.OK);
    }

    @GetMapping(path = "/cheque-transaction-details", params = {"page", "size"})
    public ResponseEntity<StandardResponse> getChqTransactions(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false, defaultValue = "All") String locaCode,
            @RequestParam(required = false, defaultValue = "All") String bankName,
            @RequestParam(required = false, defaultValue = "false") Boolean dateFilter,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo,
            @RequestParam(required = false) String searchRef,
            @RequestParam(required = false) String searchChqNo,
            @RequestParam(required = false, defaultValue = "All") String chqType) throws SQLException {

        PaginatedResponseChqTransactionDTO response = bankService.getChqTransactionDetails(
                token,
                locaCode,
                bankName,
                dateFilter,
                dateTo != null ? dateTo.toString() : null,
                searchRef,
                searchChqNo,
                chqType,
                page,
                size
        );


        return new ResponseEntity<>(new StandardResponse(
                200,
                "Cheque transactions Details",
                response
        ), HttpStatus.OK);
    }
}
