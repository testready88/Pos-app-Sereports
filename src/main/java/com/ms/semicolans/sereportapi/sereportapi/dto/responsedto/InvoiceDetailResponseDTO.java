package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class InvoiceDetailResponseDTO {
    private String itemCode;
    private String itemBarcode;
    private String itemName;
    private String itemCatCode;
    private String itemCatName;
    private BigDecimal itemUPrice;
    private BigDecimal itemSPrice;
    private BigDecimal itemDPrice;
    private BigDecimal qty;
    private BigDecimal tPrice;
    private String invType;
    private String stockId;
}

