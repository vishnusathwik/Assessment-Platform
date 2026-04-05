package com.assessment.platform.api;

import com.assessment.platform.model.ApiResponse;
import com.assessment.platform.repository.UserRepository;
import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

@RestController
@RequiredArgsConstructor
public class PlatformController {
    private final UserRepository userRepository;

    @GetMapping("/hello")
    public ResponseEntity<ApiResponse> sayHello() {
        ApiResponse response = ApiResponse.builder()
                .status(HttpStatus.OK)
                .message("Hello, welcome to the assessment platform!")
                .data(null)
                .timestamp(LocalDateTime.now())
                .build();

        return ResponseEntity.ok(response);
    }
    @GetMapping("/users")
    public ResponseEntity<ApiResponse> fetchAllUsers(){
        ApiResponse response = ApiResponse.builder()
                .status(HttpStatus.OK)
                .message("Fetched all user IDs successfully!")
                .data(userRepository.findAll())
                .timestamp(LocalDateTime.now())
                .build();

        return ResponseEntity.ok(response);

    }


}



