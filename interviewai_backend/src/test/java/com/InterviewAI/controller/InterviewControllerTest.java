package com.InterviewAI.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.interviewai.controller.InterviewController;
import com.interviewai.dto.InterviewRequest;
import com.interviewai.model.Interview;
import com.interviewai.service.InterviewService;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(InterviewController.class) // Load only the Controller layer
class InterviewControllerTest {

    @Autowired
    private MockMvc mockMvc;

    private static final String ROLE_JAVA_DEVELOPER = "Java Developer";

    @SuppressWarnings("removal")
    @MockBean // Creates a mock of the service
    private InterviewService interviewService;

    @Autowired
    private ObjectMapper objectMapper; // For converting objects to JSON

    @Test
    @WithMockUser(username = "05e775cf-9817-4e9e-b491-70ced16576d6") // 1. Mocks an authenticated user
    void whenGenerateInterviewWithValidRequestThenReturnInterview() throws Exception {

        // 2. ARRANGE
        InterviewRequest request = new InterviewRequest();
        request.setTitle("Test Java Interview");
        request.setRole(ROLE_JAVA_DEVELOPER);
        request.setExperienceLevel("Mid");

        Interview mockResponse = new Interview();
        mockResponse.setId(UUID.randomUUID());
        mockResponse.setUserId(UUID.fromString("05e775cf-9817-4e9e-b491-70ced16576d6"));
        mockResponse.setRole(ROLE_JAVA_DEVELOPER);
        mockResponse.setTitle("Test Java Interview");

        // Tell the mock service what to return
        when(interviewService.createInterview(any(InterviewRequest.class), any(UUID.class)))
                .thenReturn(mockResponse);

        // 3. ACT & ASSERT
        RequestPostProcessor csrfProcessor = java.util.Objects.requireNonNull(csrf(),
                "csrf processor must not be null");
        MediaType jsonMediaType = java.util.Objects.requireNonNull(MediaType.APPLICATION_JSON,
                "mediaType must not be null");
        String requestJson = java.util.Objects.requireNonNull(objectMapper.writeValueAsString(request),
                "request JSON must not be null");
        mockMvc.perform(post("/api/interviews/generate")
                .with(csrfProcessor) // 4. Add CSRF token for the test
                .contentType(jsonMediaType)
                .content(requestJson)) // 5. Send the request body as JSON

                // 6. Check the results
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.role").value(ROLE_JAVA_DEVELOPER))
                .andExpect(jsonPath("$.userId").value("05e775cf-9817-4e9e-b491-70ced16576d6"));
    }

    @Test
    void whenGenerateInterviewWithoutAuthThenReturnUnauthorized() throws Exception {
        // Test that our endpoint is still secured
        RequestPostProcessor csrfProcessor2 = java.util.Objects.requireNonNull(csrf(),
                "csrf processor must not be null");
        MediaType jsonMediaType2 = java.util.Objects.requireNonNull(MediaType.APPLICATION_JSON,
                "mediaType must not be null");
        String newRequestJson = java.util.Objects.requireNonNull(
                objectMapper.writeValueAsString(new InterviewRequest()), "request JSON must not be null");
        mockMvc.perform(post("/api/interviews/generate")
                .with(csrfProcessor2)
                .contentType(jsonMediaType2)
                .content(newRequestJson))
                .andExpect(status().isUnauthorized()); // Expect 401
    }
}
