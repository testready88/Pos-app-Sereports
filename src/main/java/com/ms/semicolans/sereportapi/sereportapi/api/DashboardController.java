package com.ms.semicolans.sereportapi.sereportapi.api;

import java.sql.SQLException;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ms.semicolans.sereportapi.sereportapi.service.DashboardService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/dashboards")
@RequiredArgsConstructor
public class DashboardController {
    private final DashboardService dashboardService;

    //////removed preauthorize
    @GetMapping(path = {"/summary"})
    public ResponseEntity<StandardResponse> getAllBankDetails
            (@RequestHeader("Authorization") String token, @RequestParam String dateFrom,
             @RequestParam String dateTo,
             @RequestParam String locationCode) throws SQLException {
        return new ResponseEntity<>(
                new StandardResponse(200, "All summary", dashboardService.getDashboardSummary(token,dateFrom, dateTo, locationCode))
                , HttpStatus.OK);
    }
}