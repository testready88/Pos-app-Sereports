package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.supplierdto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;

@Data
@RequiredArgsConstructor
@AllArgsConstructor
@Builder
public class ResponseSupplierDTO {
    private String code;
    private String name;
}
