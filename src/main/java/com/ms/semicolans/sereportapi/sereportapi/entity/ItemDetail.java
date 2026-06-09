package com.ms.semicolans.sereportapi.sereportapi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "tbl_ItemDet")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ItemDetail {
    
    @Id
    @Column(name = "ItemCode", length = 50)
    private String itemCode;
    
    @Column(name = "ItemBarcode", length = 100)
    private String itemBarcode;
    
    @Column(name = "ItemBarcode1", length = 100)
    private String itemBarcode1;
    
    @Column(name = "ItemBarcode2", length = 100)
    private String itemBarcode2;
    
    @Column(name = "ItemBarcode3", length = 100)
    private String itemBarcode3;
    
    @Column(name = "ItemBarcode4", length = 100)
    private String itemBarcode4;
    
    @Column(name = "ItemName", length = 255)
    private String itemName;
    
    @Column(name = "ItemName1", length = 255)
    private String itemName1;
    
    @Column(name = "ItemName2", length = 255)
    private String itemName2;
    
    @Column(name = "ItemCatCode", length = 50)
    private String itemCatCode;
    
    @Column(name = "ItemCatName", length = 255)
    private String itemCatName;
    
    @Column(name = "ItemSubCatCode1", length = 50)
    private String itemSubCatCode1;
    
    @Column(name = "ItemSubCatName1", length = 255)
    private String itemSubCatName1;
    
    @Column(name = "ItemSubCatCode2", length = 50)
    private String itemSubCatCode2;
    
    @Column(name = "ItemSubCatName2", length = 255)
    private String itemSubCatName2;
    
    @Column(name = "ItemType", length = 50)
    private String itemType;
    
    @Column(name = "PartNo1", length = 100)
    private String partNo1;
    
    @Column(name = "PartNo2", length = 100)
    private String partNo2;
    
    @Column(name = "PartNo3", length = 100)
    private String partNo3;
    
    @Column(name = "PartNo4", length = 100)
    private String partNo4;
    
    @Column(name = "ItemMake", length = 255)
    private String itemMake;
    
    @Column(name = "chkOffer", length = 1)
    private String chkOffer;
    
    @Column(name = "AskSerialNoOnInvoice", length = 1)
    private String askSerialNoOnInvoice;
    
    @Column(name = "chkZeroPrice", length = 1)
    private String chkZeroPrice;
    
    @Column(name = "chkDiscount", length = 1)
    private String chkDiscount;
    
    @Column(name = "chkWholeSale", length = 1)
    private String chkWholeSale;
    
    @Column(name = "chkLessMPrice", length = 1)
    private String chkLessMPrice;
    
    @Column(name = "chkGreaterSPrice", length = 1)
    private String chkGreaterSPrice;
    
    @Column(name = "chkLessUPrice", length = 1)
    private String chkLessUPrice;
    
    @Column(name = "chkAllowdecimal", length = 1)
    private String chkAllowdecimal;
    
    @Column(name = "chkAutoDelPriceLink", length = 1)
    private String chkAutoDelPriceLink;
    
    @Column(name = "chkAllowLoyaltyPoints", length = 1)
    private String chkAllowLoyaltyPoints;
    
    @Column(name = "chkAllowEditOnInv", length = 1)
    private String chkAllowEditOnInv;
    
    @Column(name = "OfferQty", precision = 18, scale = 4)
    private BigDecimal offerQty;
    
    @Column(name = "DiscountQty", precision = 18, scale = 4)
    private BigDecimal discountQty;
    
    @Column(name = "WSQty", precision = 18, scale = 4)
    private BigDecimal wsQty;
    
    @Column(name = "chkShowPriceLink", length = 1)
    private String chkShowPriceLink;
    
    @Column(name = "OfferValidTill")
    private LocalDate offerValidTill;
    
    @Column(name = "ZeroPriceValidTill")
    private LocalDate zeroPriceValidTill;
    
                                                                                                                                                                                                                                                                                                                            @Column(name = "DiscountValidTill")
    private LocalDate discountValidTill;
    
    @Column(name = "WholeSaleValidTill")
    private LocalDate wholeSaleValidTill;
    
    @Column(name = "LessMPriceValidTill")
    private LocalDate lessMPriceValidTill;
    
    @Column(name = "GreaterSPriceValidTill")
    private LocalDate greaterSPriceValidTill;
    
    @Column(name = "LessUPriceValidTill")
    private LocalDate lessUPriceValidTill;
    
    @Column(name = "chkAllowCashDiscount", length = 1)
    private String chkAllowCashDiscount;
    
    @Column(name = "chkAllowCusDiscount", length = 1)
    private String chkAllowCusDiscount;
    
    @Column(name = "chkAllowStaffDiscount", length = 1)
    private String chkAllowStaffDiscount;
    
    @Column(name = "UOM1", length = 50)
    private String uom1;
    
    @Column(name = "UOM2", length = 50)
    private String uom2;
    
    @Column(name = "UOM0", length = 50)
    private String uom0;
    
    @Column(name = "chkActiveOfferRange", length = 1)
    private String chkActiveOfferRange;
    
    @Column(name = "chkActiveWSRange", length = 1)
    private String chkActiveWSRange;
    
    @Column(name = "chkActiveDiscountRange", length = 1)
    private String chkActiveDiscountRange;
    
    @Column(name = "chkFreezItem", length = 1)
    private String chkFreezItem;
    
    @Column(name = "ActiveItem", length = 1)
    private String activeItem;
    
    @Column(name = "FreeQty1", precision = 18, scale = 4)
    private BigDecimal freeQty1;
    
    @Column(name = "FreeQty2", precision = 18, scale = 4)
    private BigDecimal freeQty2;
    
    @Column(name = "FreeQty3", precision = 18, scale = 4)
    private BigDecimal freeQty3;
    
    @Column(name = "FreeIssueQty1", precision = 18, scale = 4)
    private BigDecimal freeIssueQty1;
    
    @Column(name = "FreeIssueQty2", precision = 18, scale = 4)
    private BigDecimal freeIssueQty2;
    
    @Column(name = "FreeIssueQty3", precision = 18, scale = 4)
    private BigDecimal freeIssueQty3;
    
    @Column(name = "DiscountQty1", precision = 18, scale = 4)
    private BigDecimal discountQty1;
    
    @Column(name = "DiscountQty2", precision = 18, scale = 4)
    private BigDecimal discountQty2;
    
    @Column(name = "DiscountQty3", precision = 18, scale = 4)
    private BigDecimal discountQty3;
    
    @Column(name = "DiscountQty4", precision = 18, scale = 4)
    private BigDecimal discountQty4;
    
    @Column(name = "DiscountQty5", precision = 18, scale = 4)
    private BigDecimal discountQty5;
    
    @Column(name = "OfferQty1", precision = 18, scale = 4)
    private BigDecimal offerQty1;
    
    @Column(name = "OfferQty2", precision = 18, scale = 4)
    private BigDecimal offerQty2;
    
    @Column(name = "OfferQty3", precision = 18, scale = 4)
    private BigDecimal offerQty3;
    
    @Column(name = "OfferQty4", precision = 18, scale = 4)
    private BigDecimal offerQty4;
    
    @Column(name = "OfferQty5", precision = 18, scale = 4)
    private BigDecimal offerQty5;
    
    @Column(name = "WSQty1", precision = 18, scale = 4)
    private BigDecimal wsQty1;
    
    @Column(name = "WSQty2", precision = 18, scale = 4)
    private BigDecimal wsQty2;
    
    @Column(name = "WSQty3", precision = 18, scale = 4)
    private BigDecimal wsQty3;
    
    @Column(name = "WSQty4", precision = 18, scale = 4)
    private BigDecimal wsQty4;
    
    @Column(name = "WSQty5", precision = 18, scale = 4)
    private BigDecimal wsQty5;
}

