package com.assessment.platform.api;

import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class DefaultController {
    private final EntityManager entityManager;
        // This controller can be used for any default endpoints or health checks in the future.
        @GetMapping("/db-info")
        public String dbInfo() {
            Object[] result = (Object[]) entityManager
                    .createNativeQuery("SELECT current_database(), current_schema()")
                    .getSingleResult();

            return "Database: " + result[0] + ", Schema: " + result[1];
        }
}
