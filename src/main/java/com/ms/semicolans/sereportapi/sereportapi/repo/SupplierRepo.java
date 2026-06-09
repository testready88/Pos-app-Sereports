package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.entity.main.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SupplierRepo extends JpaRepository<Supplier, Long> {
    // Find all supplier names for dropdown (returns full objects, we'll extract names in service)
    List<Supplier> findByActiveSupplier(String activeSupplier);
}