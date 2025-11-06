package com.InterviewAI.dto.gemini;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;
import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true) // Ignores extra fields
public class GeminiResponse {
    private List<Candidate> candidates;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Candidate {
        private Content content;
    }

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Content {
        private List<Part> parts;
    }

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Part {
        private String text;
    }

    /**
     * Helper method to extract the first text part from the response.
     */
    public String getFirstText() {
        try {
            return this.candidates.get(0)
                    .getContent().getParts().get(0)
                    .getText();
        } catch (Exception e) {
            return null; // Handle nulls or empty lists gracefully
        }
    }
}
