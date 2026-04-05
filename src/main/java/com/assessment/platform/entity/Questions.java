package com.assessment.platform.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;
import java.util.Map;

@Entity
@Table(name = "questions", schema = "assessment_dev")
@Data
public class Questions {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;
    
    @Column(name = "company_ids", columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<Long> companyIds;
    
    @Column(name = "question_text", columnDefinition = "TEXT")
    private String questionText;
    
    @Column(name = "options", columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private Map<String, Object> options;
    
    @Column(name = "answer")
    private String answer;
    
    @Column(name = "valid")
    private Boolean valid;
    
    // One-to-Many: Question has many AssessmentQuestions
    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<AssessmentQuestions> assessmentQuestions;
}
