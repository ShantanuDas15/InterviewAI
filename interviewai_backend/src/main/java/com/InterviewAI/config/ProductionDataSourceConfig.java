package com.InterviewAI.config;

import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import javax.sql.DataSource;

@Configuration
@Profile("prod")
public class ProductionDataSourceConfig {

    /**
     * Production DataSource that uses environment variables.
     * This bean only activates when spring.profiles.active includes "prod"
     */
    @Bean
    public DataSource dataSource() {
        String url = System.getenv("DB_URL");
        String username = System.getenv("DB_USERNAME");
        String password = System.getenv("DB_PASSWORD");

        // Fallback to properties if env vars not set
        if (url == null || url.isEmpty()) {
            url = "jdbc:postgresql://aws-0-ap-south-1.pooler.supabase.com:6543/postgres?prepareThreshold=0";
        }
        if (username == null || username.isEmpty()) {
            username = "postgres.ymnoeizgsmwgswswcpea";
        }
        if (password == null || password.isEmpty()) {
            password = "Shantanu@123456789";
        }

        System.out.println("Production DataSource initialized");
        System.out.println("Database URL: " + url);

        return DataSourceBuilder.create()
                .driverClassName("org.postgresql.Driver")
                .url(url)
                .username(username)
                .password(password)
                .build();
    }
}
