package com.ms.semicolans.sereportapi.sereportapi.api;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCommonNameAndCodeDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseCreditorsDetailsDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponsePayableDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.SupplierService;
import com.ms.semicolans.sereportapi.sereportapi.service.impl.SupplierServiceImpl;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/suppliers")
@RequiredArgsConstructor
public class SupplierController {
    private final SupplierService supplierService;
    private final SupplierServiceImpl supplierServiceImpl;

    //////removed preauthorize
    @GetMapping(path = {"/get-all-suppliers-name-list"}, params = {"searchText"})
    public ResponseEntity<StandardResponse> getAllSuppliersNameList(@RequestParam String searchText, @RequestHeader("Authorization") String token) throws SQLException {

        List<ResponseCommonNameAndCodeDTO> supplierDTOList = supplierService.getAllSuppliersNameList(searchText, token);
        return new ResponseEntity<>(
                new StandardResponse(200,
                        "All Suppliers list", supplierDTOList),
                HttpStatus.OK
        );
    }

    //////removed preauthorize
    @GetMapping(path = {"/get-all-suppliers"}, params = {"searchText"})
    public void getAllSuppliers(@RequestParam String searchText, @RequestHeader("Authorization") String token) throws SQLException, IOException {
        System.out.println("suppler" + searchText);

        supplierService.getSupplierData(searchText, token);
    }
    //////removed preauthorize
    @GetMapping(path = "/supplier-details", params = {"page", "size"})
    public ResponseEntity<StandardResponse> getSupplierDetails(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false) String supplierSearch,
            @RequestParam(required = false) String creditSearch,
            @RequestParam(required = false, defaultValue = "All") String invGap,
            @RequestParam(required = false, defaultValue = "All") String settlementGap) throws SQLException {
        System.out.println(page + " " + size + " " + supplierSearch + " " + creditSearch + " " + invGap + " " + settlementGap);
        PaginatedResponseCreditorsDetailsDTO response = supplierService.getAllSuppliersList(
                supplierSearch,
                creditSearch,
                invGap,
                settlementGap,
                page,
                size,
                token
        );
        System.out.println(response.getCount());
        System.out.println(response.getTotalOutstandingAmount());
        return new ResponseEntity<>(
                new StandardResponse(
                        200,
                        "Supplier details retrieved successfully",
                        response
                ),
                HttpStatus.OK
        );
    }

    //////removed preauthorize
    @GetMapping(path = "/payable-details", params = {"page", "size"})
    public ResponseEntity<StandardResponse> getPayableDetails(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false, defaultValue = "All") String locaCode,
            @RequestParam(required = false) String searchSupplier,
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

        PaginatedResponsePayableDTO response = supplierService.getPayableDetails(
                token,
                locaCode,
                searchSupplier,
                searchInvoice,
                invGap,
                dateFrom,
                dateTo,
                page,
                size
        );

        System.out.println(page);
        System.out.println(response.getCount());
        return new ResponseEntity<>(new StandardResponse(
                200,
                "Payable details retrieved successfully",
                response
        ), HttpStatus.OK);
    }

}
