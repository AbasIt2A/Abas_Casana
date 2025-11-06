-- Run this query in Supabase SQL Editor to check your profile picture URL

-- 1. Check what's stored in your user profile
SELECT 
    id,
    full_name,
    email,
    profile_pic_url,
    created_at,
    updated_at
FROM users
ORDER BY updated_at DESC
LIMIT 5;

-- 2. Check if there are any files in the profile-pictures bucket
SELECT 
    name,
    bucket_id,
    owner,
    created_at,
    updated_at,
    last_accessed_at,
    metadata
FROM storage.objects
WHERE bucket_id = 'profile-pictures'
ORDER BY created_at DESC;

-- 3. Check the public URL format (replace USER_ID with your actual user ID)
-- The URL should look like:
-- https://YOUR_PROJECT.supabase.co/storage/v1/object/public/profile-pictures/USER_ID.jpg

-- 4. Verify RLS policies are active
SELECT 
    policyname,
    cmd,
    roles,
    qual
FROM pg_policies
WHERE tablename = 'objects'
AND schemaname = 'storage'
AND (qual LIKE '%profile-pictures%' OR policyname LIKE '%profile%');
