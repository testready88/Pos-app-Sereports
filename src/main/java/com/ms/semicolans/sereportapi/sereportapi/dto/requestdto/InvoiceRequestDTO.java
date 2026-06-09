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
public class InvoiceRequestDTO {
    private String itemBarcode;
    private String itemCode;
    private String serialNo;
    private String locaCode;
    private String compId;
    private BigDecimal qty;
    private String invType;
    private String customerCode;
    private String priceLink;
    private String currentUOM;
    private Boolean updateMode;
    private Boolean itemPriceShortCutMode;
    private String stockId;
    private BigDecimal itemUPrice;
    private BigDecimal itemSPrice;
    private BigDecimal itemDPrice;
    private String reason;
    private String priceChangeApprovedBy;
    private String isPriceChange;
    private String priceChangeType;
}

