package com.ms.semicolans.sereportapi.sereportapi.api;

import java.sql.SQLException;

import javax.crypto.SecretKey;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ms.semicolans.sereportapi.sereportapi.service.UserService;
import com.ms.semicolans.sereportapi.sereportapi.util.StandardResponse;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureException;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/user")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    private final SecretKey secretKey;

    //////removed preauthorize
    @GetMapping(path = {"/get-user-details"})
    public ResponseEntity<StandardResponse> getUserDetails
            (@RequestHeader("Authorization") String token) {
        try {
            return new ResponseEntity<>(
                    new StandardResponse(200, "User details", userService.getUserDetails(token))
                    , HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(
                    new StandardResponse(500, "Error: " + e.getMessage(), null),
                    HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    /**
     * Retrieves all permissions for the authenticated user from tbl_UserAccounts.
     * Called immediately after a successful login.
     * Returns all chk* columns and identity fields.
     */
    //////removed preauthorize
    @GetMapping(path = {"/get-user-permissions"})
    public ResponseEntity<StandardResponse> getUserPermissions
            (@RequestHeader("Authorization") String token) throws SQLException {
        try {
            // Extract username from JWT token
            String bearerToken = token.replace("Bearer ", "");
            String username = Jwts.parser()
                    .setSigningKey(secretKey)
                    .parseClaimsJws(bearerToken)
                    .getBody()
                    .getSubject();

            // Fetch the user account with all permissions
            Object userAccount = userService.getUserAccountWithPermissions(username);

            return new ResponseEntity<>(
                    new StandardResponse(200, "User permissions", userAccount),
                    HttpStatus.OK
            );
        } catch (SignatureException e) {
            return new ResponseEntity<>(
                    new StandardResponse(401, "Invalid token", null),
                    HttpStatus.UNAUTHORIZED
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                    new StandardResponse(500, "Error fetching permissions: " + e.getMessage(), null),
                    HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }
}
