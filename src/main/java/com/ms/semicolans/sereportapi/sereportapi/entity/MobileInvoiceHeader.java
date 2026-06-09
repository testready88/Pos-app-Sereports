package com.ms.semicolans.sereportapi.sereportapi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "tbl_MobileInvoiceHeader")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MobileInvoiceHeader {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "ClientId", length = 64)
    private String clientId; // mobile-generated UUID for idempotency/merge

    @Column(name = "SerialNo", length = 50)
    private String serialNo;

    @Column(name = "InvoiceNo", length = 50)
    private String invoiceNo;

    @Column(name = "LocaCode", length = 10)
    private String locaCode;

    @Column(name = "UnitNo", length = 10)
    private String unitNo;

    @Column(name = "CompID", length = 10)
    private String compId;

    @Column(name = "IsDownload")
    private Boolean isDownload;

    @Column(name = "DownloadLoca", length = 10)
    private String downloadLoca;

    @Column(name = "InvType", length = 50)
    private String invType;

    @Column(name = "CustomerCode", length = 50)
    private String customerCode;

    @Column(name = "GrandTotal", precision = 18, scale = 4)
    private BigDecimal grandTotal;

    // Payment fields
    @Column(name = "CashPaid", precision = 18, scale = 4)
    private BigDecimal cashPaid;

    @Column(name = "CreditPaid", precision = 18, scale = 4)
    private BigDecimal creditPaid;

    @Column(name = "CardPaid", precision = 18, scale = 4)
    private BigDecimal cardPaid;

    @Column(name = "CardNo", length = 50)
    private String cardNo;

    @Column(name = "CardBank", length = 100)
    private String cardBank;

    @Column(name = "ChqPaid", precision = 18, scale = 4)
    private BigDecimal chqPaid;

    @Column(name = "ChqNo", length = 50)
    private String chqNo;

    @Column(name = "ChqDate")
    private java.time.LocalDate chqDate;

    @Column(name = "ChqBnk", length = 100)
    private String chqBnk;

    @Column(name = "ItemCount")
    private Integer itemCount;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    @Column(name = "MergeStatus", length = 20)
    private String mergeStatus; // PENDING, MERGED, FAILED

    @Column(name = "MergeTarget", length = 100)
    private String mergeTarget; // optional target db identifier

    @Column(name = "MergeMessage", length = 255)
    private String mergeMessage;

    @Column(name = "IsMerged")
    private Boolean merged; // false on create, true after merge to local/original DB

    @Column(name = "it_merged")
    private Boolean itMerged; // flag to indicate if invoice should be merged by .NET project

    @Column(name = "merge_time")
    private LocalDateTime mergeTime; // timestamp when invoice was merged
}


