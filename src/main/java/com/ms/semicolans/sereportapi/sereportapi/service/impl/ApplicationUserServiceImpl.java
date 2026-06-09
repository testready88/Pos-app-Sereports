package com.ms.semicolans.sereportapi.sereportapi.service.impl;

import com.ms.semicolans.sereportapi.sereportapi.entity.main.CompanyDetails;
import com.ms.semicolans.sereportapi.sereportapi.entity.main.UserAccounts;
import com.ms.semicolans.sereportapi.sereportapi.repo.CompanyDetailsRepo;
import com.ms.semicolans.sereportapi.sereportapi.repo.UserAccountsRepo;
import com.ms.semicolans.sereportapi.sereportapi.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static com.ms.semicolans.sereportapi.sereportapi.security.ApplicationUserRole.ADMIN;

@Service
@RequiredArgsConstructor
public class ApplicationUserServiceImpl implements UserDetailsService {

    private final CompanyDetailsRepo companyDetailsRepo;
    private final UserAccountsRepo userAccountsRepo;
    private final JwtUtil jwtUtil;

    // ---------- UserDetailsService method (required by Spring Security) ----------
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Optional<CompanyDetails> systemUser = companyDetailsRepo.findByUsername(username);
        if (systemUser.isPresent()) {
            return buildUserDetails(systemUser.get());
        } else {
            throw new UsernameNotFoundException(String.format("username %s not found", username));
        }
    }

    // ---------- New login validation methods ----------
    public UserAccounts validateCredentials(String username, String password, String pinnumber) {
        List<UserAccounts> matches = userAccountsRepo.findByUserNameAndUserPasswordAndPinnumber(
                username, password, pinnumber);
        if (matches.isEmpty()) {
            throw new UsernameNotFoundException("Invalid Username, Password, or Pin Number.");
        }
        return matches.get(0);
    }

    public void validateSeReportsAccess(UserAccounts user) {
        String access = user.getSeReportsLogin();
        if (access == null || access.trim().isEmpty() || !access.trim().equals("1")) {
            throw new IllegalArgumentException("You do not have access for SeReports.");
        }
    }

    public void validateSubscriptionExpiry(String pinnumber) {
        CompanyDetails company = companyDetailsRepo.findByPinnumber(pinnumber)
                .orElseThrow(() -> new IllegalStateException("Your SeReports Subscription has expired."));
        LocalDate expiry = company.getExpiryDate();
        if (expiry == null || expiry.isBefore(LocalDate.now())) {
            throw new IllegalStateException("Your SeReports Subscription has expired.");
        }
    }

    public String generateJwt(String username) {
        return jwtUtil.generateToken(username);
    }

    public UserAccounts getUserAccountByUsername(String username) {
        List<UserAccounts> users = userAccountsRepo.findByUserName(username);
        if (users.isEmpty()) {
            throw new UsernameNotFoundException("User not found: " + username);
        }
        return users.get(0);
    }

    public String getUsernameFromToken(String token) {
        return jwtUtil.extractUsername(token);
    }

    // ---------- Helper using Spring's built-in User class ----------
    private UserDetails buildUserDetails(CompanyDetails systemUser) {
        Set<SimpleGrantedAuthority> grantedAuthorities = new HashSet<>();
        if (systemUser.getUserType().trim().equalsIgnoreCase("Admin")) {
            grantedAuthorities.addAll(ADMIN.getGrantedAuthorities());
        }
        boolean isActive = systemUser.getStatus().trim().equalsIgnoreCase("Active");
        return User.builder()
                .username(systemUser.getUsername())
                .password(systemUser.getPassword())
                .authorities(grantedAuthorities)
                .accountExpired(false)
                .accountLocked(false)
                .credentialsExpired(false)
                .disabled(!isActive)
                .build();
    }
}