package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.entity.MobileInvoiceHeader;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MobileInvoiceHeaderRepo extends JpaRepository<MobileInvoiceHeader, Long> {
    Optional<MobileInvoiceHeader> findByClientId(String clientId);
}


