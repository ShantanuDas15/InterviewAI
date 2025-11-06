package com.InterviewAI.service;

import com.InterviewAI.dto.InterviewRequest;
import com.InterviewAI.model.Interview;
import com.InterviewAI.repository.InterviewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class InterviewService {

    @Autowired
    private InterviewRepository interviewRepository;

    @Autowired
    private GeminiService geminiService;

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
