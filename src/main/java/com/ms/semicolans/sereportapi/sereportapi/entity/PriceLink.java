package com.ms.semicolans.sereportapi.sereportapi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "tbl_PriceLink1")
@Getter
@Setter
@NoArgsConstructor
public class PriceLink {
    
    @EmbeddedId
    private PriceLinkId id;
    
    // Constructor for native query mapping
    public PriceLink(String stockId, String itemBarcode, String locaCode) {
        this.id = new PriceLinkId(stockId, itemBarcode, locaCode);
    }
    
    // Convenience getters for embedded ID fields
    public String getStockId() {
        return id != null ? id.getStockId() : null;
    }
    
    public String getItemBarcode() {
        return id != null ? id.getItemBarcode() : null;
    }
    
    public String getLocaCode() {
        return id != null ? id.getLocaCode() : null;
    }
    
    @Column(name = "ItemUPrice", precision = 18, scale = 4)
    private BigDecimal itemUPrice;
    
    @Column(name = "ItemSPrice", precision = 18, scale = 4)
    private BigDecimal itemSPrice;
    
    @Column(name = "ItemDPrice", precision = 18, scale = 4)
    private BigDecimal itemDPrice;
    
    @Column(name = "ItemWPrice", precision = 18, scale = 4)
    private BigDecimal itemWPrice;
    
    @Column(name = "ItemLDPrice", precision = 18, scale = 4)
    private BigDecimal itemLDPrice;
    
    @Column(name = "ItemMPrice", precision = 18, scale = 4)
    private BigDecimal itemMPrice;
    
    @Column(name = "ItemOPrice", precision = 18, scale = 4)
    private BigDecimal itemOPrice;
    
    @Column(name = "QtyRemain", precision = 18, scale = 4)
    private BigDecimal qtyRemain;
    
    @Column(name = "WarMonth", precision = 18, scale = 4)
    private BigDecimal warMonth;
    
    @Column(name = "ItemSupName", length = 255)
    private String itemSupName;
    
    @Column(name = "ItemSupCode", length = 50)
    private String itemSupCode;
    
    @Column(name = "ExpDate")
    private LocalDate expDate;
    
    @Column(name = "UnitChange", precision = 18, scale = 4)
    private BigDecimal unitChange;
    
    @Column(name = "UnitChange0", precision = 18, scale = 4)
    private BigDecimal unitChange0;
    
    @Column(name = "ItemCusCatPrice1", precision = 18, scale = 4)
    private BigDecimal itemCusCatPrice1;
    
    @Column(name = "ItemCusCatPrice2", precision = 18, scale = 4)
    private BigDecimal itemCusCatPrice2;
    
    @Column(name = "ItemCusCatPrice3", precision = 18, scale = 4)
    private BigDecimal itemCusCatPrice3;
    
    @Column(name = "ItemCusCatPrice4", precision = 18, scale = 4)
    private BigDecimal itemCusCatPrice4;
    
    @Column(name = "ItemCusCatPrice5", precision = 18, scale = 4)
    private BigDecimal itemCusCatPrice5;
    
    @Column(name = "ExCharges", precision = 18, scale = 4)
    private BigDecimal exCharges;
    
    @Column(name = "FixedGP", precision = 18, scale = 4)
    private BigDecimal fixedGP;
    
    @Column(name = "FixedGPPer", precision = 18, scale = 4)
    private BigDecimal fixedGPPer;
    
    @Column(name = "ItemDescriptionPriceLink", length = 255)
    private String itemDescriptionPriceLink;
    
    @Column(name = "ItemAvgCost", precision = 18, scale = 4)
    private BigDecimal itemAvgCost;
    
    @Column(name = "ItemCode", length = 50)
    private String itemCode;
    
    @Column(name = "DiscountPrice1", precision = 18, scale = 4)
    private BigDecimal discountPrice1;
    
    @Column(name = "DiscountPrice2", precision = 18, scale = 4)
    private BigDecimal discountPrice2;
    
    @Column(name = "DiscountPrice3", precision = 18, scale = 4)
    private BigDecimal discountPrice3;
    
    @Column(name = "DiscountPrice4", precision = 18, scale = 4)
    private BigDecimal discountPrice4;
    
    @Column(name = "DiscountPrice5", precision = 18, scale = 4)
    private BigDecimal discountPrice5;
    
    @Column(name = "OfferPrice1", precision = 18, scale = 4)
    private BigDecimal offerPrice1;
    
    @Column(name = "OfferPrice2", precision = 18, scale = 4)
    private BigDecimal offerPrice2;
    
    @Column(name = "OfferPrice3", precision = 18, scale = 4)
    private BigDecimal offerPrice3;
    
    @Column(name = "OfferPrice4", precision = 18, scale = 4)
    private BigDecimal offerPrice4;
    
    @Column(name = "OfferPrice5", precision = 18, scale = 4)
    private BigDecimal offerPrice5;
    
    @Column(name = "WSPrice1", precision = 18, scale = 4)
    private BigDecimal wsPrice1;
    
    @Column(name = "WSPrice2", precision = 18, scale = 4)
    private BigDecimal wsPrice2;
    
    @Column(name = "WSPrice3", precision = 18, scale = 4)
    private BigDecimal wsPrice3;
    
    @Column(name = "WSPrice4", precision = 18, scale = 4)
    private BigDecimal wsPrice4;
    
    @Column(name = "WSPrice5", precision = 18, scale = 4)
    private BigDecimal wsPrice5;
}

