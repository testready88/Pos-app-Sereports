package com.ms.semicolans.sereportapi.sereportapi.dto.requestdto;

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
public class ItemPriceCalculationRequestDTO {
    // Item identification
    private String itemCode;
    private String itemBarcode;
    private String locaCode;
    private String stockId;
    
    // Quantity
    private BigDecimal qty;
    
    // Price type (RETAIL, WHOLESALE, CATEGORY1-5)
    private String priceType;
    
    // Customer information
    private String customerCode;
    private Boolean prevCusPrice;
    private Boolean cusPriceWithoutPriceLink;
    
    // Prices from selected price link
    private BigDecimal itemUPrice;
    private BigDecimal itemSPrice;
    private BigDecimal itemDPrice;
    private BigDecimal itemWPrice;
    private BigDecimal itemLDPrice;
    private BigDecimal itemMPrice;
    private BigDecimal itemOPrice;
    
    // Customer category prices
    private BigDecimal itemCusCatPrice1;
    private BigDecimal itemCusCatPrice2;
    private BigDecimal itemCusCatPrice3;
    private BigDecimal itemCusCatPrice4;
    private BigDecimal itemCusCatPrice5;
    
    // Date validation flags
    private Boolean askOfferDate;
    private Boolean askDiscountDate;
    private Boolean askWholeSaleDate;
    
    // Current date for validation
    private LocalDate currentDate;
    
    // Item flags (from ItemDetail)
    private Boolean boolItemOffer;
    private Boolean boolItemDiscount;
    private Boolean boolWholeSale;
    private Boolean boolCusDiscount;
    
    // Valid till dates
    private LocalDate offerValidTill;
    private LocalDate discountValidTill;
    private LocalDate wholeSaleValidTill;
    
    // OWS ranges (from PriceLink)
    private Boolean discountRange;
    private BigDecimal discountQty1;
    private BigDecimal discountQty2;
    private BigDecimal discountQty3;
    private BigDecimal discountQty4;
    private BigDecimal discountQty5;
    private BigDecimal discountPrice1;
    private BigDecimal discountPrice2;
    private BigDecimal discountPrice3;
    private BigDecimal discountPrice4;
    private BigDecimal discountPrice5;
    
    private Boolean offerRange;
    private BigDecimal offerQty1;
    private BigDecimal offerQty2;
    private BigDecimal offerQty3;
    private BigDecimal offerQty4;
    private BigDecimal offerQty5;
    private BigDecimal offerPrice1;
    private BigDecimal offerPrice2;
    private BigDecimal offerPrice3;
    private BigDecimal offerPrice4;
    private BigDecimal offerPrice5;
    
    private Boolean wsRange;
    private BigDecimal wsQty1;
    private BigDecimal wsQty2;
    private BigDecimal wsQty3;
    private BigDecimal wsQty4;
    private BigDecimal wsQty5;
    private BigDecimal wsPrice1;
    private BigDecimal wsPrice2;
    private BigDecimal wsPrice3;
    private BigDecimal wsPrice4;
    private BigDecimal wsPrice5;
    
    // Customer discount price (if applicable)
    private BigDecimal customerDiscountPrice;
}

