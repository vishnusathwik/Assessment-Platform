package com.assessment.platform.model;

import lombok.*;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ApiResponse {
    private HttpStatus status;
    private String message;
    private Object data;
    private LocalDateTime timestamp;
}