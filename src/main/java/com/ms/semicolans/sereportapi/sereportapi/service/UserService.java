package com.ms.semicolans.sereportapi.sereportapi.service;

import com.ms.semicolans.sereportapi.sereportapi.dto.responsedto.ResponseUserDTO;

import java.sql.SQLException;

public interface UserService {
    String getUserDetails(String token) throws SQLException;
    
    /**
     * Retrieves the user account with all permission columns (chk*) from tbl_UserAccounts.
     * Used for populating the app's permission cache after login.
     */
    Object getUserAccountWithPermissions(String username) throws SQLException;
}
