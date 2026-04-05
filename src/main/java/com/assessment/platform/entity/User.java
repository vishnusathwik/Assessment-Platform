package com.assessment.platform.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

@Entity
@Table(name = "users", schema = "assessment_dev")
@Data
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "email")
    private String email;

    @Column(name = "name")
    private String name;
    
    @Column(name = "valid")
    private Boolean valid;
    
    // Many-to-One: Many Users belong to one Company
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id", nullable = false)
    private Companies company;
    
    // One-to-Many: User has many UserRoles
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<UserRoleMap> userRoles;
    
    // One-to-Many: User has many Attempts
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Attempts> attempts;
    
    public User() {}
}