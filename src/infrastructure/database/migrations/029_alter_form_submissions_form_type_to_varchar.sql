-- Make form_submissions.form_type flexible to support new sub-types
-- Safe to run multiple times (re-applying same definition is a no-op in practice)

ALTER TABLE form_submissions
MODIFY COLUMN form_type VARCHAR(32) NOT NULL;