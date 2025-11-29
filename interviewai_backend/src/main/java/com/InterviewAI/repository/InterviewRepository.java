package com.interviewai.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.interviewai.model.Interview;

import java.util.List;
import java.util.UUID;

@Repository
public interface InterviewRepository extends JpaRepository<Interview, UUID> {
    // Spring Data JPA will automatically create query methods
    List<Interview> findByUserId(UUID userId);
}
