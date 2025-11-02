-- Align form_submissions.user_id type with users.id (string/UUID or numeric)

ALTER TABLE form_submissions MODIFY COLUMN user_id VARCHAR(64) NULL;