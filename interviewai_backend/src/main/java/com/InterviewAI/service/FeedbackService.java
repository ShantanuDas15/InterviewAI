package com.interviewai.service;

// using constructor injection for better testability
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import com.interviewai.dto.FeedbackRequest;
import com.interviewai.model.Feedback;
import com.interviewai.model.Interview;
import com.interviewai.repository.FeedbackRepository;
import com.interviewai.repository.InterviewRepository;

import java.util.Map;
import java.util.Objects;
import java.util.UUID;

@Service
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final InterviewRepository interviewRepository;
    private final GeminiService geminiService;

    public FeedbackService(FeedbackRepository feedbackRepository,
            InterviewRepository interviewRepository,
            GeminiService geminiService) {
        this.feedbackRepository = feedbackRepository;
        this.interviewRepository = interviewRepository;
        this.geminiService = geminiService;
    }

    /**
     * Creates feedback for an interview by analyzing the transcript.
     * Calls the real Gemini API to generate AI feedback.
     */
    public Feedback generateAndSaveFeedback(FeedbackRequest request, UUID userId) {
        // Verify the interview exists and belongs to the user
        UUID interviewId = Objects.requireNonNull(request.getInterviewId(), "Interview ID must not be null");

        Interview interview = interviewRepository.findById(interviewId)
                .orElseThrow(() -> new RuntimeException("Interview not found"));

        if (!interview.getUserId().equals(userId)) {
            throw new AccessDeniedException("User does not have permission to submit feedback for this interview.");
        }

        // 1. Call Gemini to get analysis
        Map<String, Object> feedbackMap = geminiService.analyzeTranscript(request.getTranscript())
                .block(); // Wait for the analysis

        // 2. Create and populate the Feedback entity
        Feedback feedback = new Feedback();
        feedback.setInterviewId(interviewId);
        feedback.setUserId(userId); // Set user_id for direct user-feedback relationship
        feedback.setTranscript(request.getTranscript());

        if (feedbackMap != null) {
            feedback.setStrengths((String) feedbackMap.get("strengths"));
            feedback.setAreasForImprovement((String) feedbackMap.get("areas_for_improvement"));
            feedback.setOverallScore((Integer) feedbackMap.get("overall_score"));
        }

        // 3. Save to database
        return feedbackRepository.save(feedback);
    }

    /**
     * Get feedback by ID with user authorization check
     */
    public Feedback getFeedbackById(UUID feedbackId, UUID userId) {
        UUID safeFeedbackId = Objects.requireNonNull(feedbackId, "feedbackId must not be null");
        // Get the feedback
        Feedback feedback = feedbackRepository.findById(safeFeedbackId)
                .orElseThrow(() -> new RuntimeException("Feedback not found"));

        // Get the associated interview to verify ownership
        UUID feedbackInterviewId = Objects.requireNonNull(feedback.getInterviewId(),
                "Feedback.interviewId must not be null");
        Interview interview = interviewRepository.findById(feedbackInterviewId)
                .orElseThrow(() -> new RuntimeException("Associated interview not found"));

        // Verify the user owns this interview (and therefore this feedback)
        if (!interview.getUserId().equals(userId)) {
            throw new AccessDeniedException("User does not have permission to access this feedback.");
        }

        return feedback;
    }

    /**
     * Get feedback by interview ID with user authorization check
     */
    public Feedback getFeedbackByInterviewId(UUID interviewId, UUID userId) {
        UUID safeInterviewId = Objects.requireNonNull(interviewId, "interviewId must not be null");
        // First verify the interview exists and belongs to the user
        Interview interview = interviewRepository.findById(safeInterviewId)
                .orElseThrow(() -> new RuntimeException("Interview not found"));

        if (!interview.getUserId().equals(userId)) {
            throw new AccessDeniedException("User does not have permission to access this interview.");
        }

        // Get the feedback for this interview
        return feedbackRepository.findFirstByInterviewId(safeInterviewId)
                .orElseThrow(() -> new RuntimeException("No feedback found for interview id: " + interviewId));
    }
}
