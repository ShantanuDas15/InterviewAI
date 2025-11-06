package com.InterviewAI.service;

import com.InterviewAI.dto.FeedbackRequest;
import com.InterviewAI.model.Feedback;
import com.InterviewAI.model.Interview;
import com.InterviewAI.repository.FeedbackRepository;
import com.InterviewAI.repository.InterviewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;

@Service
public class FeedbackService {

    @Autowired
    private FeedbackRepository feedbackRepository;

    @Autowired
    private InterviewRepository interviewRepository;

    @Autowired
    private GeminiService geminiService;

    /**
     * Creates feedback for an interview by analyzing the transcript.
     * Calls the real Gemini API to generate AI feedback.
     */
    public Feedback generateAndSaveFeedback(FeedbackRequest request, UUID userId) {
        // Verify the interview exists and belongs to the user
        @SuppressWarnings("null")
        Interview interview = interviewRepository.findById(request.getInterviewId())
                .orElseThrow(() -> new RuntimeException("Interview not found"));

        if (!interview.getUserId().equals(userId)) {
            throw new AccessDeniedException("User does not have permission to submit feedback for this interview.");
        }

        // 1. Call Gemini to get analysis
        Map<String, Object> feedbackMap = geminiService.analyzeTranscript(request.getTranscript())
                .block(); // Wait for the analysis

        // 2. Create and populate the Feedback entity
        Feedback feedback = new Feedback();
        feedback.setInterviewId(request.getInterviewId());
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
    @SuppressWarnings("null")
    public Feedback getFeedbackById(UUID feedbackId, UUID userId) {
        // Get the feedback
        Feedback feedback = feedbackRepository.findById(feedbackId)
                .orElseThrow(() -> new RuntimeException("Feedback not found"));

        // Get the associated interview to verify ownership
        Interview interview = interviewRepository.findById(feedback.getInterviewId())
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
    @SuppressWarnings("null")
    public Feedback getFeedbackByInterviewId(UUID interviewId, UUID userId) {
        // First verify the interview exists and belongs to the user
        Interview interview = interviewRepository.findById(interviewId)
                .orElseThrow(() -> new RuntimeException("Interview not found"));

        if (!interview.getUserId().equals(userId)) {
            throw new AccessDeniedException("User does not have permission to access this interview.");
        }

        // Get the feedback for this interview
        return feedbackRepository.findFirstByInterviewId(interviewId)
                .orElseThrow(() -> new RuntimeException("No feedback found for interview id: " + interviewId));
    }
}
