package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.ItemPriceCalculationRequestDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ItemDetectionResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ItemPriceCalculationResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.PriceLinkResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.entity.CustomerDiscount;
import com.ms.semicolans.sereportapi.sereportapi.entity.ItemDetail;
import com.ms.semicolans.sereportapi.sereportapi.entity.PriceLink;
import com.ms.semicolans.sereportapi.sereportapi.exception.EntryNotFoundException;
import com.ms.semicolans.sereportapi.sereportapi.repo.CustomerDiscountRepo;
import com.ms.semicolans.sereportapi.sereportapi.repo.ItemDetailRepo;
import com.ms.semicolans.sereportapi.sereportapi.repo.PriceLinkRepo;
import com.ms.semicolans.sereportapi.sereportapi.service.ItemPriceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ItemPriceServiceImpl implements ItemPriceService {
    
    private final ItemDetailRepo itemDetailRepo;
    private final PriceLinkRepo priceLinkRepo;
    private final CustomerDiscountRepo customerDiscountRepo;
//
//    @Override
//    @Transactional(readOnly = true)
//    public ItemDetectionResponseDTO detectItemByBarcode(String barcode, String locaCode, String stockId) {
//        if (barcode == null || barcode.isEmpty()) {
//            throw new IllegalArgumentException("Barcode cannot be empty");
//        }
//
//        Optional<ItemDetail> itemOpt = Optional.empty();
//        String foundBarcodeField = null;
//
//        // First try primary barcode - take first result if multiple
//        List<ItemDetail> items = itemDetailRepo.findByItemBarcode(barcode);
//        if (!items.isEmpty()) {
//            itemOpt = Optional.of(items.get(0));
//            foundBarcodeField = "ItemBarcode";
//        }
//
//        // Try alternative barcodes - take first result if multiple
//        if (itemOpt.isEmpty()) {
//            items = itemDetailRepo.findByItemBarcode1OrItemBarcode2OrItemBarcode3OrItemBarcode4(barcode);
//            if (!items.isEmpty()) {
//                ItemDetail foundItem = items.get(0);
//                itemOpt = Optional.of(foundItem);
//                if (barcode.equals(foundItem.getItemBarcode1())) {
//                    foundBarcodeField = "ItemBarcode1";
//                } else if (barcode.equals(foundItem.getItemBarcode2())) {
//                    foundBarcodeField = "ItemBarcode2";
//                } else if (barcode.equals(foundItem.getItemBarcode3())) {
//                    foundBarcodeField = "ItemBarcode3";
//                } else if (barcode.equals(foundItem.getItemBarcode4())) {
//                    foundBarcodeField = "ItemBarcode4";
//                } else {
//                    foundBarcodeField = "ItemBarcode"; // fallback
//                }
//            }
//        }
//
//        ItemDetail item = itemOpt.orElseThrow(() ->
//            new EntryNotFoundException("Item not found with barcode: " + barcode));
//
//        // Get price links - use the found barcode field for lookup
//        String barcodeForPriceLink = foundBarcodeField != null && foundBarcodeField.equals("ItemBarcode")
//            ? item.getItemBarcode()
//            : barcode;
//
//        List<PriceLink> priceLinks;
//        if (stockId != null && !stockId.isEmpty()) {
//            priceLinks = priceLinkRepo.findByItemBarcodeAndLocaCodeAndStockId(
//                barcodeForPriceLink, locaCode, stockId);
//        } else {
//            priceLinks = priceLinkRepo.findByItemBarcodeAndLocaCode(
//                barcodeForPriceLink, locaCode);
//        }
//
//        // Filter valid price links
//        List<PriceLinkResponseDTO> priceLinkDTOs = priceLinks.stream()
//            .filter(pl -> pl.getItemUPrice() != null && pl.getItemUPrice().compareTo(BigDecimal.ZERO) > 0 &&
//                         pl.getItemSPrice() != null && pl.getItemSPrice().compareTo(BigDecimal.ZERO) > 0)
//            .map(this::mapToPriceLinkResponseDTO)
//            .collect(Collectors.toList());
//
//        // Map to response DTO
//        ItemDetectionResponseDTO response = new ItemDetectionResponseDTO();
//        response.setItemCode(item.getItemCode());
//        response.setItemBarcode(item.getItemBarcode());
//        response.setItemBarcode1(item.getItemBarcode1());
//        response.setItemBarcode2(item.getItemBarcode2());
//        response.setItemBarcode3(item.getItemBarcode3());
//        response.setItemBarcode4(item.getItemBarcode4());
//        response.setItemName(item.getItemName());
//        response.setItemName1(item.getItemName1());
//        response.setItemName2(item.getItemName2());
//        response.setItemCatCode(item.getItemCatCode());
//        response.setItemCatName(item.getItemCatName());
//        response.setItemSubCatCode1(item.getItemSubCatCode1());
//        response.setItemSubCatName1(item.getItemSubCatName1());
//        response.setItemSubCatCode2(item.getItemSubCatCode2());
//        response.setItemSubCatName2(item.getItemSubCatName2());
//        response.setItemType(item.getItemType());
//        response.setPartNo1(item.getPartNo1());
//        response.setPartNo2(item.getPartNo2());
//        response.setPartNo3(item.getPartNo3());
//        response.setPartNo4(item.getPartNo4());
//        response.setItemMake(item.getItemMake());
//
//        // Flags
//        response.setBoolItemOffer("1".equals(item.getChkOffer()));
//        response.setBoolAskSerialNoOnInvoice("1".equals(item.getAskSerialNoOnInvoice()));
//        response.setBoolZeroPrice("1".equals(item.getChkZeroPrice()));
//        response.setBoolItemDiscount("1".equals(item.getChkDiscount()));
//        response.setBoolWholeSale("1".equals(item.getChkWholeSale()));
//        response.setBoolLessMPrice("1".equals(item.getChkLessMPrice()));
//        response.setBoolGreaterSPrice("1".equals(item.getChkGreaterSPrice()));
//        response.setBoolLessUPrice("1".equals(item.getChkLessUPrice()));
//        response.setBoolAllowdecimal("1".equals(item.getChkAllowdecimal()));
//        response.setBoolAutoDelPriceLink("1".equals(item.getChkAutoDelPriceLink()));
//        response.setBoolAllowLoyaltyPoints("1".equals(item.getChkAllowLoyaltyPoints()));
//        response.setBoolAllowEditOnInv("1".equals(item.getChkAllowEditOnInv()));
//        response.setBoolShowPriceLink("1".equals(item.getChkShowPriceLink()));
//        response.setBoolFreezItem("1".equals(item.getChkFreezItem()));
//
//        // Quantities
//        response.setOfferQty(item.getOfferQty());
//        response.setDiscountQty(item.getDiscountQty());
//        response.setWsQty(item.getWsQty());
//
//        // Validity dates
//        response.setOfferValidTill(item.getOfferValidTill());
//        response.setZeroPriceValidTill(item.getZeroPriceValidTill());
//        response.setDiscountValidTill(item.getDiscountValidTill());
//        response.setWholeSaleValidTill(item.getWholeSaleValidTill());
//        response.setLessMPriceValidTill(item.getLessMPriceValidTill());
//        response.setGreaterSPriceValidTill(item.getGreaterSPriceValidTill());
//        response.setLessUPriceValidTill(item.getLessUPriceValidTill());
//
//        // Discounts allowed
//        response.setChkAllowCashDiscount(item.getChkAllowCashDiscount());
//        response.setChkAllowCusDiscount(item.getChkAllowCusDiscount());
//        response.setChkAllowStaffDiscount(item.getChkAllowStaffDiscount());
//
//        // UOMs
//        response.setUom0(item.getUom0());
//        response.setUom1(item.getUom1());
//        response.setUom2(item.getUom2());
//        response.setCurrentUOM("UOM1");
//
//        // Free quantity ranges
//        BigDecimal freeQty1 = item.getFreeQty1() != null ? item.getFreeQty1() : BigDecimal.ZERO;
//        BigDecimal freeQty2 = item.getFreeQty2() != null ? item.getFreeQty2() : BigDecimal.ZERO;
//        BigDecimal freeQty3 = item.getFreeQty3() != null ? item.getFreeQty3() : BigDecimal.ZERO;
//        BigDecimal freeIssueQty1 = item.getFreeIssueQty1() != null ? item.getFreeIssueQty1() : BigDecimal.ZERO;
//        BigDecimal freeIssueQty2 = item.getFreeIssueQty2() != null ? item.getFreeIssueQty2() : BigDecimal.ZERO;
//        BigDecimal freeIssueQty3 = item.getFreeIssueQty3() != null ? item.getFreeIssueQty3() : BigDecimal.ZERO;
//
//        boolean boolFreeIssueRange = freeQty1.compareTo(BigDecimal.ZERO) > 0 ||
//                                     freeQty2.compareTo(BigDecimal.ZERO) > 0 ||
//                                     freeQty3.compareTo(BigDecimal.ZERO) > 0 ||
//                                     freeIssueQty1.compareTo(BigDecimal.ZERO) > 0 ||
//                                     freeIssueQty2.compareTo(BigDecimal.ZERO) > 0 ||
//                                     freeIssueQty3.compareTo(BigDecimal.ZERO) > 0;
//
//        response.setBoolFreeIssueRange(boolFreeIssueRange);
//        response.setFreeQty1(freeQty1);
//        response.setFreeQty2(freeQty2);
//        response.setFreeQty3(freeQty3);
//        response.setFreeIssueQty1(freeIssueQty1);
//        response.setFreeIssueQty2(freeIssueQty2);
//        response.setFreeIssueQty3(freeIssueQty3);
//
//        // OWS ranges
//        response.setDiscountRange("1".equals(item.getChkActiveDiscountRange()));
//        response.setDiscountQty1(item.getDiscountQty1());
//        response.setDiscountQty2(item.getDiscountQty2());
//        response.setDiscountQty3(item.getDiscountQty3());
//        response.setDiscountQty4(item.getDiscountQty4());
//        response.setDiscountQty5(item.getDiscountQty5());
//
//        response.setOfferRange("1".equals(item.getChkActiveOfferRange()));
//        response.setOfferQty1(item.getOfferQty1());
//        response.setOfferQty2(item.getOfferQty2());
//        response.setOfferQty3(item.getOfferQty3());
//        response.setOfferQty4(item.getOfferQty4());
//        response.setOfferQty5(item.getOfferQty5());
//
//        response.setWsRange("1".equals(item.getChkActiveWSRange()));
//        response.setWsQty1(item.getWsQty1());
//        response.setWsQty2(item.getWsQty2());
//        response.setWsQty3(item.getWsQty3());
//        response.setWsQty4(item.getWsQty4());
//        response.setWsQty5(item.getWsQty5());
//
//        response.setPriceLinks(priceLinkDTOs);
//        response.setFoundBarcodeField(foundBarcodeField);
//        response.setItemExists(true);
//
//        return response;
//    }
    
    @Override
    @Transactional(readOnly = true)
    public ItemPriceCalculationResponseDTO calculateItemPrice(ItemPriceCalculationRequestDTO request) {
        LocalDate currentDate = request.getCurrentDate() != null ? request.getCurrentDate() : LocalDate.now();
        ItemPriceCalculationResponseDTO response = new ItemPriceCalculationResponseDTO();
        
        // Populate OWS ranges from PriceLink
        populateOWSPriceRanges(request, response);
        
        // Check customer discount if applicable
        BigDecimal customerDiscountPrice = null;
        boolean hasCustomerDiscount = false;
        
        if (request.getCustomerCode() != null && !request.getCustomerCode().isEmpty() 
            && !"NULL".equalsIgnoreCase(request.getCustomerCode()) 
            && Boolean.TRUE.equals(request.getPrevCusPrice())) {
            
            Optional<CustomerDiscount> cusDiscountOpt;
            if (Boolean.TRUE.equals(request.getCusPriceWithoutPriceLink())) {
                cusDiscountOpt = customerDiscountRepo.findByCusCodeAndItemCode(
                    request.getCustomerCode(), request.getItemCode());
            } else {
                cusDiscountOpt = customerDiscountRepo.findByCusCodeAndItemCodeAndPrices(
                    request.getCustomerCode(), request.getItemCode(), 
                    request.getItemUPrice(), request.getItemSPrice());
            }
            
            if (cusDiscountOpt.isPresent() && cusDiscountOpt.get().getItemDPrice() != null 
                && cusDiscountOpt.get().getItemDPrice().compareTo(BigDecimal.ZERO) > 0) {
                hasCustomerDiscount = true;
                customerDiscountPrice = cusDiscountOpt.get().getItemDPrice();
            }
        }
        
        response.setHasCustomerDiscount(hasCustomerDiscount);
        response.setCustomerDiscountPrice(customerDiscountPrice);
        
        BigDecimal finalPrice = null;
        String invType = "RETAIL";
        String priceChangeType = "NONE";
        String isPriceChange = "0";
        String appliedPriceRange = null;
        
        // Step 1: Check category prices first (highest priority)
        if (request.getPriceType() != null && request.getPriceType().startsWith("CATEGORY")) {
            BigDecimal catPrice = getCategoryPrice(request.getPriceType(), request);
            if (catPrice != null && catPrice.compareTo(BigDecimal.ZERO) > 0) {
                finalPrice = catPrice;
                invType = "CUSTOMER DISCOUNT";
                priceChangeType = "CUSTOMER DISCOUNT";
                isPriceChange = "1";
                appliedPriceRange = "CATEGORY_" + request.getPriceType();
            }
        }
        
        // Step 2: Check wholesale mode
        if (finalPrice == null && ("WHOLESALE".equals(request.getPriceType()) || 
            (request.getItemWPrice() != null && request.getItemWPrice().compareTo(BigDecimal.ZERO) > 0))) {
            
            boolean wholeSaleDateValid = !Boolean.TRUE.equals(request.getAskWholeSaleDate()) || 
                (request.getWholeSaleValidTill() != null && 
                 (currentDate.isBefore(request.getWholeSaleValidTill()) || currentDate.isEqual(request.getWholeSaleValidTill())));
            
            if (wholeSaleDateValid) {
                // Check OWS ranges for wholesale
                BigDecimal wsPriceFromRange = getPriceFromOWSRange(request, "WS");
                BigDecimal effectiveWPrice = wsPriceFromRange != null ? wsPriceFromRange : request.getItemWPrice();
                
                if (effectiveWPrice != null && effectiveWPrice.compareTo(BigDecimal.ZERO) > 0) {
                    // Compare customer discount vs wholesale
                    if (hasCustomerDiscount && customerDiscountPrice.compareTo(effectiveWPrice) <= 0) {
                        finalPrice = customerDiscountPrice;
                        invType = "CUSTOMER DISCOUNT";
                        priceChangeType = "CUSTOMER DISCOUNT";
                        isPriceChange = "1";
                        appliedPriceRange = "CUSTOMER_DISCOUNT";
                    }
                    // Compare offer vs wholesale
                    else if (Boolean.TRUE.equals(request.getBoolItemOffer())) {
                        BigDecimal offerPrice = getOfferPrice(request, currentDate, effectiveWPrice);
                        if (offerPrice != null && offerPrice.compareTo(effectiveWPrice) <= 0) {
                            finalPrice = offerPrice;
                            invType = "OFFER";
                            priceChangeType = "OFFER";
                            isPriceChange = "1";
                            appliedPriceRange = getAppliedPriceRange(request, "OFFER");
                        } else {
                            finalPrice = effectiveWPrice;
                            invType = "WHOLE SALE";
                            priceChangeType = "WHOLESALE";
                            isPriceChange = "1";
                            appliedPriceRange = wsPriceFromRange != null ? getAppliedPriceRange(request, "WS") : "WS_BASE";
                        }
                    }
                    // Compare discount vs wholesale
                    else if (Boolean.TRUE.equals(request.getBoolItemDiscount())) {
                        BigDecimal discountPrice = getDiscountPrice(request, currentDate, effectiveWPrice);
                        if (discountPrice != null && discountPrice.compareTo(effectiveWPrice) <= 0) {
                            finalPrice = discountPrice;
                            invType = "DISCOUNTED";
                            priceChangeType = "DISCOUNT";
                            isPriceChange = "1";
                            appliedPriceRange = getAppliedPriceRange(request, "DISCOUNT");
                        } else {
                            finalPrice = effectiveWPrice;
                            invType = "WHOLE SALE";
                            priceChangeType = "WHOLESALE";
                            isPriceChange = "1";
                            appliedPriceRange = wsPriceFromRange != null ? getAppliedPriceRange(request, "WS") : "WS_BASE";
                        }
                    } else {
                        finalPrice = effectiveWPrice;
                        invType = "WHOLE SALE";
                        priceChangeType = "WHOLESALE";
                        isPriceChange = "1";
                        appliedPriceRange = wsPriceFromRange != null ? getAppliedPriceRange(request, "WS") : "WS_BASE";
                    }
                } else if (request.getItemSPrice() != null) {
                    finalPrice = request.getItemSPrice();
                    invType = "WHOLE SALE";
                    priceChangeType = "WHOLESALE";
                    isPriceChange = "1";
                    appliedPriceRange = "WS_FALLBACK_TO_S";
                }
            }
        }
        
        // Step 3: Check customer discount (if not wholesale)
        if (finalPrice == null && hasCustomerDiscount) {
            BigDecimal offerPrice = getOfferPrice(request, currentDate, customerDiscountPrice);
            if (offerPrice != null && offerPrice.compareTo(customerDiscountPrice) <= 0) {
                finalPrice = offerPrice;
                invType = "OFFER";
                priceChangeType = "OFFER";
                isPriceChange = "1";
                appliedPriceRange = getAppliedPriceRange(request, "OFFER");
            } else {
                // Check wholesale vs customer discount
                if (Boolean.TRUE.equals(request.getBoolWholeSale()) && "WHOLE SALE".equals(invType)) {
                    boolean wholeSaleDateValid = !Boolean.TRUE.equals(request.getAskWholeSaleDate()) || 
                        (request.getWholeSaleValidTill() != null && 
                         (currentDate.isBefore(request.getWholeSaleValidTill()) || currentDate.isEqual(request.getWholeSaleValidTill())));
                    
                    if (wholeSaleDateValid && request.getItemWPrice() != null && 
                        request.getItemWPrice().compareTo(BigDecimal.ZERO) > 0 &&
                        request.getItemWPrice().compareTo(customerDiscountPrice) <= 0) {
                        finalPrice = request.getItemWPrice();
                        invType = "WHOLE SALE";
                        priceChangeType = "WHOLESALE";
                        isPriceChange = "1";
                        appliedPriceRange = "WS_BASE";
                    } else {
                        finalPrice = customerDiscountPrice;
                        invType = "CUSTOMER DISCOUNT";
                        priceChangeType = "CUSTOMER DISCOUNT";
                        isPriceChange = "1";
                        appliedPriceRange = "CUSTOMER_DISCOUNT";
                    }
                }
                // Check discount vs customer discount
                else if (Boolean.TRUE.equals(request.getBoolItemDiscount())) {
                    BigDecimal discountPrice = getDiscountPrice(request, currentDate, customerDiscountPrice);
                    if (discountPrice != null && discountPrice.compareTo(customerDiscountPrice) <= 0) {
                        finalPrice = discountPrice;
                        invType = "DISCOUNTED";
                        priceChangeType = "DISCOUNT";
                        isPriceChange = "1";
                        appliedPriceRange = getAppliedPriceRange(request, "DISCOUNT");
                    } else {
                        finalPrice = customerDiscountPrice;
                        invType = "CUSTOMER DISCOUNT";
                        priceChangeType = "CUSTOMER DISCOUNT";
                        isPriceChange = "1";
                        appliedPriceRange = "CUSTOMER_DISCOUNT";
                    }
                } else {
                    finalPrice = customerDiscountPrice;
                    invType = "CUSTOMER DISCOUNT";
                    priceChangeType = "CUSTOMER DISCOUNT";
                    isPriceChange = "1";
                    appliedPriceRange = "CUSTOMER_DISCOUNT";
                }
            }
        }
        
        // Step 4: Check offer
        if (finalPrice == null && Boolean.TRUE.equals(request.getBoolItemOffer())) {
            BigDecimal offerPrice = getOfferPrice(request, currentDate, null);
            if (offerPrice != null && offerPrice.compareTo(BigDecimal.ZERO) > 0) {
                finalPrice = offerPrice;
                invType = "OFFER";
                priceChangeType = "OFFER";
                isPriceChange = "1";
                appliedPriceRange = getAppliedPriceRange(request, "OFFER");
            }
        }
        
        // Step 5: Check wholesale (if not already checked)
        if (finalPrice == null && Boolean.TRUE.equals(request.getBoolWholeSale()) && "WHOLE SALE".equals(invType)) {
            boolean wholeSaleDateValid = !Boolean.TRUE.equals(request.getAskWholeSaleDate()) || 
                (request.getWholeSaleValidTill() != null && 
                 (currentDate.isBefore(request.getWholeSaleValidTill()) || currentDate.isEqual(request.getWholeSaleValidTill())));
            
            if (wholeSaleDateValid) {
                BigDecimal wsPriceFromRange = getPriceFromOWSRange(request, "WS");
                if (wsPriceFromRange != null && wsPriceFromRange.compareTo(BigDecimal.ZERO) > 0) {
                    finalPrice = wsPriceFromRange;
                    appliedPriceRange = getAppliedPriceRange(request, "WS");
                } else if (request.getItemWPrice() != null && request.getItemWPrice().compareTo(BigDecimal.ZERO) > 0) {
                    finalPrice = request.getItemWPrice();
                    appliedPriceRange = "WS_BASE";
                } else {
                    finalPrice = request.getItemSPrice();
                    appliedPriceRange = "WS_FALLBACK_TO_S";
                }
                invType = "WHOLE SALE";
                priceChangeType = "WHOLESALE";
                isPriceChange = "1";
            }
        }
        
        // Step 6: Check discount
        if (finalPrice == null && Boolean.TRUE.equals(request.getBoolItemDiscount())) {
            BigDecimal discountPrice = getDiscountPrice(request, currentDate, null);
            if (discountPrice != null && discountPrice.compareTo(BigDecimal.ZERO) > 0) {
                finalPrice = discountPrice;
                invType = "DISCOUNTED";
                priceChangeType = "DISCOUNT";
                isPriceChange = "1";
                appliedPriceRange = getAppliedPriceRange(request, "DISCOUNT");
            } else if (request.getItemDPrice() != null && request.getItemDPrice().compareTo(BigDecimal.ZERO) > 0) {
                finalPrice = request.getItemDPrice();
                invType = "DISCOUNTED";
                priceChangeType = "DISCOUNT";
                isPriceChange = "1";
                appliedPriceRange = "DISCOUNT_BASE";
            } else if (request.getItemSPrice() != null) {
                finalPrice = request.getItemSPrice();
                invType = "DISCOUNTED";
                priceChangeType = "DISCOUNT";
                isPriceChange = "1";
                appliedPriceRange = "DISCOUNT_FALLBACK_TO_S";
            }
        }
        
        // Step 7: Default to selling price (RETAIL)
        if (finalPrice == null) {
            finalPrice = request.getItemSPrice();
            invType = "RETAIL";
            priceChangeType = "NONE";
            isPriceChange = "0";
            appliedPriceRange = "RETAIL";
        }
        
        // Calculate total price and profit
        BigDecimal qty = request.getQty() != null ? request.getQty() : BigDecimal.ONE;
        BigDecimal totalPrice = qty.multiply(finalPrice).setScale(2, RoundingMode.HALF_UP);
        BigDecimal unitPrice = request.getItemUPrice() != null ? request.getItemUPrice() : BigDecimal.ZERO;
        BigDecimal profit = qty.multiply(finalPrice.subtract(unitPrice)).setScale(2, RoundingMode.HALF_UP);
        
        response.setFinalPrice(finalPrice.setScale(2, RoundingMode.HALF_UP));
        response.setTotalPrice(totalPrice);
        response.setProfit(profit);
        response.setInvType(invType);
        response.setPriceChangeType(priceChangeType);
        response.setIsPriceChange(isPriceChange);
        response.setAppliedPriceRange(appliedPriceRange);
        
        return response;
    }
    
    @Override
    public void populateOWSPriceRanges(ItemPriceCalculationRequestDTO request, ItemPriceCalculationResponseDTO response) {
        // OWS ranges are populated from PriceLink in the request DTO
        // This method is called before price calculation to ensure ranges are available
        // The actual population happens when building the request DTO from PriceLink entity
    }
    
    @Override
    public void populateFreeQuantityRanges(ItemPriceCalculationRequestDTO request, ItemPriceCalculationResponseDTO response) {
        // Free quantity ranges are populated from ItemDetail
        // This is handled in detectItemByBarcode method
    }
    
    // Helper methods
    
    private BigDecimal getCategoryPrice(String priceType, ItemPriceCalculationRequestDTO request) {
        switch (priceType) {
            case "CATEGORY1":
                return request.getItemCusCatPrice1();
            case "CATEGORY2":
                return request.getItemCusCatPrice2();
            case "CATEGORY3":
                return request.getItemCusCatPrice3();
            case "CATEGORY4":
                return request.getItemCusCatPrice4();
            case "CATEGORY5":
                return request.getItemCusCatPrice5();
            default:
                return null;
        }
    }
    
    private BigDecimal getPriceFromOWSRange(ItemPriceCalculationRequestDTO request, String rangeType) {
        BigDecimal qty = request.getQty() != null ? request.getQty() : BigDecimal.ZERO;
        
        if ("DISCOUNT".equals(rangeType) && Boolean.TRUE.equals(request.getDiscountRange())) {
            if (request.getDiscountQty5() != null && qty.compareTo(request.getDiscountQty5()) >= 0 && 
                request.getDiscountPrice5() != null) {
                return request.getDiscountPrice5();
            } else if (request.getDiscountQty4() != null && qty.compareTo(request.getDiscountQty4()) >= 0 && 
                       request.getDiscountPrice4() != null) {
                return request.getDiscountPrice4();
            } else if (request.getDiscountQty3() != null && qty.compareTo(request.getDiscountQty3()) >= 0 && 
                       request.getDiscountPrice3() != null) {
                return request.getDiscountPrice3();
            } else if (request.getDiscountQty2() != null && qty.compareTo(request.getDiscountQty2()) >= 0 && 
                       request.getDiscountPrice2() != null) {
                return request.getDiscountPrice2();
            } else if (request.getDiscountQty1() != null && qty.compareTo(request.getDiscountQty1()) >= 0 && 
                       request.getDiscountPrice1() != null) {
                return request.getDiscountPrice1();
            }
        } else if ("OFFER".equals(rangeType) && Boolean.TRUE.equals(request.getOfferRange())) {
            if (request.getOfferQty5() != null && qty.compareTo(request.getOfferQty5()) >= 0 && 
                request.getOfferPrice5() != null) {
                return request.getOfferPrice5();
            } else if (request.getOfferQty4() != null && qty.compareTo(request.getOfferQty4()) >= 0 && 
                       request.getOfferPrice4() != null) {
                return request.getOfferPrice4();
            } else if (request.getOfferQty3() != null && qty.compareTo(request.getOfferQty3()) >= 0 && 
                       request.getOfferPrice3() != null) {
                return request.getOfferPrice3();
            } else if (request.getOfferQty2() != null && qty.compareTo(request.getOfferQty2()) >= 0 && 
                       request.getOfferPrice2() != null) {
                return request.getOfferPrice2();
            } else if (request.getOfferQty1() != null && qty.compareTo(request.getOfferQty1()) >= 0 && 
                       request.getOfferPrice1() != null) {
                return request.getOfferPrice1();
            }
        } else if ("WS".equals(rangeType) && Boolean.TRUE.equals(request.getWsRange())) {
            if (request.getWsQty5() != null && qty.compareTo(request.getWsQty5()) >= 0 && 
                request.getWsPrice5() != null) {
                return request.getWsPrice5();
            } else if (request.getWsQty4() != null && qty.compareTo(request.getWsQty4()) >= 0 && 
                       request.getWsPrice4() != null) {
                return request.getWsPrice4();
            } else if (request.getWsQty3() != null && qty.compareTo(request.getWsQty3()) >= 0 && 
                       request.getWsPrice3() != null) {
                return request.getWsPrice3();
            } else if (request.getWsQty2() != null && qty.compareTo(request.getWsQty2()) >= 0 && 
                       request.getWsPrice2() != null) {
                return request.getWsPrice2();
            } else if (request.getWsQty1() != null && qty.compareTo(request.getWsQty1()) >= 0 && 
                       request.getWsPrice1() != null) {
                return request.getWsPrice1();
            }
        }
        
        return null;
    }
    
    private BigDecimal getOfferPrice(ItemPriceCalculationRequestDTO request, LocalDate currentDate, BigDecimal comparePrice) {
        boolean offerDateValid = !Boolean.TRUE.equals(request.getAskOfferDate()) || 
            (request.getOfferValidTill() != null && 
             (currentDate.isBefore(request.getOfferValidTill()) || currentDate.isEqual(request.getOfferValidTill())));
        
        if (!offerDateValid) {
            return null;
        }
        
        // Check OWS range first
        BigDecimal offerPriceFromRange = getPriceFromOWSRange(request, "OFFER");
        if (offerPriceFromRange != null && offerPriceFromRange.compareTo(BigDecimal.ZERO) > 0) {
            if (comparePrice == null || offerPriceFromRange.compareTo(comparePrice) <= 0) {
                return offerPriceFromRange;
            }
        }
        
        // Check base offer price
        if (request.getItemOPrice() != null && request.getItemOPrice().compareTo(BigDecimal.ZERO) > 0) {
            if (comparePrice == null || request.getItemOPrice().compareTo(comparePrice) <= 0) {
                return request.getItemOPrice();
            }
        }
        
        return null;
    }
    
    private BigDecimal getDiscountPrice(ItemPriceCalculationRequestDTO request, LocalDate currentDate, BigDecimal comparePrice) {
        boolean discountDateValid = !Boolean.TRUE.equals(request.getAskDiscountDate()) || 
            (request.getDiscountValidTill() != null && 
             (currentDate.isBefore(request.getDiscountValidTill()) || currentDate.isEqual(request.getDiscountValidTill())));
        
        if (!discountDateValid) {
            return null;
        }
        
        // Check OWS range first
        BigDecimal discountPriceFromRange = getPriceFromOWSRange(request, "DISCOUNT");
        if (discountPriceFromRange != null && discountPriceFromRange.compareTo(BigDecimal.ZERO) > 0) {
            if (comparePrice == null || discountPriceFromRange.compareTo(comparePrice) <= 0) {
                return discountPriceFromRange;
            }
        }
        
        // Check base discount price
        if (request.getItemDPrice() != null && request.getItemDPrice().compareTo(BigDecimal.ZERO) > 0) {
            if (comparePrice == null || request.getItemDPrice().compareTo(comparePrice) <= 0) {
                return request.getItemDPrice();
            }
        }
        
        return null;
    }
    
    private String getAppliedPriceRange(ItemPriceCalculationRequestDTO request, String rangeType) {
        BigDecimal qty = request.getQty() != null ? request.getQty() : BigDecimal.ZERO;
        
        if ("DISCOUNT".equals(rangeType) && Boolean.TRUE.equals(request.getDiscountRange())) {
            if (request.getDiscountQty5() != null && qty.compareTo(request.getDiscountQty5()) >= 0) {
                return "DISCOUNT_RANGE_5";
            } else if (request.getDiscountQty4() != null && qty.compareTo(request.getDiscountQty4()) >= 0) {
                return "DISCOUNT_RANGE_4";
            } else if (request.getDiscountQty3() != null && qty.compareTo(request.getDiscountQty3()) >= 0) {
                return "DISCOUNT_RANGE_3";
            } else if (request.getDiscountQty2() != null && qty.compareTo(request.getDiscountQty2()) >= 0) {
                return "DISCOUNT_RANGE_2";
            } else if (request.getDiscountQty1() != null && qty.compareTo(request.getDiscountQty1()) >= 0) {
                return "DISCOUNT_RANGE_1";
            }
        } else if ("OFFER".equals(rangeType) && Boolean.TRUE.equals(request.getOfferRange())) {
            if (request.getOfferQty5() != null && qty.compareTo(request.getOfferQty5()) >= 0) {
                return "OFFER_RANGE_5";
            } else if (request.getOfferQty4() != null && qty.compareTo(request.getOfferQty4()) >= 0) {
                return "OFFER_RANGE_4";
            } else if (request.getOfferQty3() != null && qty.compareTo(request.getOfferQty3()) >= 0) {
                return "OFFER_RANGE_3";
            } else if (request.getOfferQty2() != null && qty.compareTo(request.getOfferQty2()) >= 0) {
                return "OFFER_RANGE_2";
            } else if (request.getOfferQty1() != null && qty.compareTo(request.getOfferQty1()) >= 0) {
                return "OFFER_RANGE_1";
            }
        } else if ("WS".equals(rangeType) && Boolean.TRUE.equals(request.getWsRange())) {
            if (request.getWsQty5() != null && qty.compareTo(request.getWsQty5()) >= 0) {
                return "WS_RANGE_5";
            } else if (request.getWsQty4() != null && qty.compareTo(request.getWsQty4()) >= 0) {
                return "WS_RANGE_4";
            } else if (request.getWsQty3() != null && qty.compareTo(request.getWsQty3()) >= 0) {
                return "WS_RANGE_3";
            } else if (request.getWsQty2() != null && qty.compareTo(request.getWsQty2()) >= 0) {
                return "WS_RANGE_2";
            } else if (request.getWsQty1() != null && qty.compareTo(request.getWsQty1()) >= 0) {
                return "WS_RANGE_1";
            }
        }
        
        return rangeType + "_BASE";
    }
    
    private PriceLinkResponseDTO mapToPriceLinkResponseDTO(PriceLink priceLink) {
        PriceLinkResponseDTO dto = new PriceLinkResponseDTO();
        // Note: PriceLink uses composite key (StockID, ItemBarcode, LocaCode) - no single ID column
        dto.setId(null); // Table doesn't have an id column
        dto.setStockId(priceLink.getStockId());
        dto.setItemUPrice(priceLink.getItemUPrice());
        dto.setItemSPrice(priceLink.getItemSPrice());
        dto.setItemDPrice(priceLink.getItemDPrice());
        dto.setItemWPrice(priceLink.getItemWPrice());
        dto.setItemLDPrice(priceLink.getItemLDPrice());
        dto.setItemMPrice(priceLink.getItemMPrice());
        dto.setItemOPrice(priceLink.getItemOPrice());
        dto.setQtyRemain(priceLink.getQtyRemain());
        dto.setWarMonth(priceLink.getWarMonth());
        dto.setItemSupName(priceLink.getItemSupName());
        dto.setItemSupCode(priceLink.getItemSupCode());
        dto.setExpDate(priceLink.getExpDate());
        dto.setUnitChange(priceLink.getUnitChange());
        dto.setUnitChange0(priceLink.getUnitChange0());
        dto.setItemCusCatPrice1(priceLink.getItemCusCatPrice1());
        dto.setItemCusCatPrice2(priceLink.getItemCusCatPrice2());
        dto.setItemCusCatPrice3(priceLink.getItemCusCatPrice3());
        dto.setItemCusCatPrice4(priceLink.getItemCusCatPrice4());
        dto.setItemCusCatPrice5(priceLink.getItemCusCatPrice5());
        dto.setExCharges(priceLink.getExCharges());
        dto.setFixedGP(priceLink.getFixedGP());
        dto.setFixedGPPer(priceLink.getFixedGPPer());
        dto.setItemDescriptionPriceLink(priceLink.getItemDescriptionPriceLink());
        dto.setItemAvgCost(priceLink.getItemAvgCost());
        dto.setItemCode(priceLink.getItemCode());
        dto.setDiscountPrice1(priceLink.getDiscountPrice1());
        dto.setDiscountPrice2(priceLink.getDiscountPrice2());
        dto.setDiscountPrice3(priceLink.getDiscountPrice3());
        dto.setDiscountPrice4(priceLink.getDiscountPrice4());
        dto.setDiscountPrice5(priceLink.getDiscountPrice5());
        dto.setOfferPrice1(priceLink.getOfferPrice1());
        dto.setOfferPrice2(priceLink.getOfferPrice2());
        dto.setOfferPrice3(priceLink.getOfferPrice3());
        dto.setOfferPrice4(priceLink.getOfferPrice4());
        dto.setOfferPrice5(priceLink.getOfferPrice5());
        dto.setWsPrice1(priceLink.getWsPrice1());
        dto.setWsPrice2(priceLink.getWsPrice2());
        dto.setWsPrice3(priceLink.getWsPrice3());
        dto.setWsPrice4(priceLink.getWsPrice4());
        dto.setWsPrice5(priceLink.getWsPrice5());
        return dto;
    }
}

