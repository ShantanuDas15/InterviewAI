// src/main/java/com/InterviewAI/config/SecurityConfig.java
package com.InterviewAI.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import javax.crypto.spec.SecretKeySpec;
import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // Injects the 'supabase.jwt.secret' from application.properties
    @Value("${supabase.jwt.secret}")
    private String jwtSecret;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. Enable CORS
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))

                // 2. Disable CSRF (not needed for stateless, token-based APIs)
                .csrf(csrf -> csrf.disable())

                // 3. Make the API stateless (no sessions)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                // 4. Set authorization rules
                .authorizeHttpRequests(authorize -> authorize
                        // Allow health checks or other public endpoints
                        .requestMatchers("/public/**", "/").permitAll()
                        // Secure all other /api/ endpoints
                        .requestMatchers("/api/**").authenticated()
                        // Deny everything else
                        .anyRequest().denyAll())

                // 5. Configure as an OAuth 2.0 Resource Server
                .oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt -> jwt.decoder(jwtDecoder())));

        return http.build();
    }

    @Bean
    public JwtDecoder jwtDecoder() {
        // Supabase uses a symmetric key (HS256), so we build a decoder with it
        SecretKeySpec secretKey = new SecretKeySpec(
                jwtSecret.getBytes(),
                MacAlgorithm.HS256.getName());

        return NimbusJwtDecoder.withSecretKey(secretKey)
                .macAlgorithm(MacAlgorithm.HS256)
                .build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        // This is a basic CORS configuration for Flutter Web
        // In production, you should restrict origins
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("http://localhost:8080", "http://localhost:3000", "*")); // Allow
                                                                                                               // localhost
                                                                                                               // for
                                                                                                               // dev
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration); // Apply to all paths
        return source;
    }
}
