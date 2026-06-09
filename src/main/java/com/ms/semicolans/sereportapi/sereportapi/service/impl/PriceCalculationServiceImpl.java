package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.entity.ItemDetail;
import com.ms.semicolans.sereportapi.sereportapi.entity.PriceLink;
import com.ms.semicolans.sereportapi.sereportapi.service.PriceCalculationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class PriceCalculationServiceImpl implements PriceCalculationService {
    
    @Override
    public BigDecimal calculateDiscountPrice(BigDecimal itemSPrice, BigDecimal discountPercentage) {
        if (itemSPrice == null || discountPercentage == null) {
            return itemSPrice;
        }
        BigDecimal discountAmount = itemSPrice.multiply(discountPercentage)
                .divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
        return itemSPrice.subtract(discountAmount);
    }
    
    @Override
    public BigDecimal calculateOfferPrice(BigDecimal itemSPrice, BigDecimal offerQty, BigDecimal currentQty) {
        if (itemSPrice == null || offerQty == null || currentQty == null) {
            return itemSPrice;
        }
        // If current quantity meets offer quantity requirement, apply offer
        if (currentQty.compareTo(offerQty) >= 0) {
            // This is a simplified calculation - adjust based on actual offer logic
            return itemSPrice.multiply(BigDecimal.valueOf(0.9)); // 10% discount as example
        }
        return itemSPrice;
    }
    
    @Override
    public BigDecimal calculateWholesalePrice(BigDecimal itemWPrice, BigDecimal wsQty, BigDecimal currentQty) {
        if (itemWPrice == null || wsQty == null || currentQty == null) {
            return null;
        }
        // If current quantity meets wholesale quantity requirement, use wholesale price
        if (currentQty.compareTo(wsQty) >= 0) {
            return itemWPrice;
        }
        return null;
    }
    
    @Override
    public BigDecimal calculatePriceWithRange(PriceLink priceLink, BigDecimal qty, 
                                               ItemDetail itemDetail, String invType) {
        if (priceLink == null || qty == null) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal basePrice = priceLink.getItemSPrice();
        
        // Check if wholesale
        if ("WHOLE SALE".equalsIgnoreCase(invType) && priceLink.getItemWPrice() != null) {
            basePrice = priceLink.getItemWPrice();
        }
        
        // Apply offer range if applicable
        if (itemDetail != null && "1".equals(itemDetail.getChkActiveOfferRange())) {
            basePrice = applyOfferRange(basePrice, qty, itemDetail);
        }
        
        // Apply wholesale range if applicable
        if (itemDetail != null && "1".equals(itemDetail.getChkActiveWSRange())) {
            BigDecimal wsPrice = applyWholesaleRange(priceLink.getItemWPrice(), qty, itemDetail);
            if (wsPrice != null) {
                basePrice = wsPrice;
            }
        }
        
        return basePrice;
    }
    
    @Override
    public boolean isOfferValid(ItemDetail itemDetail, LocalDate currentDate) {
        if (itemDetail == null || itemDetail.getOfferValidTill() == null) {
            return false;
        }
        return currentDate.isBefore(itemDetail.getOfferValidTill()) || 
               currentDate.isEqual(itemDetail.getOfferValidTill());
    }
    
    @Override
    public boolean isDiscountValid(ItemDetail itemDetail, LocalDate currentDate) {
        if (itemDetail == null || itemDetail.getDiscountValidTill() == null) {
            return false;
        }
        return currentDate.isBefore(itemDetail.getDiscountValidTill()) || 
               currentDate.isEqual(itemDetail.getDiscountValidTill());
    }
    
    @Override
    public boolean isWholesaleValid(ItemDetail itemDetail, LocalDate currentDate) {
        if (itemDetail == null || itemDetail.getWholeSaleValidTill() == null) {
            return false;
        }
        return currentDate.isBefore(itemDetail.getWholeSaleValidTill()) || 
               currentDate.isEqual(itemDetail.getWholeSaleValidTill());
    }
    
    @Override
    public BigDecimal getFinalPrice(PriceLink priceLink, BigDecimal qty, ItemDetail itemDetail, 
                                    String invType, LocalDate currentDate, 
                                    Boolean allowCashDiscount, Boolean allowCusDiscount, Boolean allowStaffDiscount) {
        BigDecimal finalPrice = calculatePriceWithRange(priceLink, qty, itemDetail, invType);
        
        // Apply discounts based on permissions
        if (Boolean.TRUE.equals(allowCashDiscount)) {
            // Apply cash discount logic here
        }
        
        if (Boolean.TRUE.equals(allowCusDiscount)) {
            // Apply customer discount logic here
        }
        
        if (Boolean.TRUE.equals(allowStaffDiscount)) {
            // Apply staff discount logic here
        }
        
        return finalPrice;
    }
    
    private BigDecimal applyOfferRange(BigDecimal basePrice, BigDecimal qty, ItemDetail itemDetail) {
        // Simplified offer range logic - implement based on actual requirements
        // This would check qty against offerQty1, offerQty2, etc. and apply corresponding prices
        return basePrice;
    }
    
    private BigDecimal applyWholesaleRange(BigDecimal wsPrice, BigDecimal qty, ItemDetail itemDetail) {
        // Simplified wholesale range logic - implement based on actual requirements
        // This would check qty against wsQty1, wsQty2, etc. and apply corresponding prices
        return wsPrice;
    }
}

