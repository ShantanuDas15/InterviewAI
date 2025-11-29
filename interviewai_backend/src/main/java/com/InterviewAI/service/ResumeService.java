package com.interviewai.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.interviewai.model.ResumeAnalysis;
import com.interviewai.repository.ResumeAnalysisRepository;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import reactor.core.publisher.Mono;
import com.interviewai.exception.AiAnalysisParseException;
import com.interviewai.exception.AnalysisNotFoundException;
import com.interviewai.exception.DownloadFailedException;
import com.interviewai.exception.MetadataParseException;
import com.interviewai.exception.PdfExtractionException;
import com.interviewai.exception.ResumeNotFoundException;

import java.io.IOException;
import java.util.Map;
import java.util.UUID;

/**
 * Service for handling resume analysis.
 * Coordinates downloading PDFs from Supabase Storage, analyzing with Gemini,
 * and saving results to the database.
 */
@Service
public class ResumeService {

    private static final Logger logger = LoggerFactory.getLogger(ResumeService.class);

    private final GeminiService geminiService;
    private final ResumeAnalysisRepository resumeAnalysisRepository;
    private final WebClient supabaseWebClient;
    private final ObjectMapper objectMapper;

    public ResumeService(GeminiService geminiService,
            ResumeAnalysisRepository resumeAnalysisRepository,
            @Qualifier("supabaseWebClient") WebClient supabaseWebClient,
            ObjectMapper objectMapper) {
        this.geminiService = java.util.Objects.requireNonNull(geminiService, "geminiService must not be null");
        this.resumeAnalysisRepository = java.util.Objects.requireNonNull(resumeAnalysisRepository,
                "resumeAnalysisRepository must not be null");
        this.supabaseWebClient = java.util.Objects.requireNonNull(supabaseWebClient,
                "supabaseWebClient must not be null");
        this.objectMapper = java.util.Objects.requireNonNull(objectMapper, "objectMapper must not be null");
    }

    /**
     * Analyzes a resume by downloading it from Supabase Storage,
     * extracting text, sending to Gemini, and saving the results.
     * 
     * @param resumeId       The ID of the resume to analyze
     * @param userId         The ID of the user (for security verification)
     * @param jobDescription Optional job description for tailored analysis
     * @return A Mono containing the saved ResumeAnalysis entity
     */
    public Mono<ResumeAnalysis> analyzeResume(UUID resumeId, UUID userId, String jobDescription) {
        // 1. Get the resume metadata from the 'resumes' table
        return supabaseWebClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/rest/v1/resumes")
                        .queryParam("select", "file_path,file_name,file_size_bytes,upload_date")
                        .queryParam("id", "eq." + resumeId.toString())
                        .queryParam("user_id", "eq." + userId.toString())
                        .build())
                .retrieve()
                .bodyToMono(String.class)
                .flatMap(responseBody -> {
                    try {
                        JsonNode data = objectMapper.readTree(responseBody);
                        if (!data.isArray() || data.isEmpty()) {
                            return Mono.<Map<String, Object>>error(
                                    new ResumeNotFoundException("Resume not found or access denied"));
                        }

                        JsonNode resumeData = data.get(0);
                        String filePath = resumeData.get("file_path").asText();
                        String fileName = resumeData.get("file_name").asText();
                        int fileSize = resumeData.get("file_size_bytes").asInt();
                        String uploadDate = resumeData.get("upload_date").asText();

                        // 2. Download the file from storage (using authenticated endpoint)
                        logger.info("Downloading file from: /storage/v1/object/authenticated/resumes/{}", filePath);
                        return supabaseWebClient.get()
                                .uri("/storage/v1/object/authenticated/resumes/" + filePath)
                                .retrieve()
                                .onStatus(
                                        status -> status.is4xxClientError() || status.is5xxServerError(),
                                        response -> response.bodyToMono(String.class)
                                                .flatMap(errorBody -> {
                                                    logger.error("Supabase Storage error: {}", errorBody);
                                                    return Mono.error(new DownloadFailedException(
                                                            "Failed to download file: " + errorBody));
                                                }))
                                .bodyToMono(byte[].class)
                                .map(fileBytes -> {
                                    try {
                                        // 3. Extract text from PDF
                                        String resumeText = extractTextFromPdf(fileBytes);

                                        // Return metadata along with resume text
                                        return Map.of(
                                                "resumeText", resumeText,
                                                "fileName", fileName,
                                                "fileSize", String.format("%.2f KB", fileSize / 1024.0),
                                                "uploadDate", uploadDate);
                                    } catch (IOException e) {
                                        throw new PdfExtractionException(
                                                "Failed to extract PDF text: " + e.getMessage(), e);
                                    }
                                });
                    } catch (Exception e) {
                        return Mono.<Map<String, Object>>error(
                                new MetadataParseException("Failed to parse resume metadata: " + e.getMessage(), e));
                    }
                })
                // 4. Send text to Gemini for analysis with metadata
                .flatMap(resumeData -> geminiService.analyzeResume(
                        (String) resumeData.get("resumeText"),
                        (String) resumeData.get("fileName"),
                        (String) resumeData.get("fileSize"),
                        (String) resumeData.get("uploadDate"),
                        jobDescription != null ? jobDescription : ""))
                // 5. Parse Gemini's JSON response and save to database
                .flatMap(geminiResponse -> {
                    try {
                        @SuppressWarnings("unchecked")
                        Map<String, Object> analysisMap = objectMapper.readValue(geminiResponse, Map.class);

                        ResumeAnalysis analysis = new ResumeAnalysis();
                        analysis.setResumeId(resumeId);
                        analysis.setUserId(userId);

                        // Handle overallScore - could be Integer or Double from JSON
                        Object scoreObj = analysisMap.get("overallScore");
                        if (scoreObj instanceof Number number) {
                            analysis.setOverallScore(number.intValue());
                        }

                        // Store the entire structured analysis in the strengths field
                        // This preserves all 7 sections for display
                        Map<String, Object> structuredAnalysis = new java.util.HashMap<>();
                        structuredAnalysis.put("skillsAssessment", analysisMap.get("skillsAssessment"));
                        structuredAnalysis.put("experienceEvaluation", analysisMap.get("experienceEvaluation"));
                        structuredAnalysis.put("educationCertifications", analysisMap.get("educationCertifications"));
                        structuredAnalysis.put("resumeOptimization", analysisMap.get("resumeOptimization"));
                        structuredAnalysis.put("interviewPreparation", analysisMap.get("interviewPreparation"));
                        structuredAnalysis.put("careerAdvancement", analysisMap.get("careerAdvancement"));
                        structuredAnalysis.put("professionalDevelopment", analysisMap.get("professionalDevelopment"));

                        analysis.setStrengths(objectMapper.valueToTree(structuredAnalysis));

                        // Store a summary in improvements for backward compatibility
                        // This can be used for quick display or legacy views
                        Map<String, Object> summary = new java.util.HashMap<>();
                        summary.put("note", "See strengths field for full structured analysis");
                        summary.put("sections",
                                "Skills, Experience, Education, Resume Optimization, Interview Prep, Career Advancement, Professional Development");
                        analysis.setImprovements(objectMapper.valueToTree(summary));

                        // 6. Save analysis to the database
                        return Mono.fromCallable(() -> resumeAnalysisRepository.save(analysis));

                    } catch (Exception e) {
                        logger.error("Error parsing Gemini response: {}", e.getMessage(), e);
                        return Mono.<ResumeAnalysis>error(
                                new AiAnalysisParseException("Failed to parse AI analysis: " + e.getMessage(), e));
                    }
                })
                // 7. Update the is_analyzed flag in the resumes table
                .doOnSuccess(analysis -> {
                    String updateBody = "{\"is_analyzed\": true}";
                    supabaseWebClient.patch()
                            .uri(uriBuilder -> uriBuilder
                                    .path("/rest/v1/resumes")
                                    .queryParam("id", "eq." + resumeId.toString())
                                    .build())
                            .header("Content-Type", "application/json")
                            .header("Prefer", "return=minimal")
                            .bodyValue(updateBody)
                            .retrieve()
                            .bodyToMono(Void.class)
                            .subscribe(
                                    result -> logger.info("Successfully updated is_analyzed flag"),
                                    error -> logger.error("Failed to update is_analyzed flag: {}", error.getMessage(),
                                            error));
                });
    }

    /**
     * Extracts text content from a PDF file using Apache PDFBox.
     * 
     * @param pdfBytes The PDF file as a byte array
     * @return The extracted text content
     * @throws IOException if PDF cannot be read
     */
    private String extractTextFromPdf(byte[] pdfBytes) throws IOException {
        try (PDDocument document = Loader.loadPDF(pdfBytes)) {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document);
        }
    }

    /**
     * Retrieves an existing analysis for a resume.
     * 
     * @param resumeId The resume ID
     * @return A Mono containing the ResumeAnalysis if found
     */
    public Mono<ResumeAnalysis> getAnalysis(UUID resumeId) {
        return Mono.fromCallable(() -> resumeAnalysisRepository.findByResumeId(resumeId)
                .orElseThrow(() -> new AnalysisNotFoundException("Analysis not found")));
    }
}
