package com.InterviewAI.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@Entity
@Table(name = "feedback") // Maps this class to the 'feedback' table
public class Feedback {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(name = "interview_id") // Foreign key to interviews table
    private UUID interviewId;

    @Column(name = "user_id") // Foreign key to auth.users table
    private UUID userId;

    @Column(columnDefinition = "TEXT") // Store the full transcript
    private String transcript;

    @Column(columnDefinition = "TEXT") // Store AI-generated strengths
    private String strengths;

    @Column(name = "areas_for_improvement", columnDefinition = "TEXT")
    private String areasForImprovement;

    @Column(name = "overall_score")
    private Integer overallScore;

    @Column(name = "generated_at", updatable = false)
    private OffsetDateTime generatedAt;

    @PrePersist
    protected void onGenerated() {
        generatedAt = OffsetDateTime.now();
    }
}
