package com.InterviewAI.controller;

import com.InterviewAI.dto.InterviewRequest;
import com.InterviewAI.model.Interview;
import com.InterviewAI.service.InterviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/interviews")
public class InterviewController {

    @Autowired
    private InterviewService interviewService;

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
