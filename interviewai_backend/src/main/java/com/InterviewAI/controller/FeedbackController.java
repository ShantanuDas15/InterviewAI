package com.InterviewAI.controller;

import com.InterviewAI.dto.FeedbackRequest;
import com.InterviewAI.model.Feedback;
import com.InterviewAI.service.FeedbackService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/feedback")
public class FeedbackController {

    @Autowired
    private FeedbackService feedbackService;

    @PostMapping
    public ResponseEntity<Feedback> generateFeedback(
            @RequestBody FeedbackRequest request,
            Authentication authentication) {

        // Get the authenticated user's UUID from the token
        UUID userId = UUID.fromString(authentication.getName());

        // Generate and save feedback using real Gemini API
        Feedback feedback = feedbackService.generateAndSaveFeedback(request, userId);

        return ResponseEntity.ok(feedback);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Feedback> getFeedback(
            @PathVariable UUID id,
            Authentication authentication) {

        // Get the authenticated user's UUID from the token
        UUID userId = UUID.fromString(authentication.getName());

        // Get feedback with ownership verification
        Feedback feedback = feedbackService.getFeedbackById(id, userId);
        return ResponseEntity.ok(feedback);
    }

    @GetMapping("/for-interview/{interviewId}")
    public ResponseEntity<?> getFeedbackForInterview(
            @PathVariable UUID interviewId,
            Authentication authentication) {

        // Get the authenticated user's UUID from the token
        UUID userId = UUID.fromString(authentication.getName());

        try {
            Feedback feedback = feedbackService.getFeedbackByInterviewId(interviewId, userId);
            return ResponseEntity.ok(feedback);
        } catch (RuntimeException e) {
            // Return 404 if no feedback is found (which is OK for interviews in progress)
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(e.getMessage());
        }
    }
}
