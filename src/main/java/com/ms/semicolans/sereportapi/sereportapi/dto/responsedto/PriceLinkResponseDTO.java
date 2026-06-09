package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PriceLinkResponseDTO {
    private Long id;
    private String stockId;
    private BigDecimal itemUPrice;
    private BigDecimal itemSPrice;
    private BigDecimal itemDPrice;
    private BigDecimal itemWPrice;
    private BigDecimal itemLDPrice;
    private BigDecimal itemMPrice;
    private BigDecimal itemOPrice;
    private BigDecimal qtyRemain;
    private BigDecimal warMonth;
    private String itemSupName;
    private String itemSupCode;
    private LocalDate expDate;
    private BigDecimal unitChange;
    private BigDecimal unitChange0;
    private BigDecimal itemCusCatPrice1;
    private BigDecimal itemCusCatPrice2;
    private BigDecimal itemCusCatPrice3;
    private BigDecimal itemCusCatPrice4;
    private BigDecimal itemCusCatPrice5;
    private BigDecimal exCharges;
    private BigDecimal fixedGP;
    private BigDecimal fixedGPPer;
    private String itemDescriptionPriceLink;
    private BigDecimal itemAvgCost;
    
    private String itemCode;
    private String itemBarcode;
    private String itemName;
    private BigDecimal discountPrice1;
    private BigDecimal discountPrice2;
    private BigDecimal discountPrice3;
    private BigDecimal discountPrice4;
    private BigDecimal discountPrice5;
    private BigDecimal offerPrice1;
    private BigDecimal offerPrice2;
    private BigDecimal offerPrice3;
    private BigDecimal offerPrice4;
    private BigDecimal offerPrice5;
    private BigDecimal wsPrice1;
    private BigDecimal wsPrice2;
    private BigDecimal wsPrice3;
    private BigDecimal wsPrice4;
    private BigDecimal wsPrice5;
}

