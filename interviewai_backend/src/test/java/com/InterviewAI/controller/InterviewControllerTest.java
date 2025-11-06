package com.InterviewAI.controller;

import com.InterviewAI.dto.InterviewRequest;
import com.InterviewAI.model.Interview;
import com.InterviewAI.service.InterviewService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(InterviewController.class) // Load only the Controller layer
public class InterviewControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @SuppressWarnings("removal")
    @MockBean // Creates a mock of the service
    private InterviewService interviewService;

    @Autowired
    private ObjectMapper objectMapper; // For converting objects to JSON

    @SuppressWarnings("null")
    @Test
    @WithMockUser(username = "05e775cf-9817-4e9e-b491-70ced16576d6") // 1. Mocks an authenticated user
    public void whenGenerateInterview_withValidRequest_thenReturnInterview() throws Exception {

        // 2. ARRANGE
        InterviewRequest request = new InterviewRequest();
        request.setTitle("Test Java Interview");
        request.setRole("Java Developer");
        request.setExperienceLevel("Mid");

        Interview mockResponse = new Interview();
        mockResponse.setId(UUID.randomUUID());
        mockResponse.setUserId(UUID.fromString("05e775cf-9817-4e9e-b491-70ced16576d6"));
        mockResponse.setRole("Java Developer");
        mockResponse.setTitle("Test Java Interview");

        // Tell the mock service what to return
        when(interviewService.createInterview(any(InterviewRequest.class), any(UUID.class)))
                .thenReturn(mockResponse);

        // 3. ACT & ASSERT
        mockMvc.perform(post("/api/interviews/generate")
                .with(csrf()) // 4. Add CSRF token for the test
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))) // 5. Send the request body as JSON

                // 6. Check the results
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.role").value("Java Developer"))
                .andExpect(jsonPath("$.userId").value("05e775cf-9817-4e9e-b491-70ced16576d6"));
    }

    @SuppressWarnings("null")
    @Test
    public void whenGenerateInterview_withoutAuth_thenReturnUnauthorized() throws Exception {
        // Test that our endpoint is still secured
        mockMvc.perform(post("/api/interviews/generate")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(new InterviewRequest())))
                .andExpect(status().isUnauthorized()); // Expect 401
    }
}
