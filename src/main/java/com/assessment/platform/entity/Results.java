package com.assessment.platform.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "results", schema = "assessment_dev")
@Data
public class Results {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;
    
    // One-to-One: One Result belongs to one Attempt
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attempt_id", nullable = false, unique = true)
    private Attempts attempt;
    
    @Column(name = "score")
    private Double score;
}
