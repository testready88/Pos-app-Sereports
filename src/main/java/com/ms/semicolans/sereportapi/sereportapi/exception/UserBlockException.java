package com.ms.semicolans.sereportapi.sereportapi.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.LOCKED)
public class UserBlockException extends RuntimeException{
    public UserBlockException(String message) {
        super(message);
    }
}
