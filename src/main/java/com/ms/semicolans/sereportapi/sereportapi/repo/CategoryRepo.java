package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.entity.main.Category;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.stereotype.Repository;


public interface CategoryRepo extends JpaRepository<Category, Integer> {


    @Query(value = "SELECT * FROM eCommerceCategory WHERE name LIKE '%' + ?1 + '%'", nativeQuery = true)
    Page<Category> getCategories(String searchText,  Pageable pageable);
    @Query(value = "SELECT COUNT(*) FROM eCommerceCategory WHERE name LIKE '%' + ?1 + '%'", nativeQuery = true)
    long countBrands(String searchText);
}
