package com.assessment.platform.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "attempt_answers", schema = "assessment_dev")
@Data
public class AttemptAnswers {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;
    
    // Many-to-One: Many AttemptAnswers belong to one Attempt
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attempt_id", nullable = false)
    private Attempts attempt;
    
    // Many-to-One: Many AttemptAnswers belong to one Question
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private Questions question;
    
    @Column(name = "answer", columnDefinition = "TEXT")
    private String answer;
}
