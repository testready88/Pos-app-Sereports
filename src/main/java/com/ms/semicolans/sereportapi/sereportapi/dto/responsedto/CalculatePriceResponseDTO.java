package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CalculatePriceResponseDTO {
    private BigDecimal finalPrice;
    private BigDecimal totalPrice;
    private BigDecimal profit;
    private String invType; // RETAIL, WHOLESALE, OFFER, DISCOUNTED, CUSTOMER DISCOUNT
    private String priceChangeType; // NONE, WHOLESALE, OFFER, DISCOUNT, CUSTOMER DISCOUNT
    private String isPriceChange; // "0" or "1"
    private Boolean hasCustomerDiscount;
    private BigDecimal customerDiscountPrice;
}

