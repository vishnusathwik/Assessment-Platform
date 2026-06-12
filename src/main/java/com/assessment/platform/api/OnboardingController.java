package com.assessment.platform.api;

import com.assessment.platform.entity.Companies;
import com.assessment.platform.entity.Role;
import com.assessment.platform.entity.User;
import com.assessment.platform.entity.UserRoleMap;
import com.assessment.platform.model.ApiResponse;
import com.assessment.platform.model.CompanyOnboardRequest;
import com.assessment.platform.model.UserOnboardRequest;
import com.assessment.platform.repository.CompaniesRepository;
import com.assessment.platform.repository.RoleRepository;
import com.assessment.platform.repository.UserRepository;
import com.assessment.platform.repository.UserRoleMapRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/onboarding")
@RequiredArgsConstructor
public class OnboardingController {

    private final CompaniesRepository companiesRepository;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final UserRoleMapRepository userRoleMapRepository;

    @PostMapping("/company")
    public ResponseEntity<ApiResponse> registerCompany(@RequestBody CompanyOnboardRequest request) {
        if (companiesRepository.existsByName(request.getName())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(ApiResponse.builder()
                    .status(HttpStatus.CONFLICT)
                    .message("Company already exists")
                    .timestamp(LocalDateTime.now())
                    .build());
        }
        Companies company = new Companies();
        company.setName(request.getName());
        company.setAddress(request.getAddress());
        company.setValid(true);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.builder()
                .status(HttpStatus.CREATED)
                .message("Company registered successfully")
                .data(companiesRepository.save(company))
                .timestamp(LocalDateTime.now())
                .build());
    }

    @PostMapping("/user")
    public ResponseEntity<ApiResponse> registerUser(@RequestBody UserOnboardRequest request) {
        Companies company = companiesRepository.findById(request.getCompanyId()).orElse(null);
        if (company == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ApiResponse.builder()
                    .status(HttpStatus.NOT_FOUND)
                    .message("Company not found")
                    .timestamp(LocalDateTime.now())
                    .build());
        }

        List<Role> roles = roleRepository.findByName(request.getRole());
        if (roles.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ApiResponse.builder()
                    .status(HttpStatus.NOT_FOUND)
                    .message("Role not found: " + request.getRole())
                    .timestamp(LocalDateTime.now())
                    .build());
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setName(request.getName());
        user.setCompany(company);
        user.setValid(true);
        User savedUser = userRepository.save(user);

        UserRoleMap userRoleMap = new UserRoleMap();
        userRoleMap.setUser(savedUser);
        userRoleMap.setRole(roles.get(0));
        userRoleMapRepository.save(userRoleMap);

        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.builder()
                .status(HttpStatus.CREATED)
                .message("User registered successfully")
                .data(savedUser)
                .timestamp(LocalDateTime.now())
                .build());
    }
}
