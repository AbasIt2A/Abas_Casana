-- Test query to check if listings table has data and foreign key relationship works
-- Run this in Supabase SQL Editor to verify

-- 1. Check if listings table exists and has data
SELECT COUNT(*) as total_listings FROM listings;

-- 2. Check all listings with user info
SELECT 
  l.id,
  l.title,
  l.user_id,
  l.status,
  l.created_at,
  u.full_name,
  u.profile_pic_url
FROM listings l
LEFT JOIN users u ON l.user_id = u.id
ORDER BY l.created_at DESC;

-- 3. Check foreign key constraints on listings table
SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
  JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
  JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'listings';

-- 4. Check RLS policies on listings table
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'listings';
