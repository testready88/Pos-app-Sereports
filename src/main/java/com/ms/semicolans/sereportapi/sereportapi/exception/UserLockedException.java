package com.ms.semicolans.sereportapi.sereportapi.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.LOCKED)
public class UserLockedException extends RuntimeException {
    public UserLockedException(String message) {
        super(message);
    }
}
