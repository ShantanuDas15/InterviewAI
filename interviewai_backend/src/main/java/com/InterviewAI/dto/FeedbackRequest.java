package com.interviewai.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class FeedbackRequest {
    private UUID interviewId;
    private String transcript;
}
