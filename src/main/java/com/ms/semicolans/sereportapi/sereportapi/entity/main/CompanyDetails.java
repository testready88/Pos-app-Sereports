package com.ms.semicolans.sereportapi.sereportapi.entity.main;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import java.time.LocalDate;

@Entity
@Getter
@Setter
@RequiredArgsConstructor
@AllArgsConstructor
@Table(name = "tbl_CompanyDetails")
public class CompanyDetails {

    @Id
    @Column(name = "CompID")
    private String companyId;

    @Column(name = "UserName")
    private String username;

    @Column(name = "CompName")
    private String companyName;

    @Column(name = "UserPassword")
    private String password;

    @Column(name = "pinnumber")
    private String pinnumber;

    @Column(name = "UserType")
    private String userType;

    @Column(name = "Status")
    private String status;

    @Column(name = "ExpiryDate")
    private LocalDate expiryDate;

    @Column(name = "EmailID")
    private String emailId;

    @Column(name = "PinCode")
    private String pinCode;

    @Column(name = "DBName")
    private String dbName;

    @Column(name = "CompleteName")
    private String completeName;

    @Column(name = "SecretKey")
    private String secretKey;
}