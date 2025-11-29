package com.interviewai.model;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Entity representing a built resume.
 * Maps to the 'built_resumes' table in Supabase.
 * Stores both the user's raw input and AI-generated professional content.
 */
@Entity
@Table(name = "built_resumes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BuiltResume {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "title", nullable = false)
    private String title;

    /**
     * Stores the user's original raw input data as JSONB.
     * This allows users to edit and regenerate their resume later.
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "user_input_data", columnDefinition = "jsonb")
    private JsonNode userInputData;

    /**
     * Stores the AI-generated professional resume content as JSONB.
     * This contains the enhanced, professionally written version.
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "ai_generated_content", columnDefinition = "jsonb")
    private JsonNode aiGeneratedContent;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = OffsetDateTime.now();
        }
    }
}
