package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.ItemPriceCalculationRequestDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ItemPriceCalculationResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ItemDetectionResponseDTO;

public interface ItemPriceService {
    
    /**
     * Detect item by barcode - checks ItemBarcode, ItemBarcode1-4
     * Similar to Get_ItemBarcodeOrBarcode1() and Item_Detect() in VB6
     */
  //  ItemDetectionResponseDTO detectItemByBarcode(String barcode, String locaCode, String stockId);
    
    /**
     * Calculate final price based on quantity, customer, price type, and all pricing rules
     * Implements Get_ItemPriceDet() logic with OWS ranges
     */
    ItemPriceCalculationResponseDTO calculateItemPrice(ItemPriceCalculationRequestDTO request);
    
    /**
     * Get OWS (Offer, Wholesale, Discount) price ranges for an item
     * Implements Get_OWSPriceRange() logic
     */
    void populateOWSPriceRanges(ItemPriceCalculationRequestDTO request, ItemPriceCalculationResponseDTO response);
    
    /**
     * Get free quantity ranges for an item
     * Implements Get_FreeQtyRange() logic
     */
    void populateFreeQuantityRanges(ItemPriceCalculationRequestDTO request, ItemPriceCalculationResponseDTO response);
}

