package com.InterviewAI.repository;

import com.InterviewAI.model.BuiltResume;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * Repository for accessing BuiltResume entities.
 * Provides CRUD operations for resumes built by users.
 */
@Repository
public interface BuiltResumeRepository extends JpaRepository<BuiltResume, UUID> {

    /**
     * Find all resumes built by a specific user.
     * 
     * @param userId The user's UUID
     * @return List of built resumes ordered by creation date (newest first)
     */
    List<BuiltResume> findByUserIdOrderByCreatedAtDesc(UUID userId);
}
