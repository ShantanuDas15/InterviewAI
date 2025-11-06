package com.InterviewAI.repository;

import com.InterviewAI.model.Feedback;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface FeedbackRepository extends JpaRepository<Feedback, UUID> {
    List<Feedback> findByInterviewId(UUID interviewId);

    Optional<Feedback> findFirstByInterviewId(UUID interviewId);

    // New method to find all feedback for a specific user
    List<Feedback> findByUserId(UUID userId);
}
