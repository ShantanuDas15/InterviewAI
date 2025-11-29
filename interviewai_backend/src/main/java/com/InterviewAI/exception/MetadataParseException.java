package com.interviewai.exception;

public class MetadataParseException extends RuntimeException {
    public MetadataParseException(String message) {
        super(message);
    }

    public MetadataParseException(String message, Throwable cause) {
        super(message, cause);
    }
}
