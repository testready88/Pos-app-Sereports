package com.ms.semicolans.sereportapi.sereportapi.advisers;


import com.ms.semicolans.sereportapi.sereportapi.exception.*;
import com.ms.semicolans.sereportapi.sereportapi.util.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.multipart.support.MissingServletRequestPartException;

import java.sql.SQLIntegrityConstraintViolationException;


@RestControllerAdvice
public class AppWideExceptionHandler {
    @ExceptionHandler(UnAuthorizedException.class)
    public ResponseEntity<StandardResponse> handleUserUnAuthorizedException(UnAuthorizedException e) {
        return new ResponseEntity<StandardResponse>(
                new StandardResponse(401, e.getMessage(), e),
                HttpStatus.UNAUTHORIZED);
    }
    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<StandardResponse> handleBadRequestException(BadRequestException e) {
        return new ResponseEntity<StandardResponse>(
                new StandardResponse(400, e.getMessage(), e),
                HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(MissingServletRequestPartException.class)
    public ResponseEntity<StandardResponse> handleMissingServletRequestPartException(MissingServletRequestPartException e) {

        return new ResponseEntity<StandardResponse>(
                new StandardResponse(400, e.getMessage(), e),
                HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(PaymentRequiredException.class)
    public ResponseEntity<StandardResponse> handlePaymentException(PaymentRequiredException e) {

        return new ResponseEntity<StandardResponse>(
                new StandardResponse(402, e.getMessage(), e),
                HttpStatus.PAYMENT_REQUIRED);
    }



    @ExceptionHandler(EntryNotFoundException.class)
    public ResponseEntity<StandardResponse> handleNotFoundException(EntryNotFoundException e) {
        return new ResponseEntity<StandardResponse>(
                new StandardResponse(404, e.getMessage(), e),
                HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(RestrictedAreaException.class)
    public ResponseEntity<StandardResponse> handleUserRestrictedException(RestrictedAreaException e) {
        return new ResponseEntity<StandardResponse>(
                new StandardResponse(405, e.getMessage(), e),
                HttpStatus.METHOD_NOT_ALLOWED);
    }

    @ExceptionHandler(UserNotAcceptableException.class)
    public ResponseEntity<StandardResponse> handleUserNotAcceptableException(UserNotAcceptableException e) {
        return new ResponseEntity<StandardResponse>(
                new StandardResponse(406, e.getMessage(), e),
                HttpStatus.NOT_ACCEPTABLE);
    }
    @ExceptionHandler(EntryDuplicateException.class)
    public ResponseEntity<StandardResponse> handleDuplicateRequestException(EntryDuplicateException e) {
        return new ResponseEntity<StandardResponse>(
                new StandardResponse(409, e.getMessage(), e),
                HttpStatus.CONFLICT);
    }




    @ExceptionHandler(UserLockedException.class)
    public ResponseEntity<StandardResponse> handleUserLockedException(UserLockedException e) {
        return new ResponseEntity<StandardResponse>(
                new StandardResponse(423, e.getMessage(), e),
                HttpStatus.LOCKED);
    }
    @ExceptionHandler(SQLIntegrityConstraintViolationException.class)
    public ResponseEntity<StandardResponse> handleDuplicateRequestException(SQLIntegrityConstraintViolationException e) {
        return new ResponseEntity<StandardResponse>(
                new StandardResponse(409, e.getMessage(), e),
                HttpStatus.CONFLICT);
    }
    @ExceptionHandler(UserNotVerifiedException.class)
    public ResponseEntity<StandardResponse> handleUserNotVerifiedException(UserNotVerifiedException e) {
        return new ResponseEntity<StandardResponse>(
                new StandardResponse(503, e.getMessage(), e),
                HttpStatus.SERVICE_UNAVAILABLE);
    }


    @ExceptionHandler(GoneException.class)
    public ResponseEntity<StandardResponse> handleGoneException(HttpClientErrorException.Gone e) {
        return new ResponseEntity<StandardResponse>(new StandardResponse(410, "Error", e.getMessage()), HttpStatus.GONE);
    }

    @ExceptionHandler(TooManyRequestException.class)
    public ResponseEntity<StandardResponse> handleTooManyRequestException(TooManyRequestException e) {
        return new ResponseEntity<StandardResponse>(new StandardResponse(429, e.getMessage(), e), HttpStatus.TOO_MANY_REQUESTS);
    }


}
