package com.ms.semicolans.sereportapi.sereportapi.api;

import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.InvoiceCreateRequestDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.InvoiceCreateResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ItemLookupResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.LastInvPriceResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.CalculatePriceRequestDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.CalculatePriceResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.service.InvoiceService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/v1/invoice")
@RequiredArgsConstructor
public class InvoiceController {
    
    private final InvoiceService invoiceService;
    
    private String getTokenFromRequest(HttpServletRequest request) {
        String authorizationHeader = request.getHeader("Authorization");
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            return authorizationHeader;
        }
        return null;
    }

    /**
     * Item Lookup - Search item by barcode or product name
     * GET /api/v1/invoice/item-lookup?barcode={barcode}&locaCode={locaCode}
     * GET /api/v1/invoice/item-lookup?productName={name}&locaCode={locaCode}
     */
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_USER')")
    @GetMapping("/item-lookup")
    public ResponseEntity<StandardResponse> lookupItem(
            @RequestParam(required = false) String barcode,
            @RequestParam(required = false) String productName,
            @RequestParam String locaCode,
            HttpServletRequest httpRequest) {
        // Use barcode if provided, otherwise use productName
        String searchTerm = (barcode != null && !barcode.isEmpty()) ? barcode : productName;
        System.out.println(barcode);
        System.out.println(productName);
        if (searchTerm == null || searchTerm.isEmpty()) {
            return new ResponseEntity<>(
                    new StandardResponse(400, "Either barcode or productName must be provided", null),
                    HttpStatus.BAD_REQUEST
            );
        }
        String token = getTokenFromRequest(httpRequest);
        ItemLookupResponseDTO response = invoiceService.lookupItemByBarcode(searchTerm, locaCode, token);
        return new ResponseEntity<>(
                new StandardResponse(200, "Item fetched successfully", response),
                HttpStatus.OK
        );
    }
    
    /**
     * Calculate Price - Calculate final price based on quantity, customer, price type
     * POST /api/v1/invoice/calculate-price
     */
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_USER')")
    @PostMapping("/calculate-price")
    public ResponseEntity<StandardResponse> calculatePrice(@RequestBody CalculatePriceRequestDTO request) {
        CalculatePriceResponseDTO response = invoiceService.calculatePrice(request);
        return new ResponseEntity<>(
                new StandardResponse(200, "Price calculated successfully", response),
                HttpStatus.OK
        );
    }

    /**
     * Create Invoice - Create invoice for mobile app (offline-first)
     * POST /api/v1/invoice/create
     * Company ID, location code, and unit number are extracted from token
     */
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_USER')")
    @PostMapping("/create")
    public ResponseEntity<StandardResponse> createInvoice(
            @RequestBody InvoiceCreateRequestDTO request,
            HttpServletRequest httpRequest) {
        String token = getTokenFromRequest(httpRequest);
        InvoiceCreateResponseDTO response = invoiceService.createInvoice(request, token);
        return new ResponseEntity<>(
                new StandardResponse(200, "Invoice created successfully", response),
                HttpStatus.OK
        );
    }
    
    /**
     * Get Mobile Invoices - List invoices created from mobile app
     * GET /api/v1/invoice/mobile-invoices?locaCode={locaCode}&itMerged={true/false}
     */
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_USER')")
    @GetMapping("/mobile-invoices")
    public ResponseEntity<StandardResponse> getMobileInvoices(
            @RequestParam(required = false) String locaCode,
            @RequestParam(required = false) Boolean itMerged) {
        var response = invoiceService.getMobileInvoices(locaCode, itMerged);
        return new ResponseEntity<>(
                new StandardResponse(200, "Mobile invoices fetched successfully", response),
                HttpStatus.OK
        );
    }
    
    /**
     * Get last invoice price by customer and item - for Add Item dialog
     * GET /api/v1/invoice/last-inv-price-by-customer?cusCode={cusCode}&itemCode={itemCode}&barcode={barcode}
     * Uses CompID from token. Returns ItemDPrice and Qty from most recent invoice.
     */
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_USER')")
    @GetMapping("/last-inv-price-by-customer")
    public ResponseEntity<StandardResponse> getLastInvPriceByCustomer(
            @RequestParam String cusCode,
            @RequestParam String itemCode,
            @RequestParam(required = false) String barcode,
            HttpServletRequest httpRequest) {
        String token = getTokenFromRequest(httpRequest);
        LastInvPriceResponseDTO response = invoiceService.getLastInvPriceByCustomer(cusCode, itemCode, barcode, token);
        return new ResponseEntity<>(
                new StandardResponse(200, "Last invoice price fetched successfully", response),
                HttpStatus.OK
        );
    }

    /**
     * Get last invoice price by item only (no customer) - for Add Item dialog
     * GET /api/v1/invoice/last-inv-price-by-item?itemCode={itemCode}&barcode={barcode}
     * Uses CompID from token. Returns ItemDPrice and Qty from most recent invoice.
     */
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_USER')")
    @GetMapping("/last-inv-price-by-item")
    public ResponseEntity<StandardResponse> getLastInvPriceByItem(
            @RequestParam String itemCode,
            @RequestParam(required = false) String barcode,
            HttpServletRequest httpRequest) {
        String token = getTokenFromRequest(httpRequest);
        System.out.println("hello");
        LastInvPriceResponseDTO response = invoiceService.getLastInvPriceByItem(itemCode, barcode, token);
        System.out.println(response);
        return new ResponseEntity<>(
                new StandardResponse(200, "Last invoice price fetched successfully", response),
                HttpStatus.OK
        );
    }

    /**
     * Check Price Link - Get price links for an item (matches VB6 Check_PriceLink logic)
     * GET /api/v1/invoice/check-price-link?itemBarcode={barcode}&locaCode={locaCode}&stockId={stockId}
     * Optional: &itemUPrice={price}&itemSPrice={price}&updateMode={true/false}&itemPriceShortCutMode={true/false}
     */
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_USER')")
    @GetMapping("/check-price-link")
    public ResponseEntity<StandardResponse> checkPriceLink(
            @RequestParam String itemBarcode,
            @RequestParam String locaCode,
            @RequestParam String stockId,
            @RequestParam(required = false) java.math.BigDecimal itemUPrice,
            @RequestParam(required = false) java.math.BigDecimal itemSPrice,
            @RequestParam(required = false, defaultValue = "false") Boolean updateMode,
            @RequestParam(required = false, defaultValue = "false") Boolean itemPriceShortCutMode,
            HttpServletRequest httpRequest) {
        String token = getTokenFromRequest(httpRequest);
        var response = invoiceService.checkPriceLink(
                itemBarcode, locaCode, stockId, itemUPrice, itemSPrice, updateMode, itemPriceShortCutMode, token);
        return new ResponseEntity<>(
                new StandardResponse(200, "Price links fetched successfully", response),
                HttpStatus.OK
        );
    }
}

