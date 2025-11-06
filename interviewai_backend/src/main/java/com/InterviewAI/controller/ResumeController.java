package com.InterviewAI.controller;

import com.InterviewAI.dto.ResumeAnalysisRequest;
import com.InterviewAI.model.ResumeAnalysis;
import com.InterviewAI.service.ResumeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * REST controller for resume analysis endpoints.
 */
@RestController
@RequestMapping("/api/resume")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ResumeController {

    @Autowired
    private ResumeService resumeService;

    /**
     * POST /api/resume/analyze
     * Triggers AI analysis of a resume.
     * 
     * @param request        Contains resumeId and optional jobDescription
     * @param authentication Spring Security authentication (contains userId)
     * @return The saved ResumeAnalysis entity
     */
    @PostMapping("/analyze")
    public Mono<ResponseEntity<ResumeAnalysis>> analyzeResume(
            @RequestBody ResumeAnalysisRequest request,
            Authentication authentication) {

        System.out.println("=== Resume Analysis Request ===");
        System.out.println("Authentication: " + (authentication != null ? authentication.getName() : "NULL"));
        System.out.println("Resume ID: " + request.getResumeId());
        System.out.println("Job Description: " + request.getJobDescription());

        if (authentication == null || authentication.getName() == null) {
            System.err.println("ERROR: No authentication or user ID found!");
            return Mono.just(ResponseEntity.status(401).build());
        }

        UUID userId;
        try {
            userId = UUID.fromString(authentication.getName());
        } catch (IllegalArgumentException e) {
            System.err.println("ERROR: Invalid UUID format for user ID: " + authentication.getName());
            return Mono.just(ResponseEntity.status(400).build());
        }

        return resumeService.analyzeResume(
                request.getResumeId(),
                userId,
                request.getJobDescription())
                .map(ResponseEntity::ok)
                .onErrorResume(e -> {
                    System.err.println("Error in analyzeResume endpoint: " + e.getMessage());
                    e.printStackTrace();
                    return Mono.just(ResponseEntity.internalServerError().build());
                });
    }

    /**
     * GET /api/resume/analysis/{resumeId}
     * Retrieves an existing analysis.
     * 
     * @param resumeId The resume ID
     * @return The ResumeAnalysis entity
     */
    @GetMapping("/analysis/{resumeId}")
    public Mono<ResponseEntity<ResumeAnalysis>> getAnalysis(
            @PathVariable UUID resumeId,
            Authentication authentication) {

        // Note: We should verify the user owns this resume,
        // but for simplicity, relying on RLS in Supabase
        return resumeService.getAnalysis(resumeId)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
}
