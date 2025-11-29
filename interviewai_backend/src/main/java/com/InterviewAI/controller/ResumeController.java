package com.interviewai.controller;

import org.springframework.lang.NonNull;
import org.springframework.http.ResponseEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.interviewai.dto.ResumeAnalysisRequest;
import com.interviewai.model.ResumeAnalysis;
import com.interviewai.service.ResumeService;

import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * REST controller for resume analysis endpoints.
 */
@RestController
@RequestMapping("/api/resume")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ResumeController {

    private static final Logger logger = LoggerFactory.getLogger(ResumeController.class);

    private final ResumeService resumeService;

    public ResumeController(@NonNull ResumeService resumeService) {
        this.resumeService = java.util.Objects.requireNonNull(resumeService, "resumeService must not be null");
    }

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

        logger.info("=== Resume Analysis Request ===");
        logger.debug("Authentication: {}", (authentication != null ? authentication.getName() : "NULL"));
        logger.debug("Resume ID: {}", request.getResumeId());
        logger.debug("Job Description: {}", request.getJobDescription());

        if (authentication == null || authentication.getName() == null) {
            logger.warn("ERROR: No authentication or user ID found!");
            return Mono.just(ResponseEntity.status(401).build());
        }

        UUID userId;
        try {
            userId = UUID.fromString(authentication.getName());
        } catch (IllegalArgumentException e) {
            logger.warn("ERROR: Invalid UUID format for user ID: {}", authentication.getName());
            return Mono.just(ResponseEntity.status(400).build());
        }

        return resumeService.analyzeResume(
                request.getResumeId(),
                userId,
                request.getJobDescription())
                .map(ResponseEntity::ok)
                .onErrorResume(e -> {
                    logger.error("Error in analyzeResume endpoint: {}", e.getMessage(), e);
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
