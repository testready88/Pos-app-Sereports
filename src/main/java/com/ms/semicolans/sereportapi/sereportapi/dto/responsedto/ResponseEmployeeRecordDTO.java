package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

@Data
@AllArgsConstructor
@RequiredArgsConstructor
@Builder
public class ResponseEmployeeRecordDTO {
    private String employeeId;
    private String Group;
    private String Category;
    private String name;
    private String address;
    private String contact;
}
