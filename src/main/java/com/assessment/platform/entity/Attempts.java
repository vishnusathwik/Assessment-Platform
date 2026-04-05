package com.assessment.platform.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

@Entity
@Table(name = "attempts", schema = "assessment_dev")
@Data
public class Attempts {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;
    
    // Many-to-One: Many Attempts belong to one User
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    // Many-to-One: Many Attempts belong to one AssessmentTest
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assessment_test_id", nullable = false)
    private AssessmentTests assessmentTest;
    
    @Column(name = "score")
    private Double score;
    
    // One-to-Many: Attempt has many AttemptAnswers
    @OneToMany(mappedBy = "attempt", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<AttemptAnswers> attemptAnswers;
    
    // One-to-One: Attempt has one Result
    @OneToOne(mappedBy = "attempt", cascade = CascadeType.ALL, orphanRemoval = true)
    private Results result;
}
