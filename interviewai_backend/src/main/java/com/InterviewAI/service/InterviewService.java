package com.interviewai.service;

import org.springframework.stereotype.Service;

import com.interviewai.dto.InterviewRequest;
import com.interviewai.model.Interview;
import com.interviewai.repository.InterviewRepository;

import java.util.UUID;

@Service
public class InterviewService {

    private final InterviewRepository interviewRepository;
    private final GeminiService geminiService;

    public InterviewService(InterviewRepository interviewRepository, GeminiService geminiService) {
        this.interviewRepository = java.util.Objects.requireNonNull(interviewRepository,
                "interviewRepository must not be null");
        this.geminiService = java.util.Objects.requireNonNull(geminiService, "geminiService must not be null");
    }

    /**
     * Creates a new interview entry in the database.
     * Calls the real Gemini API to generate interview questions.
     */
    public Interview createInterview(InterviewRequest request, UUID userId) {

        // --- REAL GEMINI CALL ---
        // .block() waits for the asynchronous call to finish.
        String questionsJson = geminiService.generateInterviewQuestions(
                request.getRole(),
                request.getExperienceLevel()).block(); // This makes the call synchronous

        Interview interview = new Interview();
        interview.setUserId(userId);
        interview.setTitle(request.getTitle());
        interview.setRole(request.getRole());
        interview.setExperienceLevel(request.getExperienceLevel());
        interview.setQuestions(questionsJson); // Save the generated questions

        return interviewRepository.save(interview);
    }
}
