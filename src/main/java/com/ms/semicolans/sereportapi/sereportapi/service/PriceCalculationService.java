package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.entity.ItemDetail;
import com.ms.semicolans.sereportapi.sereportapi.entity.PriceLink;

import java.math.BigDecimal;
import java.time.LocalDate;

public interface PriceCalculationService {
    
    BigDecimal calculateDiscountPrice(BigDecimal itemSPrice, BigDecimal discountPercentage);
    
    BigDecimal calculateOfferPrice(BigDecimal itemSPrice, BigDecimal offerQty, BigDecimal currentQty);
    
    BigDecimal calculateWholesalePrice(BigDecimal itemWPrice, BigDecimal wsQty, BigDecimal currentQty);
    
    BigDecimal calculatePriceWithRange(PriceLink priceLink, BigDecimal qty, 
                                        ItemDetail itemDetail, String invType);
    
    boolean isOfferValid(ItemDetail itemDetail, LocalDate currentDate);
    
    boolean isDiscountValid(ItemDetail itemDetail, LocalDate currentDate);
    
    boolean isWholesaleValid(ItemDetail itemDetail, LocalDate currentDate);
    
    BigDecimal getFinalPrice(PriceLink priceLink, BigDecimal qty, ItemDetail itemDetail, 
                            String invType, LocalDate currentDate, 
                            Boolean allowCashDiscount, Boolean allowCusDiscount, Boolean allowStaffDiscount);
}

