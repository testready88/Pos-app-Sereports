package com.ms.semicolans.sereportapi.sereportapi.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

@Embeddable
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
@Getter
@Setter
public class PriceLinkId implements Serializable {
    @Column(name = "StockID", length = 50)
    private String stockId;
    
    @Column(name = "ItemBarcode", length = 100)
    private String itemBarcode;
    
    @Column(name = "LocaCode", length = 10)
    private String locaCode;
}

