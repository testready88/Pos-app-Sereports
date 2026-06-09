package com.ms.semicolans.sereportapi.sereportapi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "tbl_MobileInvoiceItem")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MobileInvoiceItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "HeaderId")
    private MobileInvoiceHeader header;

    @Column(name = "ItemCode", length = 50)
    private String itemCode;

    @Column(name = "ItemBarcode", length = 100)
    private String itemBarcode;

    @Column(name = "CompID", length = 10)
    private String compId;

    @Column(name = "LocaCode", length = 10)
    private String locaCode;

    @Column(name = "IsDownload")
    private Boolean isDownload;

    @Column(name = "DownloadLoca", length = 10)
    private String downloadLoca;

    @Column(name = "StockID", length = 50)
    private String stockId;

    @Column(name = "Qty", precision = 18, scale = 4)
    private BigDecimal qty;

    @Column(name = "ItemUPrice", precision = 18, scale = 4)
    private BigDecimal itemUPrice;

    @Column(name = "ItemSPrice", precision = 18, scale = 4)
    private BigDecimal itemSPrice;

    @Column(name = "ItemDPrice", precision = 18, scale = 4)
    private BigDecimal itemDPrice;

    @Column(name = "TPrice", precision = 18, scale = 4)
    private BigDecimal tPrice;

    @Column(name = "InvType", length = 50)
    private String invType;
}


