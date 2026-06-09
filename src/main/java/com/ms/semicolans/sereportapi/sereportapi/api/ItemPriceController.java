//package com.ms.semicolans.sereportapi.sereportapi.api;
//
//import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.ItemPriceCalculationRequestDTO;
//import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ItemDetectionResponseDTO;
//import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ItemPriceCalculationResponseDTO;
//import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.PriceLinkResponseDTO;
//import com.ms.semicolans.sereportapi.sereportapi.service.ItemPriceService;
//import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;
//import lombok.RequiredArgsConstructor;
//import org.springframework.http.HttpStatus;
//import org.springframework.http.ResponseEntity;
//import org.springframework.security.access.prepost.PreAuthorize;
//import org.springframework.web.bind.annotation.*;
//
//import java.time.LocalDate;
//
//@RestController
//@RequestMapping("/api/v1/item-price")
//@RequiredArgsConstructor
//public class ItemPriceController {
//
//    private final ItemPriceService itemPriceService;
//
//    /**
//     * Detect item by barcode
//     * POST /api/v1/item-price/detect
//     *
//     * This endpoint detects an item by barcode, checking ItemBarcode, ItemBarcode1-4
//     * Returns item details and available price links
//     */
//    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_USER')")
//    @PostMapping("/detect")
//    public ResponseEntity<StandardResponse> detectItem(
//            @RequestParam String barcode,
//            @RequestParam String locaCode,
//            @RequestParam(required = false) String stockId) {
//        try {
//            ItemDetectionResponseDTO response = itemPriceService.detectItemByBarcode(barcode, locaCode, stockId);
//            return new ResponseEntity<>(
//                    new StandardResponse(200, "Item detected successfully", response),
//                    HttpStatus.OK
//            );
//        } catch (Exception e) {
//            return new ResponseEntity<>(
//                    new StandardResponse(400, "Error detecting item: " + e.getMessage(), null),
//                    HttpStatus.BAD_REQUEST
//            );
//        }
//    }
//
//    /**
//     * Calculate item price with all pricing rules
//     * POST /api/v1/item-price/calculate
//     *
//     * This endpoint calculates the final price based on:
//     * - Quantity
//     * - Customer discounts
//     * - OWS (Offer, Wholesale, Discount) ranges
//     * - Category prices
//     * - Date validations
//     */
//    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_USER')")
//    @PostMapping("/calculate")
//    public ResponseEntity<StandardResponse> calculatePrice(
//            @RequestBody ItemPriceCalculationRequestDTO request) {
//        try {
//            // Set current date if not provided
//            if (request.getCurrentDate() == null) {
//                request.setCurrentDate(LocalDate.now());
//            }
//
//            ItemPriceCalculationResponseDTO response = itemPriceService.calculateItemPrice(request);
//            return new ResponseEntity<>(
//                    new StandardResponse(200, "Price calculated successfully", response),
//                    HttpStatus.OK
//            );
//        } catch (Exception e) {
//            return new ResponseEntity<>(
//                    new StandardResponse(400, "Error calculating price: " + e.getMessage(), null),
//                    HttpStatus.BAD_REQUEST
//            );
//        }
//    }
//}
//
