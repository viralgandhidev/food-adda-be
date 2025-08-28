-- Add new columns to users table
ALTER TABLE users
ADD COLUMN company_name VARCHAR(255) AFTER address,
ADD COLUMN company_description TEXT AFTER company_name;

-- Add index for better performance
CREATE INDEX idx_users_company_name ON users (company_name);