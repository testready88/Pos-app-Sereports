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
public class ItemDetectionResponseDTO {
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
    private Boolean boolItemOffer;
    private Boolean boolAskSerialNoOnInvoice;
    private Boolean boolZeroPrice;
    private Boolean boolItemDiscount;
    private Boolean boolWholeSale;
    private Boolean boolLessMPrice;
    private Boolean boolGreaterSPrice;
    private Boolean boolLessUPrice;
    private Boolean boolAllowdecimal;
    private Boolean boolAutoDelPriceLink;
    private Boolean boolAllowLoyaltyPoints;
    private Boolean boolAllowEditOnInv;
    private Boolean boolShowPriceLink;
    private Boolean boolFreezItem;
    
    // Quantities
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
    private String chkAllowCashDiscount;
    private String chkAllowCusDiscount;
    private String chkAllowStaffDiscount;
    
    // UOMs
    private String uom0;
    private String uom1;
    private String uom2;
    private String currentUOM;
    
    // Free quantity ranges
    private Boolean boolFreeIssueRange;
    private BigDecimal freeQty1;
    private BigDecimal freeQty2;
    private BigDecimal freeQty3;
    private BigDecimal freeIssueQty1;
    private BigDecimal freeIssueQty2;
    private BigDecimal freeIssueQty3;
    
    // OWS ranges
    private Boolean discountRange;
    private BigDecimal discountQty1;
    private BigDecimal discountQty2;
    private BigDecimal discountQty3;
    private BigDecimal discountQty4;
    private BigDecimal discountQty5;
    
    private Boolean offerRange;
    private BigDecimal offerQty1;
    private BigDecimal offerQty2;
    private BigDecimal offerQty3;
    private BigDecimal offerQty4;
    private BigDecimal offerQty5;
    
    private Boolean wsRange;
    private BigDecimal wsQty1;
    private BigDecimal wsQty2;
    private BigDecimal wsQty3;
    private BigDecimal wsQty4;
    private BigDecimal wsQty5;
    
    // Price links
    private List<PriceLinkResponseDTO> priceLinks;
    
    // Which barcode was found
    private String foundBarcodeField; // ItemBarcode, ItemBarcode1, ItemBarcode2, etc.
    private Boolean itemExists;
}

