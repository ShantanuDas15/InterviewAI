package com.interviewai.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.interviewai.dto.ResumeBuildRequest;
import com.interviewai.model.BuiltResume;
import com.interviewai.repository.BuiltResumeRepository;
import com.interviewai.service.GeminiService;

// Using constructor injection instead of field injection for better testability and immutability
import org.springframework.http.ResponseEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Objects;
import java.util.UUID;

/**
 * REST controller for the Resume Builder feature.
 * Handles AI-powered resume generation and storage.
 */
@RestController
@RequestMapping("/api/resume-builder")
public class ResumeBuilderController {

    private static final Logger logger = LoggerFactory.getLogger(ResumeBuilderController.class);

    private final GeminiService geminiService;
    private final BuiltResumeRepository resumeRepository;
    private final ObjectMapper objectMapper;

    public ResumeBuilderController(GeminiService geminiService,
            BuiltResumeRepository resumeRepository,
            ObjectMapper objectMapper) {
        this.geminiService = geminiService;
        this.resumeRepository = resumeRepository;
        this.objectMapper = objectMapper;
    }

    /**
     * Build a new resume using AI enhancement.
     * Takes raw user input, sends it to Gemini for professional rewriting,
     * and stores both the original input and AI-generated content.
     * 
     * @param request        The resume build request containing raw user data
     * @param authentication The authenticated user's details
     * @return The saved BuiltResume entity with AI-generated content
     */
    @PostMapping("/build")
    public Mono<ResponseEntity<BuiltResume>> buildResume(
            @RequestBody ResumeBuildRequest request,
            Authentication authentication) {

        UUID userId = UUID.fromString(authentication.getName());

        return geminiService.buildResume(request)
                .flatMap(aiResponse -> {
                    try {
                        // 1. Create the entity to save
                        BuiltResume newResume = new BuiltResume();
                        newResume.setUserId(userId);
                        newResume.setTitle(request.getTitle());

                        // 2. Convert request DTO and AI response to JSONB
                        JsonNode userInputNode = objectMapper.valueToTree(request);
                        JsonNode aiGeneratedNode = objectMapper.readTree(aiResponse);

                        newResume.setUserInputData(userInputNode);
                        newResume.setAiGeneratedContent(aiGeneratedNode);

                        // 3. Save to database
                        BuiltResume savedResume = resumeRepository.save(newResume);
                        Objects.requireNonNull(savedResume, "Saved resume must not be null");

                        return Mono.just(ResponseEntity.ok(savedResume));

                    } catch (Exception e) {
                        logger.error("Error saving built resume: {}", e.getMessage(), e);
                        return Mono.error(e);
                    }
                })
                .onErrorResume(e -> {
                    logger.error("Error building resume: {}", e.getMessage(), e);
                    return Mono.just(ResponseEntity.internalServerError().build());
                });
    }

    /**
     * Get all resumes built by the authenticated user.
     * 
     * @param authentication The authenticated user's details
     * @return List of built resumes ordered by creation date (newest first)
     */
    @GetMapping("/my-resumes")
    public ResponseEntity<List<BuiltResume>> getMyResumes(Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        List<BuiltResume> resumes = resumeRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return ResponseEntity.ok(resumes);
    }

    /**
     * Get a specific built resume by ID.
     * 
     * @param id             The resume ID
     * @param authentication The authenticated user's details
     * @return The built resume if found and owned by the user
     */
    @GetMapping("/{id}")
    public ResponseEntity<BuiltResume> getResumeById(
            @PathVariable UUID id,
            Authentication authentication) {

        UUID safeId = Objects.requireNonNull(id, "resume id must not be null");

        UUID userId = UUID.fromString(authentication.getName());

        return resumeRepository.findById(safeId)
                .filter(resume -> resume.getUserId().equals(userId)) // Ensure user owns this resume
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Delete a built resume.
     * 
     * @param id             The resume ID to delete
     * @param authentication The authenticated user's details
     * @return 204 No Content if successful, 404 if not found
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteResume(
            @PathVariable UUID id,
            Authentication authentication) {

        UUID safeId = Objects.requireNonNull(id, "resume id must not be null");

        UUID userId = UUID.fromString(authentication.getName());

        return resumeRepository.findById(safeId)
                .filter(resume -> resume.getUserId().equals(userId)) // Ensure user owns this resume
                .map(resume -> {
                    BuiltResume safeResume = Objects.requireNonNull(resume, "resume must not be null");
                    resumeRepository.delete(safeResume);
                    return ResponseEntity.noContent().<Void>build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
