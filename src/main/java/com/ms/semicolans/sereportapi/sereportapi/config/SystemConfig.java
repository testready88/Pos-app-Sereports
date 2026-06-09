package com.ms.semicolans.sereportapi.sereportapi.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "application.system")
public class SystemConfig {
    private Integer generalIdLength;
    private String generalKeyPrefix;
    public Integer getGeneralIdLength() {
        return generalIdLength;
    }

    public void setGeneralIdLength(Integer generalIdLength) {
        this.generalIdLength = generalIdLength;
    }

    public String getGeneralKeyPrefix() {
        return generalKeyPrefix;
    }

    public void setGeneralKeyPrefix(String generalKeyPrefix) {
        this.generalKeyPrefix = generalKeyPrefix;
    }

}
