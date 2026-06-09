package com.ms.semicolans.sereportapi.sereportapi.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.METHOD_NOT_ALLOWED)
public class RestrictedAreaException extends RuntimeException {
    public RestrictedAreaException(String message) {
        super(message);
    }
}
