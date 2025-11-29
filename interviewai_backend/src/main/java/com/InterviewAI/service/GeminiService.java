package com.interviewai.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.interviewai.dto.ResumeBuildRequest;
import com.interviewai.dto.gemini.GeminiRequest;
import com.interviewai.dto.gemini.GeminiResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.lang.NonNull;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Map;

@Service
public class GeminiService {

    private static final String MARKDOWN_JSON = "```json";
    private static final String MARKDOWN_BACKTICKS = "```";
    private static final Logger logger = LoggerFactory.getLogger(GeminiService.class);
    private static final String KEY_VALUE_FORMAT = "  %s: %s%n";
    private static final String PROMPT_NOT_NULL_MSG = "prompt must not be null";
    private static final String GEMINI_REQUEST_NOT_NULL_MSG = "GeminiRequest must not be null";

    private final WebClient webClient;
    private final String geminiApiKey;
    private final String geminiApiUrl;
    private final ObjectMapper objectMapper; // For parsing JSON

    public GeminiService(WebClient webClient,
            @org.springframework.beans.factory.annotation.Value("${gemini.api.key}") String geminiApiKey,
            @org.springframework.beans.factory.annotation.Value("${gemini.api.url}") String geminiApiUrl,
            ObjectMapper objectMapper) {
        this.webClient = java.util.Objects.requireNonNull(webClient, "webClient must not be null");
        this.geminiApiKey = java.util.Objects.requireNonNull(geminiApiKey, "gemini.api.key must not be null");
        this.geminiApiUrl = java.util.Objects.requireNonNull(geminiApiUrl, "gemini.api.url must not be null");
        this.objectMapper = java.util.Objects.requireNonNull(objectMapper, "objectMapper must not be null");
    }

    /**
     * Calls Gemini to generate a complete conversational interview script.
     * Creates a natural, human-like interview experience with proper flow,
     * empathy, and professional transitions.
     */
    public Mono<String> generateInterviewQuestions(String role, String experience) {
        String prompt = String.format(
                "You are conducting a friendly voice interview for a %s %s position. " +
                        "Create a natural, conversational interview flow.\\n\\n" +

                        "CRITICAL RULES:\\n" +
                        "- DO NOT use placeholders like 'candidate name', 'company name', or 'job title'\\n" +
                        "- DO NOT ask for personal information (name, company, etc.) - you already know it\\n" +
                        "- Keep the opening brief (1 sentence max)\\n" +
                        "- Focus questions on skills, experience, and problem-solving\\n" +
                        "- Be warm but concise%n%n" +

                        "INTERVIEW STRUCTURE:\\n" +
                        "1. Brief welcome (just say hello and let's begin)\\n" +
                        "2. 5 focused questions about their %s experience\\n" +
                        "3. Short thank you\\n\\n" +

                        "QUESTION TOPICS (choose 5):\\n" +
                        "- Previous relevant experience or projects\\n" +
                        "- Technical skills and problem-solving approach\\n" +
                        "- Challenges they've overcome\\n" +
                        "- Teamwork and collaboration\\n" +
                        "- Learning and growth mindset\\n" +
                        "- Future goals and motivations%n%n" +

                        "CONVERSATIONAL STYLE:\\n" +
                        "- Keep acknowledgments short: 'Great', 'I see', 'Interesting', 'Thanks'\\n" +
                        "- Simple transitions: 'Next question', 'Moving on', 'Let me ask about', 'Tell me about'\\n" +
                        "- Natural and friendly tone\\n\\n" +

                        "Return ONLY a JSON object with this structure:\\n" +
                        "{%n" +
                        "  \\\"opening\\\": \\\"Brief welcome (1 sentence)\\\",\\n" +
                        "  \\\"questions\\\": [\\n" +
                        "    {\\n" +
                        "      \\\"transition\\\": \\\"Short intro phrase\\\",\\n" +
                        "      \\\"question\\\": \\\"Direct question about skills/experience\\\",\\n" +
                        "      \\\"acknowledgment\\\": \\\"Brief response\\\"\\n" +
                        "    }%n" +
                        "  ],\\n" +
                        "  \\\"closing\\\": \\\"Brief thank you (1 sentence)\\\"\\n" +
                        "}%n%n" +

                        "IMPORTANT: Use ONLY the actual role (%s) in questions. No placeholders. No asking for names or companies. Return raw JSON only.",
                experience, role, role, role);

        java.util.Objects.requireNonNull(prompt, PROMPT_NOT_NULL_MSG);
        GeminiRequest request = java.util.Objects.requireNonNull(buildGeminiRequest(prompt),
                GEMINI_REQUEST_NOT_NULL_MSG);

        return callGeminiApi(request)
                .map(GeminiResponse::getFirstText)
                .map(responseText -> responseText.replace(MARKDOWN_JSON, "").replace(MARKDOWN_BACKTICKS, "").trim())
                .onErrorResume(e -> {
                    logger.error("Error generating interview questions: {}", e.getMessage(), e);
                    // Return a fallback conversational structure
                    return Mono.just(
                            "{\"opening\": \"Hello! Thanks for joining me today. I'm excited to learn more about your background and experience. Let's have a great conversation!\", "
                                    +
                                    "\"questions\": [" +
                                    "{\"transition\": \"Let's start with something about you.\", \"question\": \"Can you tell me about yourself and your background?\", \"acknowledgment\": \"That's great, thanks for sharing.\"},"
                                    +
                                    "{\"transition\": \"Now, I'd like to hear about your experience.\", \"question\": \"What interests you about this role?\", \"acknowledgment\": \"I appreciate your perspective on that.\"},"
                                    +
                                    "{\"transition\": \"Let me ask you about your skills.\", \"question\": \"What are your key strengths?\", \"acknowledgment\": \"Those sound like valuable skills.\"},"
                                    +
                                    "{\"transition\": \"I'm curious about your approach.\", \"question\": \"How do you handle challenges?\", \"acknowledgment\": \"That's a thoughtful approach.\"},"
                                    +
                                    "{\"transition\": \"One more question for you.\", \"question\": \"Where do you see yourself in the future?\", \"acknowledgment\": \"Thank you for sharing your goals.\"}"
                                    +
                                    "], " +
                                    "\"closing\": \"Thank you so much for your time today. You've shared some really interesting insights. We'll be in touch soon with next steps. Have a great day!\"}");
                });
    }

    /**
     * Calls Gemini to analyze a transcript.
     */
    public Mono<Map<String, Object>> analyzeTranscript(String transcript) {
        String prompt = String.format(
                "Analyze the following interview transcript: %n%n%s%n%n" +
                        "Provide feedback as a JSON object with three keys: " +
                        "'strengths' (string), 'areas_for_improvement' (string), " +
                        "and 'overall_score' (integer out of 100). " +
                        "Return ONLY the raw JSON object.",
                transcript);

        java.util.Objects.requireNonNull(prompt, PROMPT_NOT_NULL_MSG);
        GeminiRequest request = java.util.Objects.requireNonNull(buildGeminiRequest(prompt),
                GEMINI_REQUEST_NOT_NULL_MSG);

        return callGeminiApi(request)
                .map(GeminiResponse::getFirstText)
                .flatMap(this::parseFeedbackJson) // Use flatMap to handle the Mono
                .onErrorResume(e -> {
                    // If the API call or parsing fails, return a map with an error
                    logger.error("Error analyzing transcript: {}", e.getMessage(), e);
                    return Mono.just(Map.of(
                            "strengths", "Analysis failed.",
                            "areas_for_improvement", "Could not generate feedback. Please try again.",
                            "overall_score", 0));
                });
    }

    /**
     * Calls Gemini to analyze a resume and provide comprehensive professional
     * assessment.
     * 
     * @param resumeText     The extracted text from the resume PDF
     * @param fileName       The name of the resume file
     * @param fileSize       The size of the file (formatted)
     * @param uploadDate     The upload date of the resume
     * @param jobDescription Optional job description for tailored analysis
     * @return A Mono containing the analysis result as a JSON string
     */
    public Mono<String> analyzeResume(String resumeText, String fileName, String fileSize, String uploadDate,
            String jobDescription) {
        // Infer role and experience level from filename or resume text
        String inferredRole = inferRoleFromText(fileName + " " + resumeText);
        String inferredLevel = inferExperienceLevelFromText(resumeText);

        String prompt = String.format(
                """
                        RESUME ANALYSIS REQUEST - PROFESSIONAL ASSESSMENT

                        FILE INFORMATION:
                        - File Name: %s
                        - File Size: %s
                        - Upload Date: %s
                        - Inferred Role Category: %s
                        - Estimated Experience Level: %s

                        RESUME CONTENT:
                        %s

                        ANALYSIS CONTEXT:
                        This is a PDF resume that requires comprehensive professional analysis. Based on the resume content and metadata, please provide a detailed career assessment that would be relevant for a %s position.

                        REQUIRED ANALYSIS AREAS:

                        1. SKILLS ASSESSMENT:
                           Technical Skills: Evaluate the technical skills present in the resume and recommend additional essential technical skills for %s roles, including programming languages, tools, and technologies that are currently in demand.

                           Soft Skills: Identify demonstrated soft skills and suggest critical soft skills such as communication, leadership, problem-solving, teamwork, and adaptability that are valuable in this field.

                           Domain Expertise: Assess industry-specific knowledge and suggest specialized areas that would enhance the candidate's profile.

                        2. EXPERIENCE EVALUATION:
                           - Analyze how work experience is structured and provide guidance for improvement
                           - Evaluate achievement quantification and suggest ways to demonstrate impact
                           - Review career progression narrative and recommend best practices
                           - Assess relevant projects and accomplishments, highlighting areas for enhancement

                        3. EDUCATION & CERTIFICATIONS:
                           - Evaluate the educational background relevance for the target role
                           - Recommend valuable certifications and professional development opportunities
                           - Provide guidance on how to present academic achievements more effectively

                        4. RESUME OPTIMIZATION STRATEGIES:
                           ATS Optimization: Provide specific recommendations for improving Applicant Tracking System compatibility, including keyword usage, formatting best practices, and standard section headers.

                           Keyword Enhancement: Suggest industry-relevant keywords and phrases that should be included to improve visibility and match job requirements.

                           Structure Improvements: Recommend optimal resume structure, section organization, and content flow based on current best practices.

                        5. INTERVIEW PREPARATION:
                           - Suggest common interview questions for %s positions based on the resume content
                           - Provide guidance on using the STAR method for behavioral questions
                           - Recommend research strategies for target companies
                           - Suggest ways to demonstrate expertise and passion during interviews

                        6. CAREER ADVANCEMENT:
                           Job Recommendations: Based on the resume content, role, and experience level, suggest suitable positions including:
                           - Entry-level opportunities for career changers
                           - Mid-level positions for experienced professionals
                           - Senior roles for advanced candidates
                           - Leadership positions for management-track individuals

                           Growth Opportunities: Identify potential career paths and skill development areas for long-term success.

                        7. PROFESSIONAL DEVELOPMENT:
                           - Recommend ongoing learning opportunities specific to the candidate's background
                           - Suggest networking strategies and professional associations
                           - Identify emerging trends and skills in the field

                        %s

                        RESPONSE FORMAT:
                        Provide your analysis as a JSON object with the following structure:
                        {
                          "overallScore": <integer 0-100>,
                          "skillsAssessment": {
                            "technical": [<array of technical skill observations and recommendations>],
                            "soft": [<array of soft skill observations and recommendations>],
                            "domain": [<array of domain expertise observations and recommendations>]
                          },
                          "experienceEvaluation": [<array of experience-related insights and improvements>],
                          "educationCertifications": [<array of education/certification recommendations>],
                          "resumeOptimization": {
                            "ats": [<array of ATS optimization recommendations>],
                            "keywords": [<array of keyword enhancement suggestions>],
                            "structure": [<array of structure improvement tips>]
                          },
                          "interviewPreparation": [<array of interview questions, strategies, and tips>],
                          "careerAdvancement": {
                            "jobRecommendations": [<array of suitable job positions>],
                            "growthOpportunities": [<array of career path and skill development areas>]
                          },
                          "professionalDevelopment": [<array of learning, networking, and trend insights>]
                        }

                        Important: Each array should contain 3-5 specific, actionable items. Be comprehensive but concise. Each item should be a complete, professional statement that provides clear value to the user.

                        Return ONLY the raw JSON object without any markdown formatting or additional text.
                        """,
                fileName,
                fileSize,
                uploadDate,
                inferredRole,
                inferredLevel,
                resumeText,
                inferredRole,
                inferredRole,
                inferredRole,
                jobDescription != null && !jobDescription.isEmpty()
                        ? String.format(
                                "JOB DESCRIPTION PROVIDED:%n%s%n%nPlease tailor the analysis to this specific job opportunity, highlighting alignment and gaps.",
                                jobDescription)
                        : "");

        java.util.Objects.requireNonNull(prompt, PROMPT_NOT_NULL_MSG);
        GeminiRequest request = java.util.Objects.requireNonNull(buildGeminiRequest(prompt),
                GEMINI_REQUEST_NOT_NULL_MSG);

        return callGeminiApi(request)
                .map(GeminiResponse::getFirstText)
                .map(responseText -> responseText.replace(MARKDOWN_JSON, "").replace(MARKDOWN_BACKTICKS, "").trim())
                .onErrorResume(e -> {
                    logger.error("Error analyzing resume: {}", e.getMessage(), e);
                    return Mono.just("{\"error\": \"Failed to analyze resume.\"}");
                });
    }

    /**
     * Builds a professional resume using AI based on user's raw input data.
     * 
     * @param request The resume build request containing raw user data
     * @return A Mono containing the AI-enhanced resume as a JSON string
     */
    public Mono<String> buildResume(ResumeBuildRequest request) {
        try {
            StringBuilder promptData = new StringBuilder();

            appendPersonalInfo(promptData, request);
            appendWorkExperience(promptData, request);
            appendEducation(promptData, request);
            appendSkills(promptData, request);
            appendProjects(promptData, request);
            appendCertifications(promptData, request);

            String prompt = String.format(RESUME_PROMPT_TEMPLATE, promptData.toString());
            java.util.Objects.requireNonNull(prompt, PROMPT_NOT_NULL_MSG);
            GeminiRequest geminiRequest = java.util.Objects.requireNonNull(buildGeminiRequest(prompt),
                    GEMINI_REQUEST_NOT_NULL_MSG);
            return callGeminiApi(geminiRequest)
                    .map(GeminiResponse::getFirstText)
                    .map(responseText -> responseText.replace(MARKDOWN_JSON, "").replace(MARKDOWN_BACKTICKS, "").trim())
                    .onErrorResume(e -> {
                        logger.error("Error building resume: {}", e.getMessage(), e);
                        return Mono.just("{\"error\": \"Failed to build resume. Please try again.\"}");
                    });

        } catch (Exception e) {
            return Mono.error(e);
        }
    }

    /**
     * Infers the role category from filename and resume text
     */
    private String inferRoleFromText(String text) {
        String lowerText = text.toLowerCase();
        if (lowerText.contains("software") || lowerText.contains("developer") || lowerText.contains("engineer"))
            return "Software Engineer/Developer";
        else if (lowerText.contains("data") && (lowerText.contains("scientist") || lowerText.contains("analyst")))
            return "Data Scientist/Analyst";
        else if (lowerText.contains("devops") || lowerText.contains("sre"))
            return "DevOps/SRE Engineer";
        else if (lowerText.contains("product") && lowerText.contains("manager"))
            return "Product Manager";
        else if (lowerText.contains("designer") || lowerText.contains("ux") || lowerText.contains("ui"))
            return "UX/UI Designer";
        else if (lowerText.contains("marketing"))
            return "Marketing Professional";
        else if (lowerText.contains("sales"))
            return "Sales Professional";
        return "Professional";
    }

    /**
     * Infers experience level from resume text
     */
    private String inferExperienceLevelFromText(String text) {
        String lowerText = text.toLowerCase();
        if (lowerText.contains("senior") || lowerText.contains("lead") || lowerText.contains("principal"))
            return "Senior Level";
        else if (lowerText.contains("junior") || lowerText.contains("intern") || lowerText.contains("entry"))
            return "Entry Level";
        else if (text.split("experience").length > 1 || text.split("worked").length > 2)
            return "Mid Level";
        return "Mid Level";
    }

    private GeminiRequest buildGeminiRequest(@NonNull String prompt) {
        java.util.Objects.requireNonNull(prompt, PROMPT_NOT_NULL_MSG);
        GeminiRequest request = new GeminiRequest(
                List.of(new GeminiRequest.Content(
                        List.of(new GeminiRequest.Part(prompt)))));
        return java.util.Objects.requireNonNull(request, GEMINI_REQUEST_NOT_NULL_MSG);
    }

    private Mono<GeminiResponse> callGeminiApi(@NonNull GeminiRequest request) {
        java.util.Objects.requireNonNull(request, GEMINI_REQUEST_NOT_NULL_MSG);
        // Using gemini-2.0-flash - the latest fast and reliable model
        String fullUrl = geminiApiUrl + "/v1beta/models/gemini-2.5-flash:generateContent?key=" + geminiApiKey;

        return webClient.post()
                .uri(fullUrl)
                .header("Content-Type", "application/json")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(GeminiResponse.class)
                .doOnError(error -> {
                    logger.error("Gemini API Error: {}", error.getMessage(), error);
                    logger.error("URL: {}", fullUrl);
                });
    }

    private Mono<Map<String, Object>> parseFeedbackJson(String jsonString) {
        try {
            // Remove markdown backticks if present
            String cleanedJson = jsonString.replace(MARKDOWN_JSON, "").replace(MARKDOWN_BACKTICKS, "").trim();

            @SuppressWarnings("unchecked")
            Map<String, Object> feedbackMap = objectMapper.readValue(cleanedJson, Map.class);
            return Mono.just(feedbackMap);
        } catch (Exception e) {
            return Mono.error(new RuntimeException("Failed to parse JSON feedback: " + e.getMessage()));
        }
    }

    // --- Helpers for buildResume refactor ---
    private static final String RESUME_PROMPT_TEMPLATE = """
            You are an expert resume writer with years of experience in career counseling and professional document creation.

            Your task is to transform the following raw resume data into professionally written, compelling content.

            RAW RESUME DATA:
            %s

            INSTRUCTIONS:
            1. Rewrite all experience descriptions using strong action verbs and quantifiable achievements
            2. Create a compelling professional summary (2-3 sentences) based on the experience and skills
            3. Enhance project descriptions to highlight impact and technical complexity
            4. Organize skills into logical categories (e.g., Programming Languages, Frameworks, Tools, Soft Skills)
            5. Ensure all dates are properly formatted
            6. Use professional, industry-standard terminology
            7. Make achievements specific and measurable where possible

            IMPORTANT RULES:
            - Keep all factual information accurate (dates, company names, schools, etc.)
            - DO NOT invent or fabricate any experiences, achievements, or qualifications
            - DO enhance phrasing and presentation of existing information
            - Use active voice and strong action verbs (e.g., "Engineered", "Architected", "Optimized", "Spearheaded")

            RETURN FORMAT:
            Return a JSON object with the following structure:
            {
                "summary": "<professional summary paragraph>",
                "experience": [
                    {
                        "title": "<job title>",
                        "company": "<company name>",
                        "location": "<location if provided>",
                        "startDate": "<formatted start date>",
                        "endDate": "<formatted end date or 'Present'>",
                        "bullets": ["<enhanced bullet point 1>", "<enhanced bullet point 2>", ...]
                    }
                ],
                "education": [
                    {
                        "degree": "<degree name>",
                        "school": "<school name>",
                        "location": "<location if provided>",
                        "startDate": "<formatted start date>",
                        "endDate": "<formatted end date>",
                        "gpa": "<GPA if provided>",
                        "achievements": ["<achievement 1>", "<achievement 2>", ...]
                    }
                ],
                "skills": {
                    "technical": ["<skill 1>", "<skill 2>", ...],
                    "tools": ["<tool 1>", "<tool 2>", ...],
                    "soft": ["<soft skill 1>", "<soft skill 2>", ...]
                },
                "projects": [
                    {
                        "name": "<project name>",
                        "description": "<enhanced project description>",
                        "technologies": ["<tech 1>", "<tech 2>", ...],
                        "link": "<project link if provided>",
                        "highlights": ["<highlight 1>", "<highlight 2>", ...]
                    }
                ],
                "certifications": [
                    {
                        "name": "<certification name>",
                        "issuer": "<issuing organization>",
                        "date": "<date obtained>",
                        "credentialId": "<credential ID if provided>"
                    }
                ]
            }

            Return ONLY the raw JSON object without any markdown formatting, code blocks, or additional text.
            """;

    private void appendPersonalInfo(StringBuilder sb, ResumeBuildRequest request) {
        sb.append(String.format("=== PERSONAL INFORMATION ===%n"));
        if (request.getPersonalInfo() != null) {
            request.getPersonalInfo().forEach((k, v) -> sb.append(String.format("%s: %s%n", k, v)));
        }
    }

    private void appendWorkExperience(StringBuilder sb, ResumeBuildRequest request) {
        sb.append(String.format("%n=== WORK EXPERIENCE ===%n"));
        if (request.getExperience() == null || request.getExperience().isEmpty()) {
            sb.append(String.format("No experience provided.%n"));
            return;
        }
        for (int i = 0; i < request.getExperience().size(); i++) {
            Map<String, String> exp = request.getExperience().get(i);
            sb.append(String.format("Position %d:%n", i + 1));
            exp.forEach((k, v) -> sb.append(String.format(KEY_VALUE_FORMAT, k, v)));
        }
    }

    private void appendEducation(StringBuilder sb, ResumeBuildRequest request) {
        sb.append(String.format("%n=== EDUCATION ===%n"));
        if (request.getEducation() == null || request.getEducation().isEmpty()) {
            sb.append(String.format("No education provided.%n"));
            return;
        }
        for (int i = 0; i < request.getEducation().size(); i++) {
            Map<String, String> edu = request.getEducation().get(i);
            sb.append(String.format("Education %d:%n", i + 1));
            edu.forEach((k, v) -> sb.append(String.format(KEY_VALUE_FORMAT, k, v)));
        }
    }

    private void appendSkills(StringBuilder sb, ResumeBuildRequest request) {
        sb.append(String.format("%n=== SKILLS ===%n"));
        if (request.getSkills() == null || request.getSkills().isEmpty()) {
            sb.append(String.format("No skills provided.%n"));
            return;
        }
        request.getSkills().forEach(skill -> sb.append(String.format("- %s%n", skill)));
    }

    private void appendProjects(StringBuilder sb, ResumeBuildRequest request) {
        sb.append(String.format("%n=== PROJECTS ===%n"));
        if (request.getProjects() == null || request.getProjects().isEmpty()) {
            sb.append(String.format("No projects provided.%n"));
            return;
        }
        for (int i = 0; i < request.getProjects().size(); i++) {
            Map<String, String> project = request.getProjects().get(i);
            sb.append(String.format("Project %d:%n", i + 1));
            project.forEach((k, v) -> sb.append(String.format(KEY_VALUE_FORMAT, k, v)));
        }
    }

    private void appendCertifications(StringBuilder sb, ResumeBuildRequest request) {
        if (request.getCertifications() == null || request.getCertifications().isEmpty()) {
            return;
        }
        sb.append(String.format("%n=== CERTIFICATIONS ===%n"));
        for (int i = 0; i < request.getCertifications().size(); i++) {
            Map<String, String> cert = request.getCertifications().get(i);
            sb.append(String.format("Certification %d:%n", i + 1));
            cert.forEach((k, v) -> sb.append(String.format(KEY_VALUE_FORMAT, k, v)));
        }
    }
}
