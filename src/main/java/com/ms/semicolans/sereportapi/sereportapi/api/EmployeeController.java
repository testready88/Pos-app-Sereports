package com.ms.semicolans.sereportapi.sereportapi.api;

import java.sql.SQLException;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated.PaginatedResponseEmployeeDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.EmployeeService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/employees")
@RequiredArgsConstructor
public class EmployeeController {

    private final EmployeeService employeeService;

    //////removed preauthorize
    @GetMapping(path = "/employee-details", params = {"page", "size"})
    public ResponseEntity<StandardResponse> getEmployeeDetails(
            @RequestParam int page,
            @RequestParam int size,
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false) String searchText) throws SQLException {

        PaginatedResponseEmployeeDTO response = employeeService.getEmployeeDetails(
                token,
                searchText,
                page,
                size
        );

        return ResponseEntity.ok(
                new StandardResponse(
                        200,
                        "Employee details retrieved successfully",
                        response
                )
        );
    }
}