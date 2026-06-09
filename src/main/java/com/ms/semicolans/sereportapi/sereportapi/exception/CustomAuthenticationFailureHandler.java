package com.ms.semicolans.sereportapi.sereportapi.exception;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class CustomAuthenticationFailureHandler implements AuthenticationFailureHandler {

    @Override
    public void onAuthenticationFailure(HttpServletRequest request,
                                        HttpServletResponse response,
                                        AuthenticationException exception) throws IOException, ServletException {

        log.error("\n\n========== AUTHENTICATION FAILED ==========");
        log.error("Exception Type: {}", exception.getClass().getSimpleName());
        log.error("Message: {}", exception.getMessage());

        response.setContentType(MediaType.APPLICATION_JSON_VALUE);

        String message = exception.getMessage();
        int statusCode = 401;

        // Check the CAUSE of the exception
        Throwable cause = exception.getCause();
        if (cause != null) {
            log.error("Cause Type: {}", cause.getClass().getSimpleName());
            log.error("Cause Message: {}", cause.getMessage());

            if (cause instanceof PaymentRequiredException) {
                statusCode = 402;
                log.error("→ HTTP 402 PAYMENT REQUIRED: Subscription expired");
            } else if (cause instanceof IllegalAccessException) {
                statusCode = 403;
                log.error("→ HTTP 403 FORBIDDEN: No SeReportsLogin access");
            } else {
                statusCode = 401;
                log.error("→ HTTP 401 UNAUTHORIZED: {}", cause.getClass().getSimpleName());
            }
        } else {
            statusCode = 401;
            log.error("→ HTTP 401 UNAUTHORIZED: No cause, using exception message");
        }

        response.setStatus(statusCode);

        Map<String, Object> body = new HashMap<>();
        body.put("code", statusCode);
        body.put("message", message != null ? message : "Authentication failed");

        log.error("Response: {} | {}", statusCode, message);
        log.error("========== END FAILURE HANDLER ==========\n");

        ObjectMapper mapper = new ObjectMapper();
        mapper.writeValue(response.getOutputStream(), body);
    }
}