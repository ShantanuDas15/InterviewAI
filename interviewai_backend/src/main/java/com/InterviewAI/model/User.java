package com.InterviewAI.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@Entity
@Table(name = "users") // Removed schema for H2 compatibility; will use "auth" schema in production
public class User {

    @Id
    private UUID id;

    @Column(updatable = false, insertable = false) // Managed by Supabase Auth
    private String email;

    @Column(name = "created_at", updatable = false, insertable = false) // Managed by Supabase Auth
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", insertable = false) // Managed by Supabase Auth
    private OffsetDateTime updatedAt;
}
