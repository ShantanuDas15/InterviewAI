package com.interviewai.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.interviewai.model.ResumeAnalysis;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository for accessing ResumeAnalysis entities.
 */
@Repository
public interface ResumeAnalysisRepository extends JpaRepository<ResumeAnalysis, UUID> {

    /**
     * Find the analysis for a specific resume.
     */
    Optional<ResumeAnalysis> findByResumeId(UUID resumeId);

    /**
     * Find all analyses for a specific user.
     */
    java.util.List<ResumeAnalysis> findByUserId(UUID userId);
}
