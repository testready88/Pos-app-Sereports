package com.ms.semicolans.sereportapi.sereportapi.exception;


import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.client.HttpClientErrorException;

@ResponseStatus(value = HttpStatus.TOO_MANY_REQUESTS)
public class TooManyRequestException extends HttpClientErrorException {


    public TooManyRequestException(HttpStatusCode statusCode, String statusText) {
        super(statusCode, statusText);
    }
}
