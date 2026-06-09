package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.entity.main.CompanyDetails;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface CompanyDetailsRepo extends JpaRepository<CompanyDetails, String> {

    Optional<CompanyDetails> findByUsername(String username);
    Optional<CompanyDetails> findByUsernameAndPinnumber(String username, String pinnumber);
    Optional<CompanyDetails> findByPinnumber(String pinnumber);
}