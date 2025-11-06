package com.InterviewAI.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data // Lombok annotation for getters, setters, equals, hashCode, toString
@NoArgsConstructor // Lombok for a no-args constructor
@Entity
@Table(name = "interviews") // Maps this class to the 'interviews' table
public class Interview {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(name = "user_id") // Maps to the user_id column
    private UUID userId;

    private String title;
    private String role;

    @Column(name = "experience_level")
    private String experienceLevel;

    @Column(columnDefinition = "TEXT") // Maps to the TEXT type for storing JSON questions
    private String questions;

    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = OffsetDateTime.now();
    }
}
