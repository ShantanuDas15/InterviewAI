package com.InterviewAI.repository;

import com.InterviewAI.model.Interview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface InterviewRepository extends JpaRepository<Interview, UUID> {
    // Spring Data JPA will automatically create query methods
    List<Interview> findByUserId(UUID userId);
}
