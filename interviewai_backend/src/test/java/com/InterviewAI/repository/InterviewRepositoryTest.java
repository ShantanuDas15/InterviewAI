package com.InterviewAI.repository;

import com.InterviewAI.model.Interview;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.TestPropertySource;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest // Loads only the JPA components, very fast
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE) // Use real Supabase database, not embedded
@TestPropertySource(locations = "classpath:application.properties")
public class InterviewRepositoryTest {

    @Autowired
    private InterviewRepository interviewRepository;

    @Test
    @SuppressWarnings("null")
    public void whenSaveInterview_thenFindById() {
        // This test requires a valid user_id (UUID).
        // For a real test, you might need to insert a user first
        // or mock it, but for this simple connection test,
        // we can use a random UUID.
        UUID testUserId = UUID.randomUUID();

        // 1. Create a new Interview object
        Interview newInterview = new Interview();
        newInterview.setUserId(testUserId);
        newInterview.setTitle("Test Interview");
        newInterview.setRole("Backend Developer");
        newInterview.setExperienceLevel("Senior");

        // 2. Save it to the database
        Interview savedInterview = interviewRepository.save(newInterview);
        assertThat(savedInterview.getId()).isNotNull();

        // 3. Retrieve it from the database
        UUID savedId = savedInterview.getId();
        var foundInterview = interviewRepository.findById(savedId);

        // 4. Assert that the operation was successful
        assertThat(foundInterview).isPresent();
        assertThat(foundInterview.get().getRole()).isEqualTo("Backend Developer");
        assertThat(foundInterview.get().getUserId()).isEqualTo(testUserId);
    }
}
