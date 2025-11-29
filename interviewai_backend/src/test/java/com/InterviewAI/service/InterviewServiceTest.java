package com.InterviewAI.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.interviewai.dto.InterviewRequest;
import com.interviewai.model.Interview;
import com.interviewai.repository.InterviewRepository;
import com.interviewai.service.GeminiService;
import com.interviewai.service.InterviewService;

import reactor.core.publisher.Mono;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class InterviewServiceTest {

    @Mock
    private InterviewRepository interviewRepository;

    @Mock
    private GeminiService geminiService;

    @InjectMocks
    private InterviewService interviewService;

    private static final String EXPERIENCE_LEVEL_SENIOR = "Senior";

    @Test
    void createInterviewShouldSaveQuestionsFromGemini() {
        // ARRANGE
        UUID userId = UUID.randomUUID();
        InterviewRequest request = new InterviewRequest();
        request.setTitle("My Test Interview");
        request.setRole("SDE");
        request.setExperienceLevel(EXPERIENCE_LEVEL_SENIOR);

        String mockQuestions = "[\"Mock Question 1?\"]";
        Interview savedInterview = java.util.Objects.requireNonNull(new Interview(), "savedInterview must not be null");
        savedInterview.setId(UUID.randomUUID());
        savedInterview.setRole("SDE");
        savedInterview.setQuestions(mockQuestions); // This is what we test

        // Mock the GeminiService call
        when(geminiService.generateInterviewQuestions("SDE", EXPERIENCE_LEVEL_SENIOR))
                .thenReturn(Mono.just(mockQuestions));

        // Mock the repository save
        when(interviewRepository.save(org.mockito.Mockito.isA(Interview.class)))
                .thenReturn(java.util.Objects.requireNonNull(savedInterview, "savedInterview must not be null"));

        // ACT
        Interview result = java.util.Objects.requireNonNull(interviewService.createInterview(request, userId),
                "result must not be null");

        // ASSERT
        // Verify GeminiService was called
        verify(geminiService).generateInterviewQuestions("SDE", EXPERIENCE_LEVEL_SENIOR);

        // Verify repository was called
        verify(interviewRepository).save(savedInterview);

        // Check that the result contains the questions
        assertThat(result.getQuestions()).isEqualTo(mockQuestions);
        assertThat(result.getRole()).isEqualTo("SDE");
    }
}
