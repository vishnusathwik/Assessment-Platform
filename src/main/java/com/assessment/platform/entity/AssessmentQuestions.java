package com.assessment.platform.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.Map;

@Entity
@Table(name = "assessment_questions", schema = "assessment_dev")
@Data
public class AssessmentQuestions {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;
    
    // Many-to-One: Many AssessmentQuestions belong to one AssessmentTest
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assessment_test_id", nullable = false)
    private AssessmentTests assessmentTest;
    
    // Many-to-One: Many AssessmentQuestions belong to one Question
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private Questions question;
    
    @Column(name = "question", nullable = false, columnDefinition = "TEXT")
    private String questionText;
    
    @Column(name = "options", columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private Map<String, Object> options;
    
    @Column(name = "correct_answer", columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private String correctAnswer;
}
