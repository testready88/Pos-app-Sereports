package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.entity.CustomerDiscount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Optional;

@Repository
public interface CustomerDiscountRepo extends JpaRepository<CustomerDiscount, Long> {
    
    @Query("SELECT c FROM CustomerDiscount c WHERE c.cusCode = :cusCode " +
           "AND c.itemCode = :itemCode AND c.itemDPrice <> 0")
    Optional<CustomerDiscount> findByCusCodeAndItemCode(
            @Param("cusCode") String cusCode,
            @Param("itemCode") String itemCode);
    
    @Query("SELECT c FROM CustomerDiscount c WHERE c.cusCode = :cusCode " +
           "AND c.itemCode = :itemCode AND c.itemDPrice <> 0 " +
           "AND c.itemUPrice = :itemUPrice AND c.itemSPrice = :itemSPrice")
    Optional<CustomerDiscount> findByCusCodeAndItemCodeAndPrices(
            @Param("cusCode") String cusCode,
            @Param("itemCode") String itemCode,
            @Param("itemUPrice") BigDecimal itemUPrice,
            @Param("itemSPrice") BigDecimal itemSPrice);
}

