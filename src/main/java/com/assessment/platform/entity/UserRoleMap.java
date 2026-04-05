package com.assessment.platform.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "user_role_map", schema = "assessment_dev")
@Data
public class UserRoleMap {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;
    
    // Many-to-One: Many UserRoles belong to one User
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    // Many-to-One: Many UserRoles belong to one Role
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;
}
