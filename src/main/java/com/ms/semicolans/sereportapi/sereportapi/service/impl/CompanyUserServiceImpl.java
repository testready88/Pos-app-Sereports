package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

import javax.crypto.SecretKey;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseCompanyUserDataDTO;
import com.ms.semicolans.sereportapi.sereportapi.entity.main.CompanyDetails;
import com.ms.semicolans.sereportapi.sereportapi.entity.main.UserAccounts;
import com.ms.semicolans.sereportapi.sereportapi.jwt.JwtConfig;
import com.ms.semicolans.sereportapi.sereportapi.repo.CompanyDetailsRepo;
import com.ms.semicolans.sereportapi.sereportapi.repo.UserAccountsRepo;
import com.ms.semicolans.sereportapi.sereportapi.service.CompanyUserService;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class CompanyUserServiceImpl implements CompanyUserService {
    private final CompanyDetailsRepo companyDetailsRepo;
    private final UserAccountsRepo userAccountsRepo;
    private final JwtConfig jwtConfig;
    private final SecretKey secretKey;


    @Override
    public ResponseCompanyUserDataDTO getUserAllData(String token) throws SQLException {
        try {
            String realToken = token.replace(jwtConfig.getTokenPrefix(), "");
            Jws<Claims> claimsJws = Jwts.parser()
                    .setSigningKey(secretKey)
                    .parseClaimsJws(realToken);
            String username = claimsJws.getBody().getSubject();

            // Find user by username to get their pinnumber
            List<UserAccounts> users = userAccountsRepo.findByUserName(username);
            if (users.isEmpty()) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User not found: " + username);
            }
            String pinnumber = users.get(0).getPinnumber();

            // Find company by pinnumber
            Optional<CompanyDetails> company = companyDetailsRepo.findByPinnumber(pinnumber);
            if (company.isEmpty()) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Company not found for pin");
            }

            return new ResponseCompanyUserDataDTO(
                    company.get().getCompanyId(),
                    company.get().getUserType()
            );
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Authentication failed", e);
        }
    }
}
