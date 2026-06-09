package com.ms.semicolans.sereportapi.sereportapi.dto.requestdto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class InvoiceItemCreateDTO {
    private String itemCode;
    private String itemBarcode;
    private String stockId;
    private BigDecimal qty;
    private BigDecimal itemUPrice;
    private BigDecimal itemSPrice;
    private BigDecimal itemDPrice;
    private String invType;
    private String priceCategory; // RETAIL, WHOLESALE, CATEGORY1-5, LOYALTY DISCOUNT
}


