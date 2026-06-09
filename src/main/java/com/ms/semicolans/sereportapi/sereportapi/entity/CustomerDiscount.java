package com.ms.semicolans.sereportapi.sereportapi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "tbl_CusDiscountDet")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CustomerDiscount {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "CusCode", length = 50)
    private String cusCode;
    
    @Column(name = "ItemCode", length = 50)
    private String itemCode;
    
    @Column(name = "ItemUPrice", precision = 18, scale = 4)
    private BigDecimal itemUPrice;
    
    @Column(name = "ItemSPrice", precision = 18, scale = 4)
    private BigDecimal itemSPrice;
    
    @Column(name = "ItemDPrice", precision = 18, scale = 4)
    private BigDecimal itemDPrice;
}

