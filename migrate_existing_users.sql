-- Migrate existing auth users to the users table
-- This creates user profile records for users who signed up before the users table existed

-- Insert existing auth users into the users table
-- Extract name from email if full_name is not available
INSERT INTO users (id, full_name, email, phone_number, profile_pic_url, created_at, updated_at)
SELECT 
  id,
  COALESCE(
    raw_user_meta_data->>'full_name',
    SPLIT_PART(email, '@', 1)  -- Use email username as fallback
  ) as full_name,
  email,
  raw_user_meta_data->>'phone_number' as phone_number,
  raw_user_meta_data->>'profile_pic_url' as profile_pic_url,
  created_at,
  updated_at
FROM auth.users
WHERE id NOT IN (SELECT id FROM users)  -- Only insert users that don't exist yet
ON CONFLICT (id) DO NOTHING;

-- Verify the migration
SELECT 
  u.id,
  u.email,
  p.full_name,
  p.phone_number,
  p.created_at
FROM auth.users u
LEFT JOIN users p ON u.id = p.id
ORDER BY u.created_at DESC;
