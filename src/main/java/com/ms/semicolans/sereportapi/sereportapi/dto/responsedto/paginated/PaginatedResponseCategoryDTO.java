package com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.paginated;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCategoryDTO;
import lombok.*;

import java.util.List;
@AllArgsConstructor
@Getter
@Setter
@Builder
@NoArgsConstructor
public class PaginatedResponseCategoryDTO {
    private Long count;
    private List<ResponseCategoryDTO> data;
}
