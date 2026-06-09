package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.entity.MobileInvoiceHeader;
import com.ms.semicolans.sereportapi.sereportapi.entity.MobileInvoiceItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MobileInvoiceItemRepo extends JpaRepository<MobileInvoiceItem, Long> {
    List<MobileInvoiceItem> findByHeader(MobileInvoiceHeader header);
}


