package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponesInventoryItemDTO;
import lombok.*;

import java.util.List;

@AllArgsConstructor
@Getter
@Setter
@Builder
public class PaginatedResponseProductInventoryDTO {
    private Long count;
    private List<ResponesInventoryItemDTO> data;
}
