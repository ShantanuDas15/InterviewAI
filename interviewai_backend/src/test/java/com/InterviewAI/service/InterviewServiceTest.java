package com.InterviewAI.service;

import com.InterviewAI.dto.InterviewRequest;
import com.InterviewAI.model.Interview;
import com.InterviewAI.repository.InterviewRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import reactor.core.publisher.Mono;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class InterviewServiceTest {

    @Mock
    private InterviewRepository interviewRepository;

    @Mock
    private GeminiService geminiService;

    @InjectMocks
    private InterviewService interviewService;

    @SuppressWarnings("null")
    @Test
    void createInterview_shouldSaveQuestionsFromGemini() {
        // ARRANGE
        UUID userId = UUID.randomUUID();
        InterviewRequest request = new InterviewRequest();
        request.setTitle("My Test Interview");
        request.setRole("SDE");
        request.setExperienceLevel("Senior");

        String mockQuestions = "[\"Mock Question 1?\"]";
        Interview savedInterview = new Interview();
        savedInterview.setId(UUID.randomUUID());
        savedInterview.setRole("SDE");
        savedInterview.setQuestions(mockQuestions); // This is what we test

        // Mock the GeminiService call
        when(geminiService.generateInterviewQuestions("SDE", "Senior"))
                .thenReturn(Mono.just(mockQuestions));

        // Mock the repository save
        when(interviewRepository.save(any(Interview.class)))
                .thenReturn(savedInterview);

        // ACT
        Interview result = interviewService.createInterview(request, userId);

        // ASSERT
        // Verify GeminiService was called
        verify(geminiService).generateInterviewQuestions("SDE", "Senior");

        // Verify repository was called
        verify(interviewRepository).save(any(Interview.class));

        // Check that the result contains the questions
        assertThat(result.getQuestions()).isEqualTo(mockQuestions);
        assertThat(result.getRole()).isEqualTo("SDE");
    }
}
