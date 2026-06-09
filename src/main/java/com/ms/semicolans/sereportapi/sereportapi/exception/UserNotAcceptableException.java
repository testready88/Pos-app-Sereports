package com.ms.semicolans.sereportapi.sereportapi.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.NOT_ACCEPTABLE)
public class UserNotAcceptableException extends RuntimeException {
    public UserNotAcceptableException(String message) {
        super(message);
    }
}
