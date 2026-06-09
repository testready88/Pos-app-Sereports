package com.ms.semicolans.sereportapi.sereportapi.api;

import java.sql.SQLException;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCreditorsDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.SupplierCreditorService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;
@RestController
@RequestMapping("/api/v1/suppliers-creditor")
@RequiredArgsConstructor
public class SupplierCreditorController {
    private final SupplierCreditorService supplierCreditorService;

    //////removed preauthorize
    @GetMapping(path = {"/get-creditor-details-list"}, params = {"page", "size"})
    public ResponseEntity<StandardResponse> getSupplierDetails(
            @RequestParam(required = false) String supplierSearch,
            @RequestParam(required = false) String creditSearch,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false, defaultValue = "All") String invGap,
            @RequestParam(required = false, defaultValue = "All") String settlementGap,
            @RequestHeader("Authorization") String token) throws SQLException {
        System.out.println(page);
        PaginatedResponseCreditorsDetailsDTO response =    supplierCreditorService.getCreditorsDetailsList(
                supplierSearch, creditSearch, invGap, settlementGap, page, size, token
        );
        System.out.println(response.getCount());
        return new ResponseEntity<>(new StandardResponse(
                200,
                "Supplier Details",response

        ), HttpStatus.OK);
    }
}
