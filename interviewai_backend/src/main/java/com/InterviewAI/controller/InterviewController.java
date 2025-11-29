package com.interviewai.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.interviewai.dto.InterviewRequest;
import com.interviewai.model.Interview;
import com.interviewai.service.InterviewService;

import java.util.UUID;

@RestController
@RequestMapping("/api/interviews")
public class InterviewController {
    private final InterviewService interviewService;

    public InterviewController(InterviewService interviewService) {
        this.interviewService = interviewService;
    }

    @PostMapping("/generate")
    public ResponseEntity<Interview> generateInterview(
            @RequestBody InterviewRequest request,
            Authentication authentication) {

        // Get the authenticated user's UUID from the token
        UUID userId = UUID.fromString(authentication.getName());

        Interview newInterview = interviewService.createInterview(request, userId);

        return ResponseEntity.ok(newInterview);
    }
}
