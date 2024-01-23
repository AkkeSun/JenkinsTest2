package com.example.jenkinstest2;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthCheckController {

    @GetMapping("/healthCheck")
    public String healthCheck() {
        return "Y";
    }

}
