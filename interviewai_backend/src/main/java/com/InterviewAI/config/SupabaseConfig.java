package com.interviewai.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.lang.NonNull;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * Configuration for Supabase REST API client.
 * Uses WebClient to interact with Supabase Storage and Database APIs.
 */
@Configuration
public class SupabaseConfig {

    private final @NonNull String supabaseUrl;
    private final @NonNull String supabaseServiceRoleKey;

    public SupabaseConfig(@Value("${supabase.url}") @NonNull String supabaseUrl,
            @Value("${supabase.service.role.key}") @NonNull String supabaseServiceRoleKey) {
        this.supabaseUrl = java.util.Objects.requireNonNull(supabaseUrl, "supabase.url must not be null");
        this.supabaseServiceRoleKey = java.util.Objects.requireNonNull(supabaseServiceRoleKey,
                "supabase.service.role.key must not be null");
    }

    /**
     * Creates a WebClient configured for Supabase API calls.
     * The service role key provides admin-level access to Storage and Database.
     */
    @Bean(name = "supabaseWebClient")
    public WebClient supabaseWebClient() {
        return WebClient.builder()
                .baseUrl(supabaseUrl)
                .defaultHeader("apikey", supabaseServiceRoleKey)
                .defaultHeader("Authorization", "Bearer " + supabaseServiceRoleKey)
                .build();
    }
}
