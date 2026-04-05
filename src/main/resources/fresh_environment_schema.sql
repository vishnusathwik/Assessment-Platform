-- ============================================================================
-- COMPLETE DATABASE SCHEMA - FRESH ENVIRONMENT
-- This file creates the entire database schema from scratch
-- Safe to run on a fresh database with no existing tables
-- ============================================================================

-- ============================================================================
-- CREATE SCHEMA
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS assessment_dev;

-- ============================================================================
-- CREATE COMPANIES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS assessment_dev.companies (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    valid BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CREATE ROLES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS assessment_dev.roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    valid BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CREATE USERS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS assessment_dev.users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    company_id BIGINT NOT NULL,
    valid BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CREATE USER_ROLE_MAP TABLE (Junction Table)
-- ============================================================================

CREATE TABLE IF NOT EXISTS assessment_dev.user_role_map (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_role UNIQUE (user_id, role_id)
);

-- ============================================================================
-- CREATE QUESTIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS assessment_dev.questions (
    id BIGSERIAL PRIMARY KEY,
    question_text TEXT NOT NULL,
    company_ids JSONB,
    options JSONB,
    answer TEXT,
    valid BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CREATE ASSESSMENT_TESTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS assessment_dev.assessment_tests (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    company_id BIGINT NOT NULL,
    valid BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CREATE ASSESSMENT_QUESTIONS TABLE (Junction Table)
-- ============================================================================

CREATE TABLE IF NOT EXISTS assessment_dev.assessment_questions (
    id BIGSERIAL PRIMARY KEY,
    assessment_test_id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    question_text TEXT NOT NULL,
    options JSONB,
    correct_answer JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CREATE ATTEMPTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS assessment_dev.attempts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    assessment_test_id BIGINT NOT NULL,
    score DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CREATE ATTEMPT_ANSWERS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS assessment_dev.attempt_answers (
    id BIGSERIAL PRIMARY KEY,
    attempt_id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    answer TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CREATE RESULTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS assessment_dev.results (
    id BIGSERIAL PRIMARY KEY,
    attempt_id BIGINT NOT NULL UNIQUE,
    score DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- ADD FOREIGN KEY CONSTRAINTS
-- ============================================================================

-- Foreign Key: users.company_id -> companies.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.users
  ADD CONSTRAINT fk_users_company
  FOREIGN KEY (company_id) REFERENCES assessment_dev.companies(id)
  ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Foreign Key: user_role_map.user_id -> users.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.user_role_map
  ADD CONSTRAINT fk_user_role_user
  FOREIGN KEY (user_id) REFERENCES assessment_dev.users(id)
  ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Foreign Key: user_role_map.role_id -> roles.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.user_role_map
  ADD CONSTRAINT fk_user_role_role
  FOREIGN KEY (role_id) REFERENCES assessment_dev.roles(id)
  ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Foreign Key: assessment_tests.company_id -> companies.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.assessment_tests
  ADD CONSTRAINT fk_assessment_tests_company
  FOREIGN KEY (company_id) REFERENCES assessment_dev.companies(id)
  ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Foreign Key: assessment_questions.assessment_test_id -> assessment_tests.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.assessment_questions
  ADD CONSTRAINT fk_assessment_questions_test
  FOREIGN KEY (assessment_test_id) REFERENCES assessment_dev.assessment_tests(id)
  ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Foreign Key: assessment_questions.question_id -> questions.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.assessment_questions
  ADD CONSTRAINT fk_assessment_questions_question
  FOREIGN KEY (question_id) REFERENCES assessment_dev.questions(id)
  ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Foreign Key: attempts.user_id -> users.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.attempts
  ADD CONSTRAINT fk_attempts_user
  FOREIGN KEY (user_id) REFERENCES assessment_dev.users(id)
  ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Foreign Key: attempts.assessment_test_id -> assessment_tests.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.attempts
  ADD CONSTRAINT fk_attempts_assessment
  FOREIGN KEY (assessment_test_id) REFERENCES assessment_dev.assessment_tests(id)
  ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Foreign Key: attempt_answers.attempt_id -> attempts.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.attempt_answers
  ADD CONSTRAINT fk_attempt_answers_attempt
  FOREIGN KEY (attempt_id) REFERENCES assessment_dev.attempts(id)
  ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Foreign Key: attempt_answers.question_id -> questions.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.attempt_answers
  ADD CONSTRAINT fk_attempt_answers_question
  FOREIGN KEY (question_id) REFERENCES assessment_dev.questions(id)
  ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Foreign Key: results.attempt_id -> attempts.id
DO $$ BEGIN
  ALTER TABLE assessment_dev.results
  ADD CONSTRAINT fk_results_attempt
  FOREIGN KEY (attempt_id) REFERENCES assessment_dev.attempts(id)
  ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_users_company_id ON assessment_dev.users(company_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON assessment_dev.users(email);
CREATE INDEX IF NOT EXISTS idx_user_role_user_id ON assessment_dev.user_role_map(user_id);
CREATE INDEX IF NOT EXISTS idx_user_role_role_id ON assessment_dev.user_role_map(role_id);
CREATE INDEX IF NOT EXISTS idx_assessment_tests_company_id ON assessment_dev.assessment_tests(company_id);
CREATE INDEX IF NOT EXISTS idx_assessment_questions_test_id ON assessment_dev.assessment_questions(assessment_test_id);
CREATE INDEX IF NOT EXISTS idx_assessment_questions_question_id ON assessment_dev.assessment_questions(question_id);
CREATE INDEX IF NOT EXISTS idx_attempts_user_id ON assessment_dev.attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_attempts_assessment_id ON assessment_dev.attempts(assessment_test_id);
CREATE INDEX IF NOT EXISTS idx_attempt_answers_attempt_id ON assessment_dev.attempt_answers(attempt_id);
CREATE INDEX IF NOT EXISTS idx_attempt_answers_question_id ON assessment_dev.attempt_answers(question_id);
CREATE INDEX IF NOT EXISTS idx_results_attempt_id ON assessment_dev.results(attempt_id);

-- ============================================================================
-- INSERT SAMPLE DATA (Optional)
-- ============================================================================

-- Insert default company
INSERT INTO assessment_dev.companies (name, address, valid)
VALUES ('Default Company', 'Default Address', true)
ON CONFLICT DO NOTHING;

-- Insert default roles
INSERT INTO assessment_dev.roles (name, description, valid)
VALUES
  ('PLATFORM_ADMIN', 'Platform administrator with full access', true),
  ('COMPANY_ADMIN', 'Company administrator who manages assessments', true),
  ('CANDIDATE', 'Candidate who takes assessments', true)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- VERIFY SCHEMA
-- ============================================================================

-- List all tables
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'assessment_dev';

-- Check users table structure
-- \d+ assessment_dev.users

-- Check all foreign keys
-- SELECT constraint_name FROM information_schema.table_constraints
-- WHERE table_schema = 'assessment_dev' AND constraint_type = 'FOREIGN KEY';

-- Check all indexes
-- SELECT indexname FROM pg_indexes
-- WHERE schemaname = 'assessment_dev';

-- ============================================================================
-- END OF SCHEMA CREATION
-- ============================================================================

COMMIT;

