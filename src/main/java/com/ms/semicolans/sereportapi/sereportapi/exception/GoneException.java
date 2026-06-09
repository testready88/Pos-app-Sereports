package com.ms.semicolans.sereportapi.sereportapi.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.client.HttpClientErrorException;
@ResponseStatus(value = HttpStatus.GONE)
public class GoneException extends HttpClientErrorException {
    public GoneException(HttpStatus statusCode, String statusText) {
        super(statusCode, statusText);
    }
}
