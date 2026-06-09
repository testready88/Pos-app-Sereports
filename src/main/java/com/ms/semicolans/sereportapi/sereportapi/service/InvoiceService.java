package com.ms.semicolans.sereportapi.sereportapi.service;


import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.InvoiceCreateRequestDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.InvoiceResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.PriceLinkResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.InvoiceCreateResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ItemLookupResponseDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.requestdto.CalculatePriceRequestDTO;
import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.CalculatePriceResponseDTO;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.LastInvPriceResponseDTO;

import java.math.BigDecimal;
import java.util.List;

public interface InvoiceService {

    LastInvPriceResponseDTO getLastInvPriceByCustomer(String cusCode, String itemCode, String barcode, String token);

    LastInvPriceResponseDTO getLastInvPriceByItem(String itemCode, String barcode, String token);

    List<PriceLinkResponseDTO> checkPriceLink(String itemBarcode, String locaCode, String stockId,
                                              BigDecimal itemUPrice, BigDecimal itemSPrice,
                                              Boolean updateMode, Boolean itemPriceShortCutMode, String token);
    

    InvoiceResponseDTO getInvoiceDetails(String serialNo, String locaCode);

    InvoiceCreateResponseDTO createInvoice(InvoiceCreateRequestDTO request, String token);

    ItemLookupResponseDTO lookupItemByBarcode(String searchTerm, String locaCode, String token);
    
    CalculatePriceResponseDTO calculatePrice(CalculatePriceRequestDTO request);
    
    List<com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.MobileInvoiceListResponseDTO> getMobileInvoices(String locaCode, Boolean itMerged);
}

