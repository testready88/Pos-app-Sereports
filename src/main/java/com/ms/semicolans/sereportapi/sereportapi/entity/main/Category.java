package com.ms.semicolans.sereportapi.sereportapi.entity.main;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Entity
@Getter
@Setter
@RequiredArgsConstructor
@AllArgsConstructor
@Table(name = "eCommerceCategory")
public class Category {
    @Id
    @Column(length = 4, name = "id")
    private Integer id;

    @Column(length = 255, name = "Name")
    @NotNull
    private String name;

    @Column(length = 8, name = "Code")
    @NotNull
    private String code;


}