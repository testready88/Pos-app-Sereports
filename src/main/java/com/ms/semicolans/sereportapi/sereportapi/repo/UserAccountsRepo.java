package com.ms.semicolans.sereportapi.sereportapi.repo;

import com.ms.semicolans.sereportapi.sereportapi.entity.main.UserAccounts;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface UserAccountsRepo extends JpaRepository<UserAccounts, Long> {

    List<UserAccounts> findByUserName(String userName);
    List<UserAccounts> findByUserNameAndPinnumber(String userName, String pinnumber);
    List<UserAccounts> findByUserNameAndUserPasswordAndPinnumber(
            String userName, String userPassword, String pinnumber);
}