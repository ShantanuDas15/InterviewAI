package com.interviewai.exception;

public class AiAnalysisParseException extends RuntimeException {
    public AiAnalysisParseException(String message) {
        super(message);
    }

    public AiAnalysisParseException(String message, Throwable cause) {
        super(message, cause);
    }
}
