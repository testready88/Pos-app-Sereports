package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

import javax.crypto.SecretKey;

import org.springframework.stereotype.Service;

import com.ms.semicolans.sereportapi.sereportapi.entity.main.CompanyDetails;
import com.ms.semicolans.sereportapi.sereportapi.entity.main.UserAccounts;
import com.ms.semicolans.sereportapi.sereportapi.jwt.JwtConfig;
import com.ms.semicolans.sereportapi.sereportapi.repo.CompanyDetailsRepo;
import com.ms.semicolans.sereportapi.sereportapi.repo.UserAccountsRepo;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;
import com.ms.semicolans.sereportapi.sereportapi.service.UserService;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final CompanyUserService companyUserService;
    private final CompanyDetailsRepo companyDetailsRepo;
    private final UserAccountsRepo userAccountsRepo;
    private final JwtConfig jwtConfig;
    private final SecretKey secretKey;
    
    @Override
    public String getUserDetails(String token) throws SQLException {
        try {
            String realToken = token.replace(jwtConfig.getTokenPrefix(), "");
            Jws<Claims> claimsJws = Jwts.parser()
                    .setSigningKey(secretKey)
                    .parseClaimsJws(realToken);
            String username = claimsJws.getBody().getSubject();
            Optional<CompanyDetails> selectedUser = companyDetailsRepo.findByUsername(username);
            if (selectedUser.isEmpty()) {
                throw new SQLException("User not found: " + username);
            }
            return selectedUser.get().getCompanyName();
        } catch (Exception e) {
            throw new SQLException("Failed to get user details", e);
        }
    }

    @Override
    public Object getUserAccountWithPermissions(String username) throws SQLException {
        List<UserAccounts> users = userAccountsRepo.findByUserName(username);
        if (users.isEmpty()) {
            throw new SQLException("User not found: " + username);
        }
        return users.get(0);
    }
}