package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.entity.ItemDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ItemDetailRepo extends JpaRepository<ItemDetail, String> {

    @Query(
            value = """
        SELECT * FROM tbl_ItemDet
        WHERE (
            ItemBarcode  = :itemBarcode
            OR ItemBarcode1 = :itemBarcode
            OR ItemBarcode2 = :itemBarcode
            OR ItemBarcode3 = :itemBarcode
            OR ItemBarcode4 = :itemBarcode
        )
        AND CompId = :compId
        AND (ActiveItem = '1' OR ActiveItem IS NULL)
        """,
            nativeQuery = true
    )
    List<ItemDetail> findByAnyBarcodeAndCompId(
            @Param("itemBarcode") String itemBarcode,
            @Param("compId") String compId
    );

    
    @Query("SELECT i FROM ItemDetail i WHERE (i.itemBarcode1 = :barcode OR i.itemBarcode2 = :barcode OR i.itemBarcode3 = :barcode OR i.itemBarcode4 = :barcode) AND (i.activeItem = '1' OR i.activeItem IS NULL)")
    List<ItemDetail> findByItemBarcode1OrItemBarcode2OrItemBarcode3OrItemBarcode4(
            @Param("barcode") String barcode);
    
    @Query("SELECT i FROM ItemDetail i WHERE i.itemName LIKE %:itemName% AND (i.activeItem = '1' OR i.activeItem IS NULL)")
    List<ItemDetail> findByItemNameContainingIgnoreCase(@Param("itemName") String itemName);
    
    @Query("SELECT i FROM ItemDetail i WHERE i.itemName1 LIKE %:itemName1% AND (i.activeItem = '1' OR i.activeItem IS NULL)")
    List<ItemDetail> findByItemName1ContainingIgnoreCase(@Param("itemName1") String itemName1);
    
    @Query("SELECT i FROM ItemDetail i WHERE i.itemName2 LIKE %:itemName2% AND (i.activeItem = '1' OR i.activeItem IS NULL)")
    List<ItemDetail> findByItemName2ContainingIgnoreCase(@Param("itemName2") String itemName2);
    
    // Custom query to handle duplicate itemCode - returns List and take first
    @Query("SELECT i FROM ItemDetail i WHERE i.itemCode = :itemCode AND (i.activeItem = '1' OR i.activeItem IS NULL)")
    List<ItemDetail> findByItemCodeList(@Param("itemCode") String itemCode);
}

