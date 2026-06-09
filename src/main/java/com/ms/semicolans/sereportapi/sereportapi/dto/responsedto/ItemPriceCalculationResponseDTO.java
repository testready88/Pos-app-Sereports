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
public class ItemPriceCalculationResponseDTO {
    // Final calculated price
    private BigDecimal finalPrice;
    private BigDecimal totalPrice;
    private BigDecimal profit;
    
    // Invoice type and price change info
    private String invType; // RETAIL, WHOLE SALE, DISCOUNTED, OFFER, CUSTOMER DISCOUNT
    private String priceChangeType; // NONE, WHOLESALE, DISCOUNT, OFFER, CUSTOMER DISCOUNT
    private String isPriceChange; // "0" or "1"
    
    // Customer discount info
    private Boolean hasCustomerDiscount;
    private BigDecimal customerDiscountPrice;
    
    // Applied price range info (for debugging/logging)
    private String appliedPriceRange; // e.g., "DISCOUNT_RANGE_2", "OFFER_RANGE_3", "WS_RANGE_1"
}

