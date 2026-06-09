package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.entity.PriceLink;
import com.ms.semicolans.sereportapi.sereportapi.entity.PriceLinkId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface PriceLinkRepo extends JpaRepository<PriceLink, PriceLinkId> {
    
    @Query(value = "SELECT * FROM tbl_PriceLink1 WHERE ItemBarcode = :itemBarcode " +
           "AND LocaCode = :locaCode " +
           "AND ItemUPrice <> 0 AND ItemSPrice <> 0 " +
           "ORDER BY QtyRemain ASC", nativeQuery = true)
    List<PriceLink> findByItemBarcodeAndLocaCode(
            @Param("itemBarcode") String itemBarcode,
            @Param("locaCode") String locaCode);
    
    @Query(value = "SELECT * FROM tbl_PriceLink1 WHERE ItemBarcode = :itemBarcode " +
           "AND LocaCode = :locaCode AND StockID = :stockId " +
           "AND ItemUPrice <> 0 AND ItemSPrice <> 0 " +
           "ORDER BY QtyRemain ASC", nativeQuery = true)
    List<PriceLink> findByItemBarcodeAndLocaCodeAndStockId(
            @Param("itemBarcode") String itemBarcode,
            @Param("locaCode") String locaCode,
            @Param("stockId") String stockId);
    
    @Query(value = "SELECT * FROM tbl_PriceLink1 WHERE ItemBarcode = :itemBarcode " +
           "AND LocaCode = :locaCode AND StockID = :stockId " +
           "AND ItemUPrice = :itemUPrice AND ItemSPrice = :itemSPrice " +
           "AND ItemUPrice <> 0 AND ItemSPrice <> 0 " +
           "ORDER BY QtyRemain ASC", nativeQuery = true)
    List<PriceLink> findByItemBarcodeAndLocaCodeAndStockIdAndPrices(
            @Param("itemBarcode") String itemBarcode,
            @Param("locaCode") String locaCode,
            @Param("stockId") String stockId,
            @Param("itemUPrice") BigDecimal itemUPrice,
            @Param("itemSPrice") BigDecimal itemSPrice);
}

