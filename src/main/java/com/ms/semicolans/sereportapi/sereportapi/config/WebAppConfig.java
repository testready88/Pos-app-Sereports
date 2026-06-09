package com.ms.semicolans.sereportapi.sereportapi.config;



import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.Configuration;


@Configuration
@EntityScan(basePackages = "com.ms.semicolans.sereportapi.sereportapi")
public class WebAppConfig extends SpringBootServletInitializer {

}


