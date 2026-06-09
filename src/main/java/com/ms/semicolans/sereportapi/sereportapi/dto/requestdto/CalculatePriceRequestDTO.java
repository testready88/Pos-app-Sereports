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
public class CalculatePriceRequestDTO {
    private String itemCode;
    private String itemBarcode;
    private String locaCode;
    private BigDecimal qty;
    private String priceType; // RETAIL, WHOLESALE, CATEGORY1-5
    private String customerCode;
    private BigDecimal itemUPrice;
    private BigDecimal itemSPrice;
    private BigDecimal itemDPrice;
    private BigDecimal itemWPrice;
    private BigDecimal itemOPrice;
    private BigDecimal itemLDPrice;
    private BigDecimal itemMPrice;
    private BigDecimal itemCusCatPrice1;
    private BigDecimal itemCusCatPrice2;
    private BigDecimal itemCusCatPrice3;
    private BigDecimal itemCusCatPrice4;
    private BigDecimal itemCusCatPrice5;
    private Boolean askOfferDate;
    private Boolean askDiscountDate;
    private Boolean askWholeSaleDate;
    private Boolean cusPriceWithoutPriceLink;
    private Boolean prevCusPrice;
}

