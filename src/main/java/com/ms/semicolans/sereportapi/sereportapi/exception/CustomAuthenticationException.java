package com.ms.semicolans.sereportapi.sereportapi.exception;

import org.springframework.security.core.AuthenticationException;

/**
 * Custom Spring Security exception that preserves the original cause
 * so the failure handler can inspect it and return the correct HTTP status code.
 */

public class CustomAuthenticationException extends AuthenticationException {
    public CustomAuthenticationException(String msg, Throwable cause) {
        super(msg, cause);
    }
}
