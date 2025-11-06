# Supabase Storage Setup for Listing Images

## Issue Fixed
Previously, when User A posted an item with images, the images were stored as local file paths (e.g., `/data/user/0/.../image.jpg`) which were not accessible to other users. This caused the "image not supported" icon to appear for other users.

## Solution
Images are now uploaded to Supabase Storage and the public URLs are stored in the database, making them accessible to all users.

## Required Setup in Supabase Dashboard

### 1. Create Storage Bucket

1. Go to your Supabase project dashboard
2. Navigate to **Storage** in the left sidebar
3. Click **"New bucket"**
4. Enter bucket name: `listings-images`
5. **IMPORTANT**: Set bucket as **Public** (so images can be viewed by all users)
6. Click **"Create bucket"**

### 2. Verify Bucket Settings

After creating the bucket:

1. Click on the `listings-images` bucket
2. Go to **Policies** tab
3. Make sure "Public bucket" toggle is **ON**
4. If not, toggle it on

### 3. Set Storage Policies

Even with a public bucket, you need these RLS policies:

**Policy for INSERT (Upload):**
```sql
CREATE POLICY "Authenticated users can upload listing images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'listings-images');
```

**Policy for SELECT (View):**
```sql
CREATE POLICY "Anyone can view listing images"
ON storage.objects FOR SELECT
TO anon, authenticated
USING (bucket_id = 'listings-images');
```

**Policy for UPDATE:**
```sql
CREATE POLICY "Users can update their listing images"  
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'listings-images');
```

**Policy for DELETE:**
```sql
CREATE POLICY "Users can delete their own listing images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'listings-images');
```

### 4. Test Upload in Supabase Dashboard

Before testing in the app:
1. Go to Storage → `listings-images` bucket
2. Try manually uploading a test image
3. If it fails, check your policies again
4. Make sure the bucket is set to Public

If you already have a `profile-pictures` bucket, the `listings-images` bucket should follow the same pattern.

## Testing

After setting up the storage bucket:

1. User A should post a new item with photos
2. The images will be uploaded to Supabase Storage
3. User B should be able to see the images in:
   - Home screen (Featured Items)
   - Browse screen
   - Item Details screen

## Troubleshooting

### Error: "Failed to upload images"

**Check these in order:**

1. **Verify Bucket Name**
   - Go to Supabase → Storage
   - Confirm bucket is named exactly: `listings-images` (with hyphen, not underscore)
   
2. **Check Public Access**
   - Click on the bucket
   - Verify "Public bucket" toggle is ON
   
3. **Verify RLS Policies**
   - Go to SQL Editor
   - Run this to check existing policies:
   ```sql
   SELECT * FROM pg_policies 
   WHERE tablename = 'objects' 
   AND schemaname = 'storage';
   ```
   
4. **Test Manual Upload**
   - Go to Storage → `listings-images`
   - Try uploading a file manually
   - If this fails, the issue is with Supabase settings
   
5. **Check Console Logs**
   - Run `flutter run` from terminal
   - Try posting an item
   - Look for detailed error messages in console
   
6. **Verify Storage is Enabled**
   - In Supabase dashboard, check if Storage is active
   - Some plans might have storage limits

### Common Issues

**Issue: "Row Level Security policy violation"**
- Solution: Make sure all 4 policies (INSERT, SELECT, UPDATE, DELETE) are created
- Or: Set bucket to Public and add policies for `anon` and `authenticated` roles

**Issue: "Bucket not found"**
- Solution: Double-check bucket name is `listings-images` (not `listing-images` or `listings_images`)

**Issue: Images upload but can't be viewed**
- Solution: Check the SELECT policy allows `anon` role access
- Or: Ensure bucket is set to Public

**Issue: "Permission denied"**
- Solution: User must be authenticated (logged in) to upload
- Check JWT token is valid in Supabase auth dashboard

## Code Changes Made

### 1. `database_service.dart`
- Added `uploadListingImages()` method to upload multiple images to Supabase Storage
- Returns list of public URLs for the uploaded images

### 2. `post_item_screen.dart`
- Now uploads images to Supabase before creating listing
- Stores image URLs instead of local file paths
- Shows loading indicator while posting
- Handles upload errors gracefully

### 3. Image Display Fixed
- All screens now check if image is URL (http/https) or local asset
- Network images use `Image.network()` with loading indicators
- Local assets still work for backward compatibility

## Migration for Existing Listings

If you have existing listings with local file paths in the database:

1. Those images cannot be recovered (local paths are not accessible)
2. Users should re-post those items with new photos
3. Or run a cleanup script to remove listings with local file paths:

```sql
-- Remove listings with local file paths (optional)
UPDATE listings 
SET image_urls = '[]' 
WHERE image_urls::text LIKE '%/data/%' 
   OR image_urls::text LIKE '%/storage/%'
   OR image_urls::text LIKE '%C:\\%';
```

## Notes

- Images are stored with naming pattern: `{listingId}_{index}.jpg`
- Maximum file size depends on your Supabase plan
- Consider adding image compression for better performance
- The `listings-images` bucket name must match in both code and Supabase dashboard
