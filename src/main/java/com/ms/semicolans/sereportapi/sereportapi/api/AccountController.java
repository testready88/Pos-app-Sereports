package com.ms.semicolans.sereportapi.sereportapi.api;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseChqDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.AccountQueryService;
import com.ms.semicolans.sereportapi.sereportapi.service.AccountsChqService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/accounts")
@RequiredArgsConstructor
public class AccountController {
    private final AccountQueryService accountQueryService;
    private final AccountsChqService accountsChqService;

    @GetMapping("/asset-ledger")
    public ResponseEntity<StandardResponse> getAssetLedger(@RequestParam String filters, @RequestHeader("Authorization") String token) throws SQLException {
        return ResponseEntity.ok(new StandardResponse(200, "OK", Map.of("data", accountQueryService.getAssetLedger(filters, token))));
    }

    @GetMapping("/asset-summary")
    public ResponseEntity<StandardResponse> getAssetSummary(@RequestParam String filters, @RequestHeader("Authorization") String token) throws SQLException {
        Map<String, Object> result = new HashMap<>();
        result.put("totals", accountQueryService.getAssetSummary(filters, token));
        result.put("data", accountQueryService.getAssetBreakdown(filters, token));
        return ResponseEntity.ok(new StandardResponse(200, "OK", result));
    }

    @GetMapping("/capital-ledger")
    public ResponseEntity<StandardResponse> getCapitalLedger(@RequestParam String filters, @RequestHeader("Authorization") String token) throws SQLException {
        return ResponseEntity.ok(new StandardResponse(200, "OK", Map.of("data", accountQueryService.getCapitalLedger(filters, token))));
    }

    @GetMapping("/capital-summary")
    public ResponseEntity<StandardResponse> getCapitalSummary(@RequestParam String filters, @RequestHeader("Authorization") String token) throws SQLException {
        Map<String, Object> result = new HashMap<>();
        result.put("totals", accountQueryService.getCapitalSummary(filters, token));
        result.put("data", accountQueryService.getCapitalBreakdown(filters, token));
        return ResponseEntity.ok(new StandardResponse(200, "OK", result));
    }

    @GetMapping("/card-accounts")
    public ResponseEntity<StandardResponse> getCardAccounts(@RequestParam(defaultValue = "") String filters, @RequestHeader("Authorization") String token) throws SQLException {
        return ResponseEntity.ok(new StandardResponse(200, "OK", Map.of("data", accountQueryService.getCardAccounts(filters, token))));
    }

    @GetMapping("/card-ledger")
    public ResponseEntity<StandardResponse> getCardLedger(@RequestParam(defaultValue = "") String filters, @RequestHeader("Authorization") String token) throws SQLException {
        return ResponseEntity.ok(new StandardResponse(200, "OK", Map.of("data", accountQueryService.getCardLedger(filters, token))));
    }

    @GetMapping("/cash-accounts")
    public ResponseEntity<StandardResponse> getCashAccounts(@RequestParam(defaultValue = "") String filters, @RequestHeader("Authorization") String token) throws SQLException {
        return ResponseEntity.ok(new StandardResponse(200, "OK", Map.of("data", accountQueryService.getCashAccounts(filters, token))));
    }

    @GetMapping("/cash-ledger")
    public ResponseEntity<StandardResponse> getCashLedger(@RequestParam(defaultValue = "") String filters, @RequestHeader("Authorization") String token) throws SQLException {
        return ResponseEntity.ok(new StandardResponse(200, "OK", Map.of("data", accountQueryService.getCashLedger(filters, token))));
    }

    @GetMapping("/liability-ledger")
    public ResponseEntity<StandardResponse> getLiabilityLedger(@RequestParam String filters, @RequestHeader("Authorization") String token) throws SQLException {
        return ResponseEntity.ok(new StandardResponse(200, "OK", Map.of("data", accountQueryService.getLiabilityLedger(filters, token))));
    }

    @GetMapping("/liability-summary")
    public ResponseEntity<StandardResponse> getLiabilitySummary(@RequestParam String filters, @RequestHeader("Authorization") String token) throws SQLException {
        Map<String, Object> result = new HashMap<>();
        result.put("totals", accountQueryService.getLiabilitySummary(filters, token));
        result.put("data", accountQueryService.getLiabilityBreakdown(filters, token));
        return ResponseEntity.ok(new StandardResponse(200, "OK", result));
    }

    @GetMapping("/chq-ledger")
    public ResponseEntity<StandardResponse> getChqLedger(
            @RequestParam(defaultValue = "All") String locaCode,
            @RequestParam(defaultValue = "All") String bankName,
            @RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate dateFrom,
            @RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate dateTo,
            @RequestParam(defaultValue = "") String searchRef,
            @RequestParam(defaultValue = "") String chqNo,
            @RequestParam(defaultValue = "ALL") String chqType,
            @RequestParam(defaultValue = "ALL") String statusFilter,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "500") int size,
            @RequestHeader("Authorization") String token) throws SQLException {
        PaginatedResponseChqDTO response = accountsChqService.getAllCheques(locaCode, bankName, dateFrom, dateTo, searchRef, chqNo, chqType, statusFilter, page, size, token);
        return ResponseEntity.ok(new StandardResponse(200, "Cheque data retrieved successfully", response));
    }

    @PostMapping("/card-adjust-balance")
    public ResponseEntity<StandardResponse> adjustCardBalance(@RequestBody Map<String, Object> body, @RequestHeader("Authorization") String token) {
        try {
            accountQueryService.adjustCardBalance(body, token);
            return ResponseEntity.ok(new StandardResponse(200, "Card account balance adjusted successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new StandardResponse(400, "Failed: " + e.getMessage(), null));
        }
    }
}
