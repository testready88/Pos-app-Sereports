package com.ms.semicolans.sereportapi.sereportapi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "tbl_NextNumber")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class NextNumber {
    
    // Using InvCodeN as the primary key since the table doesn't have an 'id' column
    // This assumes InvCodeN is unique (which it should be for a sequence table)
    @Id
    @Column(name = "InvCodeN")
    private Long invCodeN;
    
    @Column(name = "InvCodeM")
    private Long invCodeM;
    
    @Column(name = "CreditPayment")
    private Long creditPayment;
}

