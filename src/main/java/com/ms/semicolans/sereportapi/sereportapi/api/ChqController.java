package com.ms.semicolans.sereportapi.sereportapi.api;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseChqDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.ChqService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/cheques")
@RequiredArgsConstructor
public class ChqController {
    private final ChqService chqService;


    @GetMapping(path = {"/chq-transactions"})
    public ResponseEntity<StandardResponse> getCheques(
            @RequestParam(defaultValue = "All") String locaCode,
            @RequestParam(defaultValue = "All") String bankName,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateTo,
            @RequestParam(defaultValue = "") String searchRef,
            @RequestParam(defaultValue = "") String chqNo,
            @RequestParam(defaultValue = "All") String chqType,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestHeader("Authorization") String token) throws SQLException {

        PaginatedResponseChqDTO response = chqService.getCheques(
                locaCode, bankName, dateTo, searchRef, chqNo, chqType, page, size, token);

        return ResponseEntity.ok(
                new StandardResponse(200, "Cheque data retrieved successfully", response)
        );
    }
}
