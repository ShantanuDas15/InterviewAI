package com.InterviewAI.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * DTO for resume analysis requests.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ResumeAnalysisRequest {
    private UUID resumeId;
    // Optional: Can add jobDescription field later for tailored analysis
    private String jobDescription;
}
