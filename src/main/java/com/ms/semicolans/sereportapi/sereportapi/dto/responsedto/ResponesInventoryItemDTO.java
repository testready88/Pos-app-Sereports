package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto;

import lombok.*;

@Data
@AllArgsConstructor
@Builder
public class ResponesInventoryItemDTO {
    private String compId;
    private String locaCode;
    private String stockId;
    private String itemCode;
    private String itemBarcode;
    private String itemName;
    private Double qtyRemain;
    private Double itemAvgCost;
    private Double itemUPrice;
    private Double itemSPrice;
    private Double itemDPrice;
    private String itemCatName;
    private String itemSubCatName1;
    private String itemSupName;
    private String productImg1;
}