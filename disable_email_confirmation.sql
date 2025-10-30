-- Disable email confirmation for easier development
-- Run this in Supabase SQL Editor

-- This allows users to sign up and immediately log in without email confirmation
-- Note: Re-enable this in production for security

-- For new signups, you need to update Auth settings in the Dashboard:
-- Go to Authentication > Settings > Email Auth
-- Disable "Enable email confirmations"

-- To manually confirm existing users, run:
-- UPDATE auth.users SET email_confirmed_at = NOW() WHERE email_confirmed_at IS NULL;
