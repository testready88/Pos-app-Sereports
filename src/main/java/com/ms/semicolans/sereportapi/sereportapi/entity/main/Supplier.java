package com.ms.semicolans.sereportapi.sereportapi.entity.main;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Table(name = "tbl_SupDet")
public class Supplier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RowNo")
    private Long rowNo;

    @Column(name = "LocaCode", length = 10)
    private String locaCode;

    @Column(name = "SupCode", length = 30)
    private String supCode;

    @Column(name = "SupUniqID", length = 30)
    private String supUniqID;

    @Column(name = "SupName", length = 50)
    private String supName;

    @Column(name = "SupPhone", length = 50)
    private String supPhone;

    @Column(name = "SupHPhone", length = 50)
    private String supHPhone;

    @Column(name = "SupMob1", length = 100)
    private String supMob1;

    @Column(name = "SupMob2", length = 100)
    private String supMob2;

    @Column(name = "SupFax", length = 30)
    private String supFax;

    @Column(name = "SupEmail", length = 50)
    private String supEmail;

    @Column(name = "SupWebsite", length = 50)
    private String supWebsite;

    @Column(name = "SupAddress", length = 100)
    private String supAddress;

    @Column(name = "SupAddress2", length = 100)
    private String supAddress2;

    @Column(name = "SupAddress3", length = 100)
    private String supAddress3;

    @Column(name = "SupRemark", length = 500)
    private String supRemark;

    @Column(name = "SupCPerson", length = 50)
    private String supCPerson;

    @Column(name = "SupPosition", length = 20)
    private String supPosition;

    @Column(name = "SupCPersonMob1", length = 50)
    private String supCPersonMob1;

    @Column(name = "SupCPersonMob2", length = 50)
    private String supCPersonMob2;

    @Column(name = "SupCPersonEmail1", length = 50)
    private String supCPersonEmail1;

    @Column(name = "SupCPerson2", length = 50)
    private String supCPerson2;

    @Column(name = "SupCPersonPosition2", length = 50)
    private String supCPersonPosition2;

    @Column(name = "SupCPersonMob3", length = 50)
    private String supCPersonMob3;

    @Column(name = "SupCPersonMob4", length = 50)
    private String supCPersonMob4;

    @Column(name = "SupCPersonEmail2", length = 50)
    private String supCPersonEmail2;

    @Column(name = "CreateBy", length = 50)
    private String createBy;

    @Column(name = "CreateDate")
    private LocalDateTime createDate;

    @Column(name = "TotalPurchase")
    private BigDecimal totalPurchase;

    @Column(name = "DueAmount")
    private BigDecimal dueAmount;

    @Column(name = "AdvanceAmount")
    private BigDecimal advanceAmount;

    @Column(name = "LastPayDate")
    private LocalDateTime lastPayDate;

    @Column(name = "LastPayAmount")
    private BigDecimal lastPayAmount;

    @Column(name = "LastPayType", length = 20)
    private String lastPayType;

    @Column(name = "LastInvDate")
    private LocalDateTime lastInvDate;

    @Column(name = "LastInvAmount")
    private BigDecimal lastInvAmount;

    @Column(name = "LastInvType", length = 20)
    private String lastInvType;

    @Column(name = "DiscountAmount")
    private BigDecimal discountAmount;

    @Column(name = "OpeningBalance")
    private BigDecimal openingBalance;

    @Column(name = "TDueAmount")
    private BigDecimal tDueAmount;

    @Column(name = "DiscountPercentage")
    private BigDecimal discountPercentage;

    @Column(name = "CreditLimit")
    private BigDecimal creditLimit;

    @Column(name = "ActiveSupplier", length = 20)
    private String activeSupplier;

    @Column(name = "CreditAdjust")
    private BigDecimal creditAdjust;

    @Column(name = "DebitAdjust")
    private BigDecimal debitAdjust;

    @Column(name = "ServerUpdateStatus", length = 10)
    private String serverUpdateStatus;

    @Column(name = "ServerUpdateDate")
    private LocalDateTime serverUpdateDate;

    @Column(name = "chkAllowCashDiscount", length = 5)
    private String chkAllowCashDiscount;

    @Column(name = "chkAllowCusDiscount", length = 5)
    private String chkAllowCusDiscount;

    @Column(name = "chkAllowStaffDiscount", length = 5)
    private String chkAllowStaffDiscount;

    @Column(name = "imgPath", length = 1000)
    private String imgPath;

    @Column(name = "CompId", length = 10)
    private String compId;

    @Column(name = "IDx")
    private Integer idx;

    @Column(name = "LastUpdateDate")
    private LocalDateTime lastUpdateDate;

    @Column(name = "IsRequiredToDownload")
    private Boolean isRequiredToDownload;

    @Column(name = "SupGroup", length = 30)
    private String supGroup;

    @Column(name = "LastPayMode", length = 100)
    private String lastPayMode;
}