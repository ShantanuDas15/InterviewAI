package com.InterviewAI.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * Configuration for Supabase REST API client.
 * Uses WebClient to interact with Supabase Storage and Database APIs.
 */
@Configuration
public class SupabaseConfig {

    @Value("${supabase.url}")
    private String supabaseUrl;

    @Value("${supabase.service.role.key}")
    private String supabaseServiceRoleKey;

    /**
     * Creates a WebClient configured for Supabase API calls.
     * The service role key provides admin-level access to Storage and Database.
     */
    @SuppressWarnings("null")
    @Bean(name = "supabaseWebClient")
    public WebClient supabaseWebClient() {
        return WebClient.builder()
                .baseUrl(supabaseUrl)
                .defaultHeader("apikey", supabaseServiceRoleKey)
                .defaultHeader("Authorization", "Bearer " + supabaseServiceRoleKey)
                .build();
    }
}
