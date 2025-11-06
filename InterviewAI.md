Here is a professional development plan for the AI Mock Interview application, outlining the complete tech stack, folder structure, and dependencies for a Flutter Web frontend and a Spring Boot backend using Supabase.

---

# **AI Mock Interview Platform: Development Plan**

This document outlines the architecture, tech stack, and project structure for building the "InterviewAI" AI Mock Interview web application.

The architecture consists of a **Flutter Web** frontend for the user interface and a **Spring Boot** backend to orchestrate AI logic. **Supabase** will be used as the all-in-one backend-as-a-service (BaaS) for database (PostgreSQL) and authentication (OAuth 2.0).

---

## **1\. Core Tech Stack**

| Component | Technology | Purpose |
| :---- | :---- | :---- |
| **Frontend** | **Flutter Web** | Building the client-side user interface. |
| **Backend** | **Spring Boot** | Serves as the API layer, handling business logic and AI integration. |
| **Authentication** | **Supabase Auth** | Manages user sign-up and sign-in (Google OAuth 2.0). |
| **Database** | **Supabase DB (PostgreSQL)** | Stores all application data (users, interviews, feedback). |
| **AI Voice** | **Vapi AI** (JS SDK) | Provides the real-time, conversational AI agent. |
| **AI Model** | **Google Gemini** | Generates interview questions and analyzes transcripts for feedback. |

### **Core Architectural Flow**

1. **Authentication:** The Flutter app uses the supabase\_flutter client to handle Google Sign-In. Supabase manages the entire OAuth flow.  
2. **Session Management:** Once signed in, the Flutter client receives a **Supabase JWT (Access Token)**.  
3. **API Communication:** Every request from Flutter to the Spring Boot backend is authenticated by attaching this Supabase JWT in the Authorization: Bearer \<token\> header.  
4. **Backend Security:** The Spring Boot backend is configured with Spring Security to validate the Supabase JWT (using your project's JWT\_SECRET).  
5. **AI Orchestration:**  
   * **Question Generation:** Flutter asks the Spring Boot API to create an interview. Spring Boot calls the Google Gemini API, gets the questions, and saves the new Interview to the Supabase PostgreSQL database.  
   * **Interview Call:** The Flutter app uses the vapi\_flutter package (which uses JS interop) to start the voice call.  
   * **Feedback Generation:** When the call ends, Flutter sends the transcript to the Spring Boot API. Spring Boot calls Google Gemini for analysis and saves the Feedback to the Supabase database.

---

## **2\. Project Folder Structure**

### **Backend (Spring Boot \- InterviewAI\_backend)**

interviewai\_backend/  
├── src/  
│   ├── main/  
│   │   ├── java/  
│   │   │   └── com/InterviewAI/  
│   │   │       ├── InterviewAIApplication.java  
│   │   │       ├── config/  
│   │   │       │   └── SecurityConfig.java         \# Configures Spring Security to validate Supabase JWTs  
│   │   │       ├── controller/  
│   │   │       │   ├── InterviewController.java    \# (e.g., POST /api/interviews/generate)  
│   │   │       │   └── FeedbackController.java     \# (e.g., POST /api/feedback)  
│   │   │       ├── dto/  
│   │   │       │   ├── InterviewRequest.java     \# DTOs for API requests/responses  
│   │   │       │   └── FeedbackRequest.java  
│   │   │       ├── model/  
│   │   │       │   ├── User.java                 \# JPA Entity for the 'users' table  
│   │   │       │   ├── Interview.java            \# JPA Entity for the 'interviews' table  
│   │   │       │   └── Feedback.java             \# JPA Entity for the 'feedback' table  
│   │   │       ├── repository/  
│   │   │       │   ├── UserRepository.java  
│   │   │       │   ├── InterviewRepository.java  
│   │   │       │   └── FeedbackRepository.java   \# Spring Data JPA repositories  
│   │   │       └── service/  
│   │   │           ├── GeminiService.java        \# Logic to call Google Gemini API  
│   │   │           ├── InterviewService.java     \# Business logic for interviews  
│   │   │           └── FeedbackService.java      \# Business logic for feedback  
│   │   └── resources/  
│   │       └── application.properties          \# Spring Boot config  
│   └── test/  
│       └── java/  
├── .gitignore  
├── pom.xml                                     \# Maven dependencies  
└── README.md

### **Frontend (Flutter Web \- InterviewAI\_frontend)**

interviewai\_frontend/  
├── lib/  
│   ├── main.dart                             \# App entry point, Supabase init, Riverpod setup  
│   ├── app\_router.dart                       \# Configuration for go\_router  
│   ├── constants/  
│   │   ├── app\_colors.dart  
│   │   └── api\_constants.dart                \# (e.g., final String API\_BASE\_URL \= "...")  
│   ├── models/  
│   │   ├── interview.dart                    \# Data models with fromJson/toJson  
│   │   ├── feedback.dart  
│   │   └── user.dart  
│   ├── providers/  
│   │   ├── auth\_provider.dart                \# Riverpod provider for auth state  
│   │   ├── interviews\_provider.dart          \# Riverpod provider for interview list  
│   │   └── vapi\_provider.dart                \# Riverpod provider for call state  
│   ├── screens/  
│   │   ├── auth/  
│   │   │   └── sign\_in\_screen.dart             \# Google Sign-In button  
│   │   ├── dashboard/  
│   │   │   └── dashboard\_screen.dart           \# Shows list of interviews  
│   │   ├── interview/  
│   │   │   └── interview\_screen.dart           \# The main interview UI  
│   │   └── feedback/  
│   │       └── feedback\_screen.dart            \# Displays feedback from the API  
│   ├── services/  
│   │   ├── api\_service.dart                  \# Handles all HTTP calls to Spring Boot  
│   │   └── auth\_service.dart                 \# Manages Supabase auth (signInWithOAuth)  
│   └── widgets/  
│       ├── interview\_card.dart               \# Reusable card component  
│       └── responsive\_layout.dart            \# Handles web layout  
│  
├── web/  
│   ├── index.html                            \# IMPORTANT: Vapi JS SDK script is added here  
│   └── manifest.json  
│  
├── .gitignore  
├── pubspec.yaml                              \# Flutter dependencies  
└── README.md

---

## **3\. Dependencies**

### **Backend (Spring Boot \- pom.xml)**

These are the key dependencies for your Spring Boot application.

XML

\<dependency\>  
    \<groupId\>org.springframework.boot\</groupId\>  
    \<artifactId\>spring-boot-starter-web\</artifactId\>  
\</dependency\>

\<dependency\>  
    \<groupId\>org.springframework.boot\</groupId\>  
    \<artifactId\>spring-boot-starter-data-jpa\</artifactId\>  
\</dependency\>  
\<dependency\>  
    \<groupId\>org.postgresql\</groupId\>  
    \<artifactId\>postgresql\</artifactId\>  
    \<scope\>runtime\</scope\>  
\</dependency\>

\<dependency\>  
    \<groupId\>org.springframework.boot\</groupId\>  
    \<artifactId\>spring-boot-starter-security\</artifactId\>  
\</dependency\>  
\<dependency\>  
    \<groupId\>org.springframework.boot\</groupId\>  
    \<artifactId\>spring-boot-starter-oauth2-resource-server\</artifactId\>  
\</dependency\>

\<dependency\>  
    \<groupId\>org.springframework.boot\</groupId\>  
    \<artifactId\>spring-boot-starter-webflux\</artifactId\>  
\</dependency\>

\<dependency\>  
    \<groupId\>org.projectlombok\</groupId\>  
    \<artifactId\>lombok\</artifactId\>  
    \<optional\>true\</optional\>  
\</dependency\>

### **Frontend (Flutter \- pubspec.yaml)**

These are the key dependencies for your Flutter Web application.

YAML

dependencies:  
  flutter:  
    sdk: flutter

  \# \--- CORE SERVICES \---  
  \# Supabase Client for Auth (Google) and database listeners  
  supabase\_flutter: ^2.5.0

  \# Vapi Client for Flutter (handles JS Interop for web)  
  vapi\_flutter: ^0.1.0 \# Or the latest version

  \# \--- STATE MANAGEMENT \---  
  \# Global state management for auth, interviews, etc.  
  flutter\_riverpod: ^2.5.1  
  riverpod\_annotation: ^2.3.5

  \# \--- NETWORKING \---  
  \# For making authenticated HTTP calls to your Spring Boot backend  
  http: ^1.2.0

  \# \--- ROUTING \---  
  \# For clean, URL-based web navigation  
  go\_router: ^14.2.0

  \# \--- UTILITIES & UI \---  
  \# For easy Google Sign-In button  
  sign\_in\_button: ^3.2.0  
    
  \# For date formatting (e.g., "Nov 2, 2025")  
  intl: ^0.19.0   
    
  \# For responsive web design  
  responsive\_builder: ^0.7.0   
    
  \# For custom fonts  
  google\_fonts: ^6.2.1

dev\_dependencies:  
  flutter\_test:  
    sdk: flutter

  \# Code generation for Riverpod  
  riverpod\_generator: ^2.4.0  
  build\_runner: ^2.4.9  
