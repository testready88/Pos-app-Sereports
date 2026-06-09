package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.entity.NextNumber;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface NextNumberRepo extends JpaRepository<NextNumber, Long> {
    
    @Modifying
    @Query("UPDATE NextNumber n SET n.creditPayment = n.creditPayment + 1")
    void incrementCreditPayment();
    
    @Modifying
    @Query("UPDATE NextNumber n SET n.invCodeN = n.invCodeN + 1")
    void incrementInvCodeN();
    
    @Modifying
    @Query("UPDATE NextNumber n SET n.invCodeM = n.invCodeM + 1")
    void incrementInvCodeM();
}

