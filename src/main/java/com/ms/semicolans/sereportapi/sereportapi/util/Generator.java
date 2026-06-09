package com.ms.semicolans.sereportapi.sereportapi.util;

import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Random;
import java.util.UUID;
@Service
public class Generator {

    private final Random RANDOM = new Random();
    private final String NUMERIC = "0123456789";
    private final static String NUMERIC2 = "123456789";
    public final static String ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    public final static String CHARACTORS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    public final static String CHARACTERS = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@#$";

    public String generatePrefix(){
        int randomLength = new Random().nextInt((14-6) +1)+6;
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < randomLength; i++) {
            builder.append(ALPHABET.charAt(new Random().nextInt(25)));
        }
        return builder.toString();
    }
    public int generateOtp() {
        StringBuilder builder = new StringBuilder();
        builder.append(NUMERIC2.charAt(new Random().nextInt(8)));
        for (int i = 0; i < 5; i++) {
            builder.append(NUMERIC.charAt(new Random().nextInt(9)));
        }
        return Integer.parseInt(builder.toString());
    }

    public static String generateUserPassword() {
        SecureRandom random = new SecureRandom();
        StringBuilder builder = new StringBuilder();
        // Append special character
        builder.append("@");

        // Append numbers
        for (int i = 0; i < 5; i++) {
            char randomDigit = CHARACTERS.charAt(random.nextInt(CHARACTERS.length()));
            char randomNumber = NUMERIC2.charAt(random.nextInt(NUMERIC2.length()));
            builder.append(randomDigit);
            builder.append(randomNumber);
        }

        return builder.toString();
    }

    public static String generateTenantName(String businessName) {
        String businessAbbreviation = businessName.replaceAll("[^a-zA-Z0-9]", "").toUpperCase().substring(0, 3);
        String uniqueCode = UUID.randomUUID().toString().substring(0, 4).toUpperCase();
        String timestamp = new SimpleDateFormat("yyyyMMdd").format(new Date());
        return (businessAbbreviation + "-" + uniqueCode + "-" + timestamp).toLowerCase().replace("-", "_");
    }

    public static Date packageEndDate(int dayCount, Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        calendar.add(Calendar.DAY_OF_MONTH, dayCount);
        return calendar.getTime();
    }
}

