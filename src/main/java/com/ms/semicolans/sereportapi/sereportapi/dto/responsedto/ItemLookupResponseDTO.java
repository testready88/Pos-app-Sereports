package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ItemLookupResponseDTO {
    private String itemCode;
    private String itemBarcode;
    private String itemBarcode1;
    private String itemBarcode2;
    private String itemBarcode3;
    private String itemBarcode4;
    private String itemName;
    private String itemName1;
    private String itemName2;
    private String itemCatCode;
    private String itemCatName;
    private String itemSubCatCode1;
    private String itemSubCatName1;
    private String itemSubCatCode2;
    private String itemSubCatName2;
    private String itemType;
    private String partNo1;
    private String partNo2;
    private String partNo3;
    private String partNo4;
    private String itemMake;

    // Flags
    private boolean offer;
    private boolean askSerialNoOnInvoice;
    private boolean zeroPrice;
    private boolean discount;
    private boolean wholeSale;
    private boolean lessMPrice;
    private boolean greaterSPrice;
    private boolean lessUPrice;
    private boolean allowDecimal;
    private boolean autoDelPriceLink;
    private boolean allowLoyaltyPoints;
    private boolean allowEditOnInv;
    private boolean showPriceLink;
    private boolean freezeItem;

    // Quantities / Pricing references
    private BigDecimal offerQty;
    private BigDecimal discountQty;
    private BigDecimal wsQty;

    // Validity dates
    private LocalDate offerValidTill;
    private LocalDate zeroPriceValidTill;
    private LocalDate discountValidTill;
    private LocalDate wholeSaleValidTill;
    private LocalDate lessMPriceValidTill;
    private LocalDate greaterSPriceValidTill;
    private LocalDate lessUPriceValidTill;

    // Discounts allowed
    private boolean allowCashDiscount;
    private boolean allowCusDiscount;
    private boolean allowStaffDiscount;

    // UOMs
    private String uom0;
    private String uom1;
    private String uom2;

    // Price links
    private List<PriceLinkResponseDTO> priceLinks;
    
    // Free quantity ranges
    private BigDecimal freeQty1;
    private BigDecimal freeQty2;
    private BigDecimal freeQty3;
    private BigDecimal freeIssueQty1;
    private BigDecimal freeIssueQty2;
    private BigDecimal freeIssueQty3;
    
    // Discount ranges
    private Boolean discountRange;
    private BigDecimal discountQty1;
    private BigDecimal discountQty2;
    private BigDecimal discountQty3;
    private BigDecimal discountQty4;
    private BigDecimal discountQty5;
    
    // Offer ranges
    private Boolean offerRange;
    private BigDecimal offerQty1;
    private BigDecimal offerQty2;
    private BigDecimal offerQty3;
    private BigDecimal offerQty4;
    private BigDecimal offerQty5;
    
    // Wholesale ranges
    private Boolean wsRange;
    private BigDecimal wsQty1;
    private BigDecimal wsQty2;
    private BigDecimal wsQty3;
    private BigDecimal wsQty4;
    private BigDecimal wsQty5;
    
    // Price ranges from selected price link (will be populated when price link is selected)
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







