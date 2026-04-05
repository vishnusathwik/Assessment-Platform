package com.assessment.platform.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

@Entity
@Table(name = "assessment_tests", schema = "assessment_dev")
@Data
public class AssessmentTests {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;
    @Column(name = "name")
    private String name;
    @Column(name = "description")
    private String description;
    
    // Many-to-One: Many AssessmentTests belong to one Company
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id", nullable = false)
    private Companies company;
    
    @Column(name = "valid")
    private Boolean valid;
    
    // One-to-Many: AssessmentTest has many AssessmentQuestions
    @OneToMany(mappedBy = "assessmentTest", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<AssessmentQuestions> assessmentQuestions;
    
    // One-to-Many: AssessmentTest has many Attempts
    @OneToMany(mappedBy = "assessmentTest", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Attempts> attempts;
}
