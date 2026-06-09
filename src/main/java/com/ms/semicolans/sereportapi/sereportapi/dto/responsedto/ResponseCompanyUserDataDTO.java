package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.ArrayList;

@Data
@RequiredArgsConstructor
@AllArgsConstructor
@Builder
public class ResponseCompanyUserDataDTO {
    private String companyId;
    private String role;

}
