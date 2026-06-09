package com.ms.semicolans.sereportapi.sereportapi.api;

import java.util.Collections;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class FallbackController {

    @RequestMapping("/api/**")
    public ResponseEntity<Map<String, Object>> fallback() {
        // Return an empty JSON object {} under "data", not an array []
        return ResponseEntity.ok(Map.of(
            "message", "ok",
            "data", Collections.emptyMap()   // ← changed from emptyList()
        ));
    }
}