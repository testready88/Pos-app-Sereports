package com.ms.semicolans.sereportapi.sereportapi.util;

import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class ImageUploadGenerator {

    public String generatePosResourceName(String name,String type){
        StringBuilder builder = new StringBuilder();
        builder.append(UUID.randomUUID().toString());
        builder.append("-POS-");
        builder.append(type).append("-");
        builder.append(name);
        return builder.toString();
    }

}
