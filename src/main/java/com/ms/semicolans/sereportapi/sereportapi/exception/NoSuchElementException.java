package com.ms.semicolans.sereportapi.sereportapi.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.NOT_FOUND)
public class NoSuchElementException extends RuntimeException{
    public NoSuchElementException(String message) {
        super(message);
    }
}
