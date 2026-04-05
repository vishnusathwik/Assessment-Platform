-- ============================================================================
-- COMPLETE DATABASE MIGRATION - ALTER STATEMENTS
-- Run this file to add all missing columns and constraints
-- ============================================================================

-- ============================================================================
-- STEP 1: Add Missing Columns to USERS table
-- ============================================================================

ALTER TABLE assessment_dev.users
ADD COLUMN IF NOT EXISTS company_id BIGINT;

ALTER TABLE assessment_dev.users
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE assessment_dev.users
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ============================================================================
-- STEP 2: Update USER_ROLE_MAP table - Add object relationship columns
-- ============================================================================

ALTER TABLE assessment_dev.user_role_map
ADD COLUMN IF NOT EXISTS user_id BIGINT;

ALTER TABLE assessment_dev.user_role_map
ADD COLUMN IF NOT EXISTS role_id BIGINT;

-- Drop old columns if they exist
ALTER TABLE assessment_dev.user_role_map
DROP COLUMN IF EXISTS userId CASCADE;

ALTER TABLE assessment_dev.user_role_map
DROP COLUMN IF EXISTS roleId CASCADE;

-- ============================================================================
-- STEP 3: Update ROLES table - Add audit columns
-- ============================================================================

ALTER TABLE assessment_dev.roles
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE assessment_dev.roles
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ============================================================================
-- STEP 4: Update COMPANIES table - Add audit columns
-- ============================================================================

ALTER TABLE assessment_dev.companies
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE assessment_dev.companies
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ============================================================================
-- STEP 5: Update ASSESSMENT_TESTS table
-- ============================================================================

-- Rename companyId to company_id if exists

-- Add description column
ALTER TABLE assessment_dev.assessment_tests
ADD COLUMN IF NOT EXISTS description TEXT;

-- Add audit columns
ALTER TABLE assessment_dev.assessment_tests
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE assessment_dev.assessment_tests
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ============================================================================
-- STEP 6: Update QUESTIONS table
-- ============================================================================

-- Rename old columns to snake_case
ALTER TABLE assessment_dev.questions
RENAME COLUMN IF EXISTS companiesIds TO company_ids;

ALTER TABLE assessment_dev.questions
RENAME COLUMN IF EXISTS questionText TO question_text;

-- Convert to JSONB if needed
ALTER TABLE assessment_dev.questions
ALTER COLUMN company_ids TYPE JSONB USING
  CASE
    WHEN company_ids IS NULL THEN NULL
    WHEN company_ids::text ~ '^\[' THEN company_ids::jsonb
    ELSE ('['||company_ids||']')::jsonb
  END;

ALTER TABLE assessment_dev.questions
ALTER COLUMN options TYPE JSONB USING
  CASE
    WHEN options IS NULL THEN NULL
    WHEN options::text ~ '^\{' THEN options::jsonb
    ELSE '{}'::jsonb
  END;

-- Add audit columns
ALTER TABLE assessment_dev.questions
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE assessment_dev.questions
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ============================================================================
-- STEP 7: Update ASSESSMENT_QUESTIONS table
-- ============================================================================

-- Add relationship columns
ALTER TABLE assessment_dev.assessment_questions
ADD COLUMN IF NOT EXISTS assessment_test_id BIGINT;

ALTER TABLE assessment_dev.assessment_questions
ADD COLUMN IF NOT EXISTS question_id BIGINT;

-- Rename old columns
ALTER TABLE assessment_dev.assessment_questions
RENAME COLUMN IF EXISTS assessmentId TO old_assessment_id;

-- Add new columns
ALTER TABLE assessment_dev.assessment_questions
ADD COLUMN IF NOT EXISTS question_text TEXT;

ALTER TABLE assessment_dev.assessment_questions
ADD COLUMN IF NOT EXISTS options JSONB;

ALTER TABLE assessment_dev.assessment_questions
ADD COLUMN IF NOT EXISTS correct_answer JSONB;

-- Add audit columns
ALTER TABLE assessment_dev.assessment_questions
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE assessment_dev.assessment_questions
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ============================================================================
-- STEP 8: Update ATTEMPTS table
-- ============================================================================

-- Rename userId to user_id
ALTER TABLE assessment_dev.attempts
RENAME COLUMN IF EXISTS userId TO user_id;

-- Rename assessmentTestId to assessment_test_id
ALTER TABLE assessment_dev.attempts
RENAME COLUMN IF EXISTS assessmentTestId TO assessment_test_id;

-- Add audit columns
ALTER TABLE assessment_dev.attempts
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE assessment_dev.attempts
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ============================================================================
-- STEP 9: Update ATTEMPT_ANSWERS table
-- ============================================================================

-- Rename attemptId to attempt_id
ALTER TABLE assessment_dev.attempt_answers
RENAME COLUMN IF EXISTS attemptId TO attempt_id;

-- Rename questionId to question_id
ALTER TABLE assessment_dev.attempt_answers
RENAME COLUMN IF EXISTS questionId TO question_id;

-- Add audit columns
ALTER TABLE assessment_dev.attempt_answers
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ============================================================================
-- STEP 10: Update RESULTS table
-- ============================================================================

-- Rename userId to user_id (if exists, for cleanup)
ALTER TABLE assessment_dev.results
RENAME COLUMN IF EXISTS userId TO user_id_old;

-- Rename assessmentTestId to assessment_test_id (if exists, for cleanup)
ALTER TABLE assessment_dev.results
RENAME COLUMN IF EXISTS assessmentTestId TO assessment_test_id_old;

-- Add attempt_id column for one-to-one relationship
ALTER TABLE assessment_dev.results
ADD COLUMN IF NOT EXISTS attempt_id BIGINT UNIQUE;

-- Add audit columns
ALTER TABLE assessment_dev.results
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ============================================================================
-- STEP 11: Add Foreign Key Constraints
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
-- STEP 12: Add Performance Indexes
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
-- STEP 13: Populate company_id for existing users (if needed)
-- ============================================================================

-- If you have existing users and no company_id values, you need to add them
-- IMPORTANT: Choose ONE option below:

-- Option A: If you have a companies table, assign first company to all users
-- UPDATE assessment_dev.users
-- SET company_id = (SELECT id FROM assessment_dev.companies LIMIT 1)
-- WHERE company_id IS NULL;

-- Option B: Create a default company first, then assign it
-- INSERT INTO assessment_dev.companies (name, address, valid)
-- VALUES ('Default Company', 'Default Address', true)
-- ON CONFLICT (id) DO NOTHING;
--
-- UPDATE assessment_dev.users
-- SET company_id = 1
-- WHERE company_id IS NULL;

-- ============================================================================
-- STEP 14: Add NOT NULL constraint to company_id (after data is populated)
-- ============================================================================

-- Uncomment this after ensuring all users have a company_id:
-- ALTER TABLE assessment_dev.users
-- ALTER COLUMN company_id SET NOT NULL;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Run these to verify the migration:

-- Check users table structure
-- \d+ assessment_dev.users

-- Check all columns exist
-- SELECT column_name FROM information_schema.columns
-- WHERE table_schema = 'assessment_dev' AND table_name = 'users'
-- ORDER BY ordinal_position;

-- Check foreign keys
-- SELECT constraint_name FROM information_schema.table_constraints
-- WHERE table_schema = 'assessment_dev' AND constraint_type = 'FOREIGN KEY';

-- Check indexes
-- SELECT indexname FROM pg_indexes
-- WHERE schemaname = 'assessment_dev';

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================

COMMIT;


