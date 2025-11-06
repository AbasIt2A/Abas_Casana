-- SQL to identify and remove duplicate listings
-- Run this in Supabase SQL Editor

-- Step 1: Check for duplicate listings (same title, user_id, created_at date)
SELECT 
    title,
    user_id,
    DATE(created_at) as post_date,
    COUNT(*) as duplicate_count,
    ARRAY_AGG(id ORDER BY created_at) as listing_ids
FROM listings
GROUP BY title, user_id, DATE(created_at)
HAVING COUNT(*) > 1
ORDER BY created_at DESC;

-- Step 2: Delete duplicates (keeps the first one, deletes the rest)
-- IMPORTANT: Review the results from Step 1 before running this!

WITH duplicates AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY title, user_id, DATE(created_at) 
            ORDER BY created_at ASC
        ) as rn
    FROM listings
)
DELETE FROM listings
WHERE id IN (
    SELECT id 
    FROM duplicates 
    WHERE rn > 1
);

-- Step 3: Verify duplicates are removed
SELECT 
    title,
    user_id,
    DATE(created_at) as post_date,
    COUNT(*) as count
FROM listings
GROUP BY title, user_id, DATE(created_at)
HAVING COUNT(*) > 1;

-- If Step 3 returns no rows, all duplicates have been successfully removed!
