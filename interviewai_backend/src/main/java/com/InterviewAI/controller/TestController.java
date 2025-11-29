// src/main/java/com/InterviewAI/controller/TestController.java
package com.interviewai.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/test")
public class TestController {

    @GetMapping("/hello")
    public Map<String, String> getSecuredHello() {
        // Get the authenticated user's details
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // The 'name' is the User's UUID (the 'sub' claim in the JWT)
        String userId = authentication.getName();

        return Map.of(
                "message", "Hello, you are authenticated!",
                "userId", userId);
    }
}
