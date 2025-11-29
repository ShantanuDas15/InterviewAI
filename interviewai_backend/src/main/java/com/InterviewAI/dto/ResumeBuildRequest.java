package com.interviewai.dto;

import lombok.Data;
import java.util.List;
import java.util.Map;

/**
 * DTO for receiving resume build requests from the frontend.
 * Contains all the raw user input data that will be enhanced by AI.
 */
@Data
public class ResumeBuildRequest {

    /**
     * Title/name for this resume (e.g., "Software Engineer Resume", "Marketing
     * Manager Resume")
     */
    private String title;

    /**
     * Personal information fields
     * Expected keys: name, email, phone, location, linkedIn, github, portfolio,
     * etc.
     */
    private Map<String, String> personalInfo;

    /**
     * List of work experience entries
     * Expected keys per entry: title, company, location, startDate, endDate,
     * description (raw bullet points)
     */
    private List<Map<String, String>> experience;

    /**
     * List of education entries
     * Expected keys per entry: degree, school, location, startDate, endDate, gpa,
     * achievements
     */
    private List<Map<String, String>> education;

    /**
     * List of skills (as raw strings)
     */
    private List<String> skills;

    /**
     * List of project entries
     * Expected keys per entry: name, description, technologies, link, startDate,
     * endDate
     */
    private List<Map<String, String>> projects;

    /**
     * Optional certifications
     * Expected keys per entry: name, issuer, date, credentialId
     */
    private List<Map<String, String>> certifications;
}
