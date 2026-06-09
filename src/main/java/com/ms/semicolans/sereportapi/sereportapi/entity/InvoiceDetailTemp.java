package com.ms.semicolans.sereportapi.sereportapi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "tbl_InvDetTemp")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class InvoiceDetailTemp {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "SerialNo", length = 50)
    private String serialNo;
    
    @Column(name = "LocaCode", length = 10)
    private String locaCode;
    
    @Column(name = "CompID", length = 10)
    private String compId;
    
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
    
    @Column(name = "ItemDescription1", length = 50)
    private String itemDescription1;
    
    @Column(name = "ItemSupCode", length = 50)
    private String itemSupCode;
    
    @Column(name = "ItemSupName", length = 255)
    private String itemSupName;
    
    @Column(name = "ItemUPrice", precision = 18, scale = 4)
    private BigDecimal itemUPrice;
    
    @Column(name = "ItemSPrice", precision = 18, scale = 4)
    private BigDecimal itemSPrice;
    
    @Column(name = "ItemSPriceTemp", precision = 18, scale = 4)
    private BigDecimal itemSPriceTemp;
    
    @Column(name = "ItemDPrice", precision = 18, scale = 4)
    private BigDecimal itemDPrice;
    
    @Column(name = "ItemLDPrice", precision = 18, scale = 4)
    private BigDecimal itemLDPrice;
    
    @Column(name = "ItemMPrice", precision = 18, scale = 4)
    private BigDecimal itemMPrice;
    
    @Column(name = "ItemWPrice", precision = 18, scale = 4)
    private BigDecimal itemWPrice;
    
    @Column(name = "ItemOPrice", precision = 18, scale = 4)
    private BigDecimal itemOPrice;
    
    @Column(name = "Qty", precision = 18, scale = 4)
    private BigDecimal qty;
    
    @Column(name = "TPrice", precision = 18, scale = 4)
    private BigDecimal tPrice;
    
    @Column(name = "InvType", length = 50)
    private String invType;
    
    @Column(name = "PriceLink", length = 50)
    private String priceLink;
    
    @Column(name = "ItemDescriptionPriceLink", length = 255)
    private String itemDescriptionPriceLink;
    
    @Column(name = "UnitChange0", precision = 18, scale = 4)
    private BigDecimal unitChange0;
    
    @Column(name = "UnitChange", precision = 18, scale = 4)
    private BigDecimal unitChange;
    
    @Column(name = "UOM0", length = 50)
    private String uom0;
    
    @Column(name = "UOM1", length = 50)
    private String uom1;
    
    @Column(name = "UOM2", length = 50)
    private String uom2;
    
    @Column(name = "strUOM", length = 50)
    private String strUOM;
    
    @Column(name = "CurrentUOM", length = 50)
    private String currentUOM;
    
    @Column(name = "ItemSerialNos", length = 1000)
    private String itemSerialNos;
    
    @Column(name = "Reason", length = 255)
    private String reason;
    
    @Column(name = "StockID", length = 50)
    private String stockId;
    
    @Column(name = "ExCharges", precision = 18, scale = 4)
    private BigDecimal exCharges;
    
    @Column(name = "CreateDate")
    private LocalDate createDate;
    
    @Column(name = "PriceChangeApprovedBy", length = 100)
    private String priceChangeApprovedBy;
    
    @Column(name = "IsPriceChange", length = 10)
    private String isPriceChange;
    
    @Column(name = "PriceChangeType", length = 50)
    private String priceChangeType;
}

