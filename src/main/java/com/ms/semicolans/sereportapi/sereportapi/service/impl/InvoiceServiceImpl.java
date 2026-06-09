package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.InvoiceCreateRequestDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.InvoiceItemCreateDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.InvoiceDetailResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.InvoiceResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.PriceLinkResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.InvoiceCreateResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ItemLookupResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.CalculatePriceRequestDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.CalculatePriceResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.entity.InvoiceDetailTemp;
import com.ms.semicolans.sereportapi.sereportapi.entity.ItemDetail;
import com.ms.semicolans.sereportapi.sereportapi.entity.NextNumber;
import com.ms.semicolans.sereportapi.sereportapi.entity.PriceLink;
import com.ms.semicolans.sereportapi.sereportapi.entity.PriceLinkId;
import com.ms.semicolans.sereportapi.sereportapi.entity.MobileInvoiceHeader;
import com.ms.semicolans.sereportapi.sereportapi.entity.MobileInvoiceItem;
import com.ms.semicolans.sereportapi.sereportapi.exception.EntryNotFoundException;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.LastInvPriceResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.repo.InvoiceDetailTempRepo;
import com.ms.semicolans.sereportapi.sereportapi.repo.ItemDetailRepo;
import com.ms.semicolans.sereportapi.sereportapi.repo.LastInvPriceRepo;
import com.ms.semicolans.sereportapi.sereportapi.repo.NextNumberRepo;
import com.ms.semicolans.sereportapi.sereportapi.repo.MobileInvoiceHeaderRepo;
import com.ms.semicolans.sereportapi.sereportapi.repo.MobileInvoiceItemRepo;
import com.ms.semicolans.sereportapi.sereportapi.service.InvoiceService;
import com.ms.semicolans.sereportapi.sereportapi.service.ItemPriceService;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.ItemPriceCalculationRequestDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ItemPriceCalculationResponseDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;

import java.sql.SQLException;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InvoiceServiceImpl implements InvoiceService {
    
    private final NextNumberRepo nextNumberRepo;
    private final InvoiceDetailTempRepo invoiceDetailTempRepo;
    private final ItemDetailRepo itemDetailRepo;

    private final MobileInvoiceHeaderRepo mobileInvoiceHeaderRepo;
    private final MobileInvoiceItemRepo mobileInvoiceItemRepo;
    private final ItemPriceService itemPriceService;
    private final CompanyUserService companyUserService;
    private final LastInvPriceRepo lastInvPriceRepo;

    @PersistenceContext
    private EntityManager entityManager;

    

    @Override
    public List<PriceLinkResponseDTO> checkPriceLink(String itemBarcode, String locaCode, String stockId, 
                                                      BigDecimal itemUPrice, BigDecimal itemSPrice, 
                                                      Boolean updateMode, Boolean itemPriceShortCutMode, String token) {
        // Get CompID from token for proper filtering
        String compId = null;
        if (token != null && !token.isEmpty()) {
            try {
                ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
                compId = userData.getCompanyId();
                System.out.println("checkPriceLink: CompID from token: " + compId);
            } catch (SQLException e) {
                System.out.println("checkPriceLink: Warning: Failed to extract CompID from token: " + e.getMessage());
            }
        }
        
        // Use the same fixed query logic as lookupItemByBarcode for consistent results
        // This ensures we get correct prices from the database with CompID filtering
        List<PriceLink> priceLinks = findPriceLinksByBarcodeAndLocaCode(itemBarcode, locaCode, compId);
        
        // If stockId is provided, filter by stockId as well
        if (stockId != null && !stockId.isEmpty()) {
            priceLinks = priceLinks.stream()
                    .filter(pl -> stockId.equals(pl.getStockId()))
                    .collect(Collectors.toList());
        }
        
        // Apply additional filters based on update mode or item price shortcut mode
        if (Boolean.TRUE.equals(updateMode) && itemUPrice != null && itemSPrice != null) {
            final BigDecimal finalUPrice = itemUPrice;
            final BigDecimal finalSPrice = itemSPrice;
            priceLinks = priceLinks.stream()
                    .filter(pl -> pl.getItemUPrice() != null && 
                                pl.getItemUPrice().compareTo(finalUPrice) == 0 &&
                                pl.getItemSPrice() != null &&
                                pl.getItemSPrice().compareTo(finalSPrice) == 0)
                    .collect(Collectors.toList());
        } else if (Boolean.TRUE.equals(itemPriceShortCutMode) && itemUPrice != null && itemSPrice != null) {
            final BigDecimal finalUPrice = itemUPrice;
            final BigDecimal finalSPrice = itemSPrice;
            priceLinks = priceLinks.stream()
                    .filter(pl -> pl.getItemUPrice() != null && 
                                pl.getItemUPrice().compareTo(finalUPrice) == 0 &&
                                pl.getItemSPrice() != null &&
                                pl.getItemSPrice().compareTo(finalSPrice) == 0)
                    .collect(Collectors.toList());
        }
        
        // Filter out zero prices (should already be filtered in SQL, but double-check)
        priceLinks = priceLinks.stream()
                .filter(pl -> pl.getItemUPrice() != null && 
                            pl.getItemUPrice().compareTo(BigDecimal.ZERO) > 0 &&
                            pl.getItemSPrice() != null &&
                            pl.getItemSPrice().compareTo(BigDecimal.ZERO) > 0)
                .collect(Collectors.toList());

        System.out.println("checkPriceLink: Returning " + priceLinks.size() + " price links after filtering");

        
        return priceLinks.stream()
                .map(this::mapToPriceLinkResponseDTO)
                .collect(Collectors.toList());
    }
    

    @Override
    public InvoiceResponseDTO getInvoiceDetails(String serialNo, String locaCode) {
        List<InvoiceDetailTemp> items = invoiceDetailTempRepo.findBySerialNoAndLocaCode(serialNo, locaCode);
        
        if (items.isEmpty()) {
            throw new EntryNotFoundException("Invoice not found");
        }
        
        InvoiceResponseDTO response = new InvoiceResponseDTO();
        response.setSerialNo(serialNo);
        response.setLocaCode(locaCode);
        
        BigDecimal gTotal = items.stream()
                .map(InvoiceDetailTemp::getTPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        response.setGTotal(gTotal);
        response.setNTotal(gTotal);
        response.setCTotal(gTotal);
        response.setCTotalAfterDiscount(gTotal);
        
        List<InvoiceDetailResponseDTO> itemDTOs = items.stream()
                .map(this::mapToInvoiceDetailResponseDTO)
                .collect(Collectors.toList());
        
        response.setItems(itemDTOs);
        
        return response;
    }


    @Override
    @Transactional
    public InvoiceCreateResponseDTO createInvoice(InvoiceCreateRequestDTO request, String token) {
        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new IllegalArgumentException("Invoice items are required");
        }
        
        // Extract company ID from token
        String companyId;
        try {
            ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
            companyId = userData.getCompanyId();
        } catch (SQLException e) {
            throw new IllegalArgumentException("Failed to extract company ID from token: " + e.getMessage());
        }
        
        // Use defaults if not provided
        String locaCode = request.getLocaCode() != null && !request.getLocaCode().isEmpty() 
            ? request.getLocaCode() : "1";
        String unitNo = request.getUnitNo() != null && !request.getUnitNo().isEmpty() 
            ? request.getUnitNo() : "001";
        String invType = request.getInvType() != null && !request.getInvType().isEmpty() 
            ? request.getInvType() : "RETAIL";
        
        List<MobileInvoiceItem> mobileInvoiceItems = new ArrayList<>();

        // Generate invoice/serial numbers
        // Get the first NextNumber record (there should only be one)
        // Using findAll().stream().findFirst() to avoid duplicate row issues
        NextNumber nextNumber = nextNumberRepo.findAll().stream()
                .findFirst()
                .orElseThrow(() -> new EntryNotFoundException("NextNumber record not found"));

        boolean useInvN = Boolean.TRUE.equals(request.getBoolInvCodeM());
        long invNoNumeric = useInvN ? nextNumber.getInvCodeN() : nextNumber.getInvCodeM();
        String serialNo = (useInvN ? "INVN-" : "INVM-")
                + locaCode
                + unitNo
                + "-"
                + String.format("%05d", invNoNumeric);
        String invoiceNo = LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yy-"))
                + String.format("%05d", invNoNumeric);

        // increment counter
        if (useInvN) {
            nextNumberRepo.incrementInvCodeN();
        } else {
            nextNumberRepo.incrementInvCodeM();
        }

        // Save items
        BigDecimal grandTotal = BigDecimal.ZERO;
        for (InvoiceItemCreateDTO item : request.getItems()) {
            InvoiceDetailTemp detail = new InvoiceDetailTemp();
            detail.setSerialNo(serialNo);
            detail.setLocaCode(locaCode);
            detail.setCompId(companyId); // Use company ID from token
            detail.setItemCode(item.getItemCode());
            detail.setItemBarcode(item.getItemBarcode());
            detail.setStockId(item.getStockId());
            detail.setQty(item.getQty());
            detail.setItemUPrice(item.getItemUPrice());
            detail.setItemSPrice(item.getItemSPrice());
            detail.setItemDPrice(item.getItemDPrice());
            detail.setTPrice(item.getQty().multiply(item.getItemDPrice()));
            detail.setInvType(item.getInvType() != null ? item.getInvType() : invType);
            detail.setCreateDate(LocalDate.now());
            grandTotal = grandTotal.add(detail.getTPrice());
            invoiceDetailTempRepo.save(detail);

            // Persist to mobile invoice item for later merge
            MobileInvoiceItem mobileItem = new MobileInvoiceItem();
            mobileItem.setItemCode(item.getItemCode());
            mobileItem.setItemBarcode(item.getItemBarcode());
            mobileItem.setCompId(companyId);
            mobileItem.setLocaCode(locaCode);
            mobileItem.setIsDownload(false); // Default value
            mobileItem.setDownloadLoca(""); // Default empty string
            mobileItem.setStockId(item.getStockId());
            mobileItem.setQty(item.getQty());
            mobileItem.setItemUPrice(item.getItemUPrice());
            mobileItem.setItemSPrice(item.getItemSPrice());
            mobileItem.setItemDPrice(item.getItemDPrice());
            mobileItem.setTPrice(detail.getTPrice());
            mobileItem.setInvType(detail.getInvType());
            mobileInvoiceItems.add(mobileItem);
        }

        // Persist header for later merge
        MobileInvoiceHeader mobileHeader = new MobileInvoiceHeader();
        mobileHeader.setClientId(request.getClientId()); // Set clientId from mobile app for merge tracking
        mobileHeader.setSerialNo(serialNo);
        mobileHeader.setInvoiceNo(invoiceNo);
        mobileHeader.setLocaCode(locaCode);
        mobileHeader.setUnitNo(unitNo);
        mobileHeader.setCompId(companyId); // Use company ID from token
        mobileHeader.setIsDownload(false); // Default value
        mobileHeader.setDownloadLoca(""); // Default empty string
        mobileHeader.setInvType(invType);
        mobileHeader.setCustomerCode(request.getCustomerCode());
        mobileHeader.setGrandTotal(grandTotal);
        mobileHeader.setItemCount(request.getItems().size());
        mobileHeader.setCreatedAt(java.time.LocalDateTime.now());
        mobileHeader.setUpdatedAt(java.time.LocalDateTime.now());
        mobileHeader.setMergeStatus("PENDING");
        mobileHeader.setMergeTarget(null);
        mobileHeader.setMergeMessage(null);
        mobileHeader.setMerged(false);
        mobileHeader.setItMerged(false); // Flag for .NET project to merge
        mobileHeader.setMergeTime(null); // Will be set by .NET project after merge

        // Save payment details directly in header based on payment type
        if (request.getPaymentType() != null && !request.getPaymentType().isEmpty()) {
            String paymentType = request.getPaymentType().toUpperCase();
            
            if ("CASH".equals(paymentType)) {
                mobileHeader.setCashPaid(request.getCashPaid());
            } else if ("CREDIT".equals(paymentType)) {
                mobileHeader.setCreditPaid(request.getCreditPaid());
            } else if ("CARD".equals(paymentType)) {
                mobileHeader.setCardPaid(request.getCardPaid());
                mobileHeader.setCardNo(request.getCardNo());
                mobileHeader.setCardBank(request.getCardBank());
            } else if ("CHEQUE".equals(paymentType)) {
                mobileHeader.setChqPaid(request.getChqPaid());
                mobileHeader.setChqNo(request.getChqNo());
                mobileHeader.setChqDate(request.getChqDate());
                mobileHeader.setChqBnk(request.getChqBnk());
            }
        }

        MobileInvoiceHeader savedHeader = mobileInvoiceHeaderRepo.save(mobileHeader);
        for (MobileInvoiceItem mItem : mobileInvoiceItems) {
            mItem.setHeader(savedHeader);
        }
        System.out.println("MobileInvoiceHeader"+savedHeader);
        mobileInvoiceItemRepo.saveAll(mobileInvoiceItems);

        InvoiceCreateResponseDTO response = new InvoiceCreateResponseDTO();
        response.setSerialNo(serialNo);
        response.setInvoiceNo(invoiceNo);
        response.setItemCount(request.getItems().size());
        response.setGrandTotal(grandTotal);
        return response;
    }
    
    /**
     * Custom method to fetch price links using native query with proper mapping
     * This handles the @EmbeddedId correctly for native queries
     * Matches VB6 Check_PriceLink logic: filters by CompID, ItemBarcode, LocaCode, and excludes zero prices
     */
    @SuppressWarnings("unchecked")
    private List<PriceLink> findPriceLinksByBarcodeAndLocaCode(String itemBarcode, String locaCode, String compId) {
        System.out.println("=== Finding Price Links ===");
        System.out.println("ItemBarcode: " + itemBarcode);
        System.out.println("LocaCode: " + locaCode);
        System.out.println("CompID: " + compId);
        
        // Build SQL query matching VB6 Check_PriceLink logic
        // Filter by CompID, ItemBarcode, LocaCode, and exclude zero prices at SQL level
        // Use DISTINCT to avoid duplicate price links (based on StockID, ItemBarcode, LocaCode)
        String sql = "SELECT DISTINCT StockID, ItemBarcode, LocaCode, ItemUPrice, ItemSPrice, ItemDPrice, " +
                     "ItemWPrice, ItemLDPrice, ItemMPrice, ItemOPrice, QtyRemain, WarMonth, ItemSupName, " +
                     "ItemSupCode, ExpDate, UnitChange, UnitChange0, ItemCusCatPrice1, ItemCusCatPrice2, " +
                     "ItemCusCatPrice3, ItemCusCatPrice4, ItemCusCatPrice5, ExCharges, FixedGP, FixedGPPer, " +
                     "ItemDescriptionPriceLink, ItemAvgCost, ItemCode, DiscountPrice1, DiscountPrice2, " +
                     "DiscountPrice3, DiscountPrice4, DiscountPrice5, OfferPrice1, OfferPrice2, OfferPrice3, " +
                     "OfferPrice4, OfferPrice5, WSPrice1, WSPrice2, WSPrice3, WSPrice4, WSPrice5 " +
                     "FROM tbl_PriceLink1 " +
                     "WHERE ItemBarcode = ? AND LocaCode = ? " +
                     "AND ItemUPrice <> 0 AND ItemSPrice <> 0 ";
        
        List<Object> params = new ArrayList<>();
        params.add(itemBarcode);
        params.add(locaCode);
        
        // Add CompID filter if available (matches ProductServiceImpl pattern)
        if (compId != null && !compId.isEmpty()) {
            sql += "AND CompID = ? ";
            params.add(compId);
        }
        
        sql += "ORDER BY QtyRemain ASC";
        
        Query query = entityManager.createNativeQuery(sql);
        for (int i = 0; i < params.size(); i++) {
            query.setParameter(i + 1, params.get(i));
        }
        
        List<Object[]> rows = query.getResultList();
        System.out.println("Found " + rows.size() + " price links with filters (ItemBarcode=" + itemBarcode + ", LocaCode=" + locaCode + 
                          (compId != null ? ", CompID=" + compId : "") + ", ItemUPrice<>0, ItemSPrice<>0)");
        
        // If no results with CompID filter, try without CompID (fallback)
        if (rows.isEmpty() && compId != null && !compId.isEmpty()) {
            System.out.println("No results with CompID filter, trying without CompID...");
            sql = "SELECT DISTINCT StockID, ItemBarcode, LocaCode, ItemUPrice, ItemSPrice, ItemDPrice, " +
                  "ItemWPrice, ItemLDPrice, ItemMPrice, ItemOPrice, QtyRemain, WarMonth, ItemSupName, " +
                  "ItemSupCode, ExpDate, UnitChange, UnitChange0, ItemCusCatPrice1, ItemCusCatPrice2, " +
                  "ItemCusCatPrice3, ItemCusCatPrice4, ItemCusCatPrice5, ExCharges, FixedGP, FixedGPPer, " +
                  "ItemDescriptionPriceLink, ItemAvgCost, ItemCode, DiscountPrice1, DiscountPrice2, " +
                  "DiscountPrice3, DiscountPrice4, DiscountPrice5, OfferPrice1, OfferPrice2, OfferPrice3, " +
                  "OfferPrice4, OfferPrice5, WSPrice1, WSPrice2, WSPrice3, WSPrice4, WSPrice5 " +
                  "FROM tbl_PriceLink1 " +
                  "WHERE ItemBarcode = ? AND LocaCode = ? " +
                  "AND ItemUPrice <> 0 AND ItemSPrice <> 0 " +
                  "ORDER BY QtyRemain ASC";
            query = entityManager.createNativeQuery(sql);
            query.setParameter(1, itemBarcode);
            query.setParameter(2, locaCode);
            rows = query.getResultList();
            System.out.println("Found " + rows.size() + " price links without CompID filter");
        }
        
        // If still no results and locaCode is "DEFAULT", try without locaCode filter (last resort)
        if (rows.isEmpty() && ("DEFAULT".equals(locaCode) || locaCode == null || locaCode.isEmpty())) {
            System.out.println("No results with DEFAULT locaCode, trying without locaCode filter...");
            sql = "SELECT DISTINCT StockID, ItemBarcode, LocaCode, ItemUPrice, ItemSPrice, ItemDPrice, " +
                  "ItemWPrice, ItemLDPrice, ItemMPrice, ItemOPrice, QtyRemain, WarMonth, ItemSupName, " +
                  "ItemSupCode, ExpDate, UnitChange, UnitChange0, ItemCusCatPrice1, ItemCusCatPrice2, " +
                  "ItemCusCatPrice3, ItemCusCatPrice4, ItemCusCatPrice5, ExCharges, FixedGP, FixedGPPer, " +
                  "ItemDescriptionPriceLink, ItemAvgCost, ItemCode, DiscountPrice1, DiscountPrice2, " +
                  "DiscountPrice3, DiscountPrice4, DiscountPrice5, OfferPrice1, OfferPrice2, OfferPrice3, " +
                  "OfferPrice4, OfferPrice5, WSPrice1, WSPrice2, WSPrice3, WSPrice4, WSPrice5 " +
                  "FROM tbl_PriceLink1 " +
                  "WHERE ItemBarcode = ? AND ItemUPrice <> 0 AND ItemSPrice <> 0 ";
            params = new ArrayList<>();
            params.add(itemBarcode);
            if (compId != null && !compId.isEmpty()) {
                sql += "AND CompID = ? ";
                params.add(compId);
            }
            sql += "ORDER BY QtyRemain ASC";
            query = entityManager.createNativeQuery(sql);
            for (int i = 0; i < params.size(); i++) {
                query.setParameter(i + 1, params.get(i));
            }
            rows = query.getResultList();
            System.out.println("Found " + rows.size() + " price links without locaCode filter");
        }
        
        List<PriceLink> priceLinks = new ArrayList<>();
        
        // Use a Set to track unique price links (based on StockID, ItemBarcode, LocaCode combination)
        java.util.Set<String> seenKeys = new java.util.HashSet<>();
        
        for (Object[] row : rows) {
            String stockId = (String) row[0];
            String barcode = (String) row[1];
            String loca = (String) row[2];
            
            // Create unique key to avoid duplicates
            String uniqueKey = stockId + "|" + barcode + "|" + loca;
            if (seenKeys.contains(uniqueKey)) {
                System.out.println("Skipping duplicate price link: " + uniqueKey);
                continue;
            }
            seenKeys.add(uniqueKey);
            
            PriceLink priceLink = new PriceLink();
            PriceLinkId id = new PriceLinkId(stockId, barcode, loca);
            priceLink.setId(id);
            priceLink.setItemUPrice((BigDecimal) row[3]);
            priceLink.setItemSPrice((BigDecimal) row[4]);
            priceLink.setItemDPrice((BigDecimal) row[5]);
            priceLink.setItemWPrice((BigDecimal) row[6]);
            priceLink.setItemLDPrice((BigDecimal) row[7]);
            priceLink.setItemMPrice((BigDecimal) row[8]);
            priceLink.setItemOPrice((BigDecimal) row[9]);
            priceLink.setQtyRemain((BigDecimal) row[10]);
            priceLink.setWarMonth((BigDecimal) row[11]);
            priceLink.setItemSupName((String) row[12]);
            priceLink.setItemSupCode((String) row[13]);
            if (row[14] != null) {
                priceLink.setExpDate(((java.sql.Date) row[14]).toLocalDate());
            }
            priceLink.setUnitChange((BigDecimal) row[15]);
            priceLink.setUnitChange0((BigDecimal) row[16]);
            priceLink.setItemCusCatPrice1((BigDecimal) row[17]);
            priceLink.setItemCusCatPrice2((BigDecimal) row[18]);
            priceLink.setItemCusCatPrice3((BigDecimal) row[19]);
            priceLink.setItemCusCatPrice4((BigDecimal) row[20]);
            priceLink.setItemCusCatPrice5((BigDecimal) row[21]);
            priceLink.setExCharges((BigDecimal) row[22]);
            priceLink.setFixedGP((BigDecimal) row[23]);
            priceLink.setFixedGPPer((BigDecimal) row[24]);
            priceLink.setItemDescriptionPriceLink((String) row[25]);
            priceLink.setItemAvgCost((BigDecimal) row[26]);
            priceLink.setItemCode((String) row[27]);
            priceLink.setDiscountPrice1((BigDecimal) row[28]);
            priceLink.setDiscountPrice2((BigDecimal) row[29]);
            priceLink.setDiscountPrice3((BigDecimal) row[30]);
            priceLink.setDiscountPrice4((BigDecimal) row[31]);
            priceLink.setDiscountPrice5((BigDecimal) row[32]);
            priceLink.setOfferPrice1((BigDecimal) row[33]);
            priceLink.setOfferPrice2((BigDecimal) row[34]);
            priceLink.setOfferPrice3((BigDecimal) row[35]);
            priceLink.setOfferPrice4((BigDecimal) row[36]);
            priceLink.setOfferPrice5((BigDecimal) row[37]);
            priceLink.setWsPrice1((BigDecimal) row[38]);
            priceLink.setWsPrice2((BigDecimal) row[39]);
            priceLink.setWsPrice3((BigDecimal) row[40]);
            priceLink.setWsPrice4((BigDecimal) row[41]);
            priceLink.setWsPrice5((BigDecimal) row[42]);
            priceLinks.add(priceLink);
            
            // Debug: Print price values for first price link
            if (priceLinks.size() == 1) {
                System.out.println("First price link prices - ItemUPrice: " + priceLink.getItemUPrice() + 
                                 ", ItemSPrice: " + priceLink.getItemSPrice() + 
                                 ", ItemDPrice: " + priceLink.getItemDPrice() + 
                                 ", ItemOPrice: " + priceLink.getItemOPrice() + 
                                 ", ItemLDPrice: " + priceLink.getItemLDPrice() + 
                                 ", ItemWPrice: " + priceLink.getItemWPrice());
            }
        }
        
        System.out.println("Returning " + priceLinks.size() + " unique mapped price links (after deduplication)");
        return priceLinks;
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
        dto.setItemBarcode(priceLink.getItemBarcode());
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
    
    private InvoiceDetailResponseDTO mapToInvoiceDetailResponseDTO(InvoiceDetailTemp item) {
        InvoiceDetailResponseDTO dto = new InvoiceDetailResponseDTO();
        dto.setItemCode(item.getItemCode());
        dto.setItemBarcode(item.getItemBarcode());
        dto.setItemName(item.getItemName());
        dto.setItemCatCode(item.getItemCatCode());
        dto.setItemCatName(item.getItemCatName());
        dto.setItemUPrice(item.getItemUPrice());
        dto.setItemSPrice(item.getItemSPrice());
        dto.setItemDPrice(item.getItemDPrice());
        dto.setQty(item.getQty());
        dto.setTPrice(item.getTPrice());
        dto.setInvType(item.getInvType());
        dto.setStockId(item.getStockId());
        return dto;
    }

    @Override
    public ItemLookupResponseDTO lookupItemByBarcode(String searchTerm, String locaCode, String token) {
        System.out.println("searchTerm :" + searchTerm);
        System.out.println("locaCode :" + locaCode);
        
        // Get CompID from token
        String compId = null;
        if (token != null && !token.isEmpty()) {
            try {
                ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
                compId = userData.getCompanyId();
                System.out.println("CompID from token: " + compId);
            } catch (SQLException e) {
                System.out.println("Warning: Failed to extract CompID from token: " + e.getMessage());
            }
        }
        
        Optional<ItemDetail> itemOpt = Optional.empty();
        String foundBarcode = null;
        
        // First try to find by barcode (primary barcode) - take first result if multiple
        List<ItemDetail> items = itemDetailRepo.findByAnyBarcodeAndCompId(searchTerm,compId);
        if (!items.isEmpty()) {
            itemOpt = Optional.of(items.get(0));
            foundBarcode = searchTerm;
        }
        
//        // If not found, try alternative barcodes - take first result if multiple
//        if (itemOpt.isEmpty()) {
//            items = itemDetailRepo.findByItemBarcode1OrItemBarcode2OrItemBarcode3OrItemBarcode4(searchTerm);
//            if (!items.isEmpty()) {
//                ItemDetail foundItem = items.get(0);
//                itemOpt = Optional.of(foundItem);
//                // Determine which barcode matched
//                if (searchTerm.equals(foundItem.getItemBarcode1())) foundBarcode = foundItem.getItemBarcode1();
//                else if (searchTerm.equals(foundItem.getItemBarcode2())) foundBarcode = foundItem.getItemBarcode2();
//                else if (searchTerm.equals(foundItem.getItemBarcode3())) foundBarcode = foundItem.getItemBarcode3();
//                else if (searchTerm.equals(foundItem.getItemBarcode4())) foundBarcode = foundItem.getItemBarcode4();
//                else foundBarcode = foundItem.getItemBarcode(); // fallback to primary barcode
//            }
//        }
//
//        // If still not found, try searching by product name - take first result if multiple
//        if (itemOpt.isEmpty()) {
//            items = itemDetailRepo.findByItemNameContainingIgnoreCase(searchTerm);
//            if (!items.isEmpty()) {
//                itemOpt = Optional.of(items.get(0));
//                foundBarcode = itemOpt.get().getItemBarcode();
//            }
//        }
//
//        // Try ItemName1 - take first result if multiple
//        if (itemOpt.isEmpty()) {
//            items = itemDetailRepo.findByItemName1ContainingIgnoreCase(searchTerm);
//            if (!items.isEmpty()) {
//                itemOpt = Optional.of(items.get(0));
//                foundBarcode = itemOpt.get().getItemBarcode();
//            }
//        }
//
//        // Try ItemName2 - take first result if multiple
//        if (itemOpt.isEmpty()) {
//            items = itemDetailRepo.findByItemName2ContainingIgnoreCase(searchTerm);
//            if (!items.isEmpty()) {
//                itemOpt = Optional.of(items.get(0));
//                foundBarcode = itemOpt.get().getItemBarcode();
//            }
//        }
        
        ItemDetail item = itemOpt.orElseThrow(() -> 
            new EntryNotFoundException("Item not found for barcode or name: " + searchTerm));

        // Use the found barcode (or primary barcode) for price link lookup - filter by CompID
        String barcodeForPriceLink = foundBarcode != null ? foundBarcode : item.getItemBarcode();
        System.out.println("Looking up price links for barcode: " + barcodeForPriceLink + ", locaCode: " + locaCode + ", CompID: " + compId);
        List<PriceLink> priceLinks = findPriceLinksByBarcodeAndLocaCode(barcodeForPriceLink, locaCode, compId);
        System.out.println("Price links found: " + priceLinks.size());

        ItemLookupResponseDTO dto = new ItemLookupResponseDTO();
        dto.setItemCode(item.getItemCode());
        dto.setItemBarcode(item.getItemBarcode());
        dto.setItemBarcode1(item.getItemBarcode1());
        dto.setItemBarcode2(item.getItemBarcode2());
        dto.setItemBarcode3(item.getItemBarcode3());
        dto.setItemBarcode4(item.getItemBarcode4());
        dto.setItemName(item.getItemName());
        dto.setItemName1(item.getItemName1());
        dto.setItemName2(item.getItemName2());
        dto.setItemCatCode(item.getItemCatCode());
        dto.setItemCatName(item.getItemCatName());
        dto.setItemSubCatCode1(item.getItemSubCatCode1());
        dto.setItemSubCatName1(item.getItemSubCatName1());
        dto.setItemSubCatCode2(item.getItemSubCatCode2());
        dto.setItemSubCatName2(item.getItemSubCatName2());
        dto.setItemType(item.getItemType());
        dto.setPartNo1(item.getPartNo1());
        dto.setPartNo2(item.getPartNo2());
        dto.setPartNo3(item.getPartNo3());
        dto.setPartNo4(item.getPartNo4());
        dto.setItemMake(item.getItemMake());

        dto.setOffer("1".equals(item.getChkOffer()));
        dto.setAskSerialNoOnInvoice("1".equals(item.getAskSerialNoOnInvoice()));
        dto.setZeroPrice("1".equals(item.getChkZeroPrice()));
        dto.setDiscount("1".equals(item.getChkDiscount()));
        dto.setWholeSale("1".equals(item.getChkWholeSale()));
        dto.setLessMPrice("1".equals(item.getChkLessMPrice()));
        dto.setGreaterSPrice("1".equals(item.getChkGreaterSPrice()));
        dto.setLessUPrice("1".equals(item.getChkLessUPrice()));
        dto.setAllowDecimal("1".equals(item.getChkAllowdecimal()));
        dto.setAutoDelPriceLink("1".equals(item.getChkAutoDelPriceLink()));
        dto.setAllowLoyaltyPoints("1".equals(item.getChkAllowLoyaltyPoints()));
        dto.setAllowEditOnInv("1".equals(item.getChkAllowEditOnInv()));
        dto.setShowPriceLink("1".equals(item.getChkShowPriceLink()));
        dto.setFreezeItem("1".equals(item.getChkFreezItem()));

        dto.setOfferQty(item.getOfferQty());
        dto.setDiscountQty(item.getDiscountQty());
        dto.setWsQty(item.getWsQty());
        
        // Free quantity ranges
        dto.setFreeQty1(item.getFreeQty1());
        dto.setFreeQty2(item.getFreeQty2());
        dto.setFreeQty3(item.getFreeQty3());
        dto.setFreeIssueQty1(item.getFreeIssueQty1());
        dto.setFreeIssueQty2(item.getFreeIssueQty2());
        dto.setFreeIssueQty3(item.getFreeIssueQty3());
        
        // Discount ranges
        dto.setDiscountRange("1".equals(item.getChkActiveDiscountRange()));
        dto.setDiscountQty1(item.getDiscountQty1());
        dto.setDiscountQty2(item.getDiscountQty2());
        dto.setDiscountQty3(item.getDiscountQty3());
        dto.setDiscountQty4(item.getDiscountQty4());
        dto.setDiscountQty5(item.getDiscountQty5());
        
        // Offer ranges
        dto.setOfferRange("1".equals(item.getChkActiveOfferRange()));
        dto.setOfferQty1(item.getOfferQty1());
        dto.setOfferQty2(item.getOfferQty2());
        dto.setOfferQty3(item.getOfferQty3());
        dto.setOfferQty4(item.getOfferQty4());
        dto.setOfferQty5(item.getOfferQty5());
        
        // Wholesale ranges
        dto.setWsRange("1".equals(item.getChkActiveWSRange()));
        dto.setWsQty1(item.getWsQty1());
        dto.setWsQty2(item.getWsQty2());
        dto.setWsQty3(item.getWsQty3());
        dto.setWsQty4(item.getWsQty4());
        dto.setWsQty5(item.getWsQty5());

        dto.setOfferValidTill(item.getOfferValidTill());
        dto.setZeroPriceValidTill(item.getZeroPriceValidTill());
        dto.setDiscountValidTill(item.getDiscountValidTill());
        dto.setWholeSaleValidTill(item.getWholeSaleValidTill());
        dto.setLessMPriceValidTill(item.getLessMPriceValidTill());
        dto.setGreaterSPriceValidTill(item.getGreaterSPriceValidTill());
        dto.setLessUPriceValidTill(item.getLessUPriceValidTill());

        dto.setAllowCashDiscount("1".equals(item.getChkAllowCashDiscount()));
        dto.setAllowCusDiscount("1".equals(item.getChkAllowCusDiscount()));
        dto.setAllowStaffDiscount("1".equals(item.getChkAllowStaffDiscount()));

        dto.setUom0(item.getUom0());
        dto.setUom1(item.getUom1());
        dto.setUom2(item.getUom2());

        // Filter and map price links
        List<PriceLinkResponseDTO> priceLinkDTOs = priceLinks.stream()
                .filter(pl -> {
                    if (pl == null) {
                        System.out.println("Price link is null, filtering out");
                        return false;
                    }
                    BigDecimal uPrice = pl.getItemUPrice();
                    BigDecimal sPrice = pl.getItemSPrice();
                    boolean valid = uPrice != null && uPrice.compareTo(BigDecimal.ZERO) > 0 
                                 && sPrice != null && sPrice.compareTo(BigDecimal.ZERO) > 0;
                    if (!valid) {
                        System.out.println("Filtered out price link - ItemUPrice: " + uPrice + ", ItemSPrice: " + sPrice);
                    }
                    return valid;
                })
                .map(this::mapToPriceLinkResponseDTO)
                .collect(Collectors.toList());
        System.out.println("item lockup end point========");
        System.out.println("After filtering, " + priceLinkDTOs.size() + " valid price links remain out of " + priceLinks.size() + " total");
        System.out.println("item lockup end point========");
        dto.setPriceLinks(priceLinkDTOs);

        return dto;
    }


    @Override
    public CalculatePriceResponseDTO calculatePrice(CalculatePriceRequestDTO request) {
        // Use the new ItemPriceService for calculation
        // Build ItemPriceCalculationRequestDTO from CalculatePriceRequestDTO
        ItemPriceCalculationRequestDTO priceCalcRequest = new ItemPriceCalculationRequestDTO();
        priceCalcRequest.setItemCode(request.getItemCode());
        priceCalcRequest.setItemBarcode(request.getItemBarcode());
        priceCalcRequest.setLocaCode(request.getLocaCode());
        priceCalcRequest.setQty(request.getQty());
        priceCalcRequest.setPriceType(request.getPriceType());
        priceCalcRequest.setCustomerCode(request.getCustomerCode());
        priceCalcRequest.setPrevCusPrice(request.getPrevCusPrice());
        priceCalcRequest.setCusPriceWithoutPriceLink(request.getCusPriceWithoutPriceLink());
        priceCalcRequest.setItemUPrice(request.getItemUPrice());
        priceCalcRequest.setItemSPrice(request.getItemSPrice());
        priceCalcRequest.setItemDPrice(request.getItemDPrice());
        priceCalcRequest.setItemWPrice(request.getItemWPrice());
        priceCalcRequest.setItemOPrice(request.getItemOPrice());
        priceCalcRequest.setItemLDPrice(request.getItemLDPrice());
        priceCalcRequest.setItemMPrice(request.getItemMPrice());
        priceCalcRequest.setItemCusCatPrice1(request.getItemCusCatPrice1());
        priceCalcRequest.setItemCusCatPrice2(request.getItemCusCatPrice2());
        priceCalcRequest.setItemCusCatPrice3(request.getItemCusCatPrice3());
        priceCalcRequest.setItemCusCatPrice4(request.getItemCusCatPrice4());
        priceCalcRequest.setItemCusCatPrice5(request.getItemCusCatPrice5());
        priceCalcRequest.setAskOfferDate(request.getAskOfferDate());
        priceCalcRequest.setAskDiscountDate(request.getAskDiscountDate());
        priceCalcRequest.setAskWholeSaleDate(request.getAskWholeSaleDate());
        priceCalcRequest.setCurrentDate(LocalDate.now());
        
        // Get item details for flags and dates
        // Use custom query to handle potential duplicate itemCode in database
        List<ItemDetail> items = itemDetailRepo.findByItemCodeList(request.getItemCode());
        if (items.isEmpty()) {
            throw new EntryNotFoundException("Item not found: " + request.getItemCode());
        }
        // Take first item if multiple exist (handles duplicate itemCode issue)
        ItemDetail item = items.get(0);
        
        // Set item flags
        priceCalcRequest.setBoolItemOffer("1".equals(item.getChkOffer()));
        priceCalcRequest.setBoolItemDiscount("1".equals(item.getChkDiscount()));
        priceCalcRequest.setBoolWholeSale("1".equals(item.getChkWholeSale()));
        priceCalcRequest.setOfferValidTill(item.getOfferValidTill());
        priceCalcRequest.setDiscountValidTill(item.getDiscountValidTill());
        priceCalcRequest.setWholeSaleValidTill(item.getWholeSaleValidTill());
        
        // Get OWS ranges from PriceLink if available
        // Note: calculatePrice doesn't receive token, so pass null for compId (fallback will try without CompID filter)
        if (request.getItemBarcode() != null && request.getLocaCode() != null) {
            List<PriceLink> priceLinks = findPriceLinksByBarcodeAndLocaCode(
                request.getItemBarcode(), request.getLocaCode(), null);
            if (!priceLinks.isEmpty()) {
                PriceLink priceLink = priceLinks.get(0); // Use first price link
                populateOWSFromPriceLink(priceCalcRequest, priceLink);
            }
        }
        
        // Calculate price using ItemPriceService
        ItemPriceCalculationResponseDTO priceCalcResponse = itemPriceService.calculateItemPrice(priceCalcRequest);
        
        // Map to CalculatePriceResponseDTO
        CalculatePriceResponseDTO response = new CalculatePriceResponseDTO();
        response.setFinalPrice(priceCalcResponse.getFinalPrice());
        response.setTotalPrice(priceCalcResponse.getTotalPrice());
        response.setProfit(priceCalcResponse.getProfit());
        response.setInvType(priceCalcResponse.getInvType());
        response.setPriceChangeType(priceCalcResponse.getPriceChangeType());
        response.setIsPriceChange(priceCalcResponse.getIsPriceChange());
        response.setHasCustomerDiscount(priceCalcResponse.getHasCustomerDiscount());
        response.setCustomerDiscountPrice(priceCalcResponse.getCustomerDiscountPrice());
        
        return response;
    }
    
    private void populateOWSFromPriceLink(ItemPriceCalculationRequestDTO request, PriceLink priceLink) {
        // Get item details for OWS range flags
        // Use custom query to handle potential duplicate itemCode in database
        List<ItemDetail> items = itemDetailRepo.findByItemCodeList(request.getItemCode());
        Optional<ItemDetail> itemOpt = items.isEmpty() ? Optional.empty() : Optional.of(items.get(0));
        if (itemOpt.isPresent()) {
            ItemDetail item = itemOpt.get();
            request.setDiscountRange("1".equals(item.getChkActiveDiscountRange()));
            request.setOfferRange("1".equals(item.getChkActiveOfferRange()));
            request.setWsRange("1".equals(item.getChkActiveWSRange()));
        }
        
        // Populate discount prices and quantities
        request.setDiscountPrice1(priceLink.getDiscountPrice1());
        request.setDiscountPrice2(priceLink.getDiscountPrice2());
        request.setDiscountPrice3(priceLink.getDiscountPrice3());
        request.setDiscountPrice4(priceLink.getDiscountPrice4());
        request.setDiscountPrice5(priceLink.getDiscountPrice5());
        
        // Populate offer prices
        request.setOfferPrice1(priceLink.getOfferPrice1());
        request.setOfferPrice2(priceLink.getOfferPrice2());
        request.setOfferPrice3(priceLink.getOfferPrice3());
        request.setOfferPrice4(priceLink.getOfferPrice4());
        request.setOfferPrice5(priceLink.getOfferPrice5());
        
        // Populate wholesale prices
        request.setWsPrice1(priceLink.getWsPrice1());
        request.setWsPrice2(priceLink.getWsPrice2());
        request.setWsPrice3(priceLink.getWsPrice3());
        request.setWsPrice4(priceLink.getWsPrice4());
        request.setWsPrice5(priceLink.getWsPrice5());
        
        // Get quantities from ItemDetail
        if (itemOpt.isPresent()) {
            ItemDetail item = itemOpt.get();
            request.setDiscountQty1(item.getDiscountQty1());
            request.setDiscountQty2(item.getDiscountQty2());
            request.setDiscountQty3(item.getDiscountQty3());
            request.setDiscountQty4(item.getDiscountQty4());
            request.setDiscountQty5(item.getDiscountQty5());
            request.setOfferQty1(item.getOfferQty1());
            request.setOfferQty2(item.getOfferQty2());
            request.setOfferQty3(item.getOfferQty3());
            request.setOfferQty4(item.getOfferQty4());
            request.setOfferQty5(item.getOfferQty5());
            request.setWsQty1(item.getWsQty1());
            request.setWsQty2(item.getWsQty2());
            request.setWsQty3(item.getWsQty3());
            request.setWsQty4(item.getWsQty4());
            request.setWsQty5(item.getWsQty5());
        }
    }
    
    @Override
    public List<com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.MobileInvoiceListResponseDTO> getMobileInvoices(String locaCode, Boolean itMerged) {
        List<com.ms.semicolans.sereportapi.sereportapi.entity.MobileInvoiceHeader> invoices;
        
        if (locaCode != null && !locaCode.isEmpty()) {
            if (itMerged != null) {
                invoices = mobileInvoiceHeaderRepo.findAll().stream()
                    .filter(inv -> locaCode.equals(inv.getLocaCode()) && 
                                  itMerged.equals(inv.getItMerged()))
                    .collect(java.util.stream.Collectors.toList());
                } else {
                invoices = mobileInvoiceHeaderRepo.findAll().stream()
                    .filter(inv -> locaCode.equals(inv.getLocaCode()))
                    .collect(java.util.stream.Collectors.toList());
                }
            } else {
            if (itMerged != null) {
                invoices = mobileInvoiceHeaderRepo.findAll().stream()
                    .filter(inv -> itMerged.equals(inv.getItMerged()))
                    .collect(java.util.stream.Collectors.toList());
                } else {
                invoices = mobileInvoiceHeaderRepo.findAll();
            }
        }
        
        return invoices.stream()
            .map(this::mapToMobileInvoiceListResponseDTO)
            .collect(java.util.stream.Collectors.toList());
    }
    
    private com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.MobileInvoiceListResponseDTO mapToMobileInvoiceListResponseDTO(
            com.ms.semicolans.sereportapi.sereportapi.entity.MobileInvoiceHeader header) {
        com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.MobileInvoiceListResponseDTO dto = 
            new com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.MobileInvoiceListResponseDTO();
        dto.setId(header.getId());
        dto.setClientId(header.getClientId());
        dto.setSerialNo(header.getSerialNo());
        dto.setInvoiceNo(header.getInvoiceNo());
        dto.setLocaCode(header.getLocaCode());
        dto.setUnitNo(header.getUnitNo());
        dto.setCompId(header.getCompId());
        dto.setInvType(header.getInvType());
        dto.setCustomerCode(header.getCustomerCode());
        dto.setGrandTotal(header.getGrandTotal());
        dto.setItemCount(header.getItemCount());
        dto.setCreatedAt(header.getCreatedAt());
        dto.setUpdatedAt(header.getUpdatedAt());
        dto.setMergeStatus(header.getMergeStatus());
        dto.setItMerged(header.getItMerged());
        dto.setMergeTime(header.getMergeTime());
        dto.setMerged(header.getMerged());
        return dto;
    }

    @Override
    public LastInvPriceResponseDTO getLastInvPriceByCustomer(String cusCode, String itemCode, String barcode, String token) {
        String compId = extractCompIdFromToken(token);
        if (compId == null) {
            return LastInvPriceResponseDTO.builder().build();
        }
        Map<String, Object> row = lastInvPriceRepo.getLastInvPriceByCustomer(cusCode, itemCode, barcode, compId);
        return mapToLastInvPriceResponse(row);
    }

    @Override
    public LastInvPriceResponseDTO getLastInvPriceByItem(String itemCode, String barcode, String token) {
        String compId = extractCompIdFromToken(token);
        if (compId == null) {
            System.out.println("getLastInvPriceByItem: compId is null (token extraction failed)");
            return LastInvPriceResponseDTO.builder().build();
        }
        Map<String, Object> row = lastInvPriceRepo.getLastInvPriceByItem(itemCode, barcode, compId);
        if (row == null) {
            System.out.println("getLastInvPriceByItem: no rows found for itemCode=" + itemCode + ", compId=" + compId);
        } else {
            System.out.println("getLastInvPriceByItem: row keys=" + row.keySet() + ", row=" + row);
        }
        return mapToLastInvPriceResponse(row);
    }

    private String extractCompIdFromToken(String token) {
        if (token == null || token.isEmpty()) return null;
        try {
            ResponseCompanyUserDataDTO userData = companyUserService.getUserAllData(token);
            return userData.getCompanyId();
        } catch (SQLException e) {
            System.out.println("Failed to extract CompID from token: " + e.getMessage());
            return null;
        }
    }

    private LastInvPriceResponseDTO mapToLastInvPriceResponse(Map<String, Object> row) {
        System.out.println("map to history");
        System.out.println(row);
        if (row == null) return LastInvPriceResponseDTO.builder().build();
        // SQL Server JDBC may return keys in different casing
        Object itemDPriceObj = getMapValueCaseInsensitive(row, "ItemDPrice", "itemDPrice", "ITEMDPRICE");
        Object qtyObj = getMapValueCaseInsensitive(row, "Qty", "qty", "QTY");
        System.out.println(itemDPriceObj);
        System.out.println(qtyObj);
        BigDecimal itemDPrice = null;
        Integer qty = null;
        if (itemDPriceObj != null) {
            if (itemDPriceObj instanceof BigDecimal) itemDPrice = (BigDecimal) itemDPriceObj;
            else if (itemDPriceObj instanceof Number) itemDPrice = BigDecimal.valueOf(((Number) itemDPriceObj).doubleValue());
        }
        if (qtyObj != null && qtyObj instanceof Number) {
            qty = ((Number) qtyObj).intValue();
        }
        return LastInvPriceResponseDTO.builder()
                .itemDPrice(itemDPrice)
                .qty(qty)
                .build();
    }

    private Object getMapValueCaseInsensitive(Map<String, Object> map, String... keys) {
        for (String key : keys) {
            if (map.containsKey(key)) return map.get(key);
        }
        for (Map.Entry<String, Object> e : map.entrySet()) {
            for (String key : keys) {
                if (key.equalsIgnoreCase(e.getKey())) return e.getValue();
            }
        }
        return null;
    }
}

