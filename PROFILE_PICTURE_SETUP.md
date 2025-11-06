# Profile Picture Setup Guide

## Overview
This guide will help you set up the Supabase Storage bucket for profile pictures and troubleshoot display issues.

## Required Setup in Supabase Dashboard

### 1. Create Storage Bucket (Already Done ✓)

You've already created the `profile-pictures` bucket. Now we need to configure it properly:

1. Go to your Supabase project dashboard
2. Navigate to **Storage** in the left sidebar
3. Click on the **`profile-pictures`** bucket
4. Make sure it's set to **Public** (toggle should be ON)

### 2. Set Storage Policies for profile-pictures Bucket

Run these SQL commands in your Supabase SQL Editor:

**Policy for INSERT (Upload):**
```sql
CREATE POLICY "Authenticated users can upload profile pictures"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'profile-pictures');
```

**Policy for SELECT (View):**
```sql
CREATE POLICY "Anyone can view profile pictures"
ON storage.objects FOR SELECT
TO anon, authenticated
USING (bucket_id = 'profile-pictures');
```

**Policy for UPDATE:**
```sql
CREATE POLICY "Users can update their profile pictures"  
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'profile-pictures');
```

**Policy for DELETE:**
```sql
CREATE POLICY "Users can delete their profile pictures"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'profile-pictures');
```

### 3. Verify Policies Are Active

Run this query to check if your policies exist:

```sql
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage'
AND (qual LIKE '%profile-pictures%' OR policyname LIKE '%profile%');
```

## Testing the Setup

### Step 1: Test Manual Upload in Supabase

1. Go to **Storage** → **`profile-pictures`** bucket
2. Click **Upload file**
3. Upload any test image (e.g., `test.jpg`)
4. If successful, you should see the file appear in the bucket
5. Click on the file to get the public URL
6. Copy the URL and paste it in a browser - you should see the image

**If manual upload fails:** Your bucket policies are not correct. Re-run the policy SQL commands above.

### Step 2: Test in Your App

1. Run your Flutter app: `flutter run`
2. Navigate to Profile → Edit Profile
3. Tap the camera icon
4. Choose Camera or Gallery
5. Select an image
6. Tap **Save**
7. Check the console output for upload logs

### Step 3: Verify the Upload Succeeded

In the console, look for these messages:
```
Uploading profile picture: {userId}.jpg
Image path: /path/to/image
File size: 123456 bytes
Upload response: ...
Successfully uploaded: {userId}.jpg
Public URL: https://...supabase.co/storage/v1/object/public/profile-pictures/{userId}.jpg
```

**If you see errors:** Continue to troubleshooting section below.

### Step 4: Check Database Update

Run this SQL query in Supabase to verify the URL was saved:

```sql
SELECT id, full_name, profile_pic_url 
FROM users 
WHERE id = 'YOUR_USER_ID_HERE';
```

The `profile_pic_url` should contain the full Supabase Storage URL.

### Step 5: Verify Image Display

1. Go back to Profile screen - you should see your uploaded image
2. Go to Home screen - check the AppBar top-right - your profile picture should appear
3. If you see initials instead of the image, there's a display issue

## Troubleshooting

### Issue 1: Image Uploads But Doesn't Display

**Symptoms:** You can upload an image, but you see your initials instead.

**Possible Causes:**

1. **Check the saved URL in database:**
   ```sql
   SELECT profile_pic_url FROM users WHERE id = 'YOUR_USER_ID';
   ```
   
   The URL should look like:
   ```
   https://YOUR_PROJECT.supabase.co/storage/v1/object/public/profile-pictures/USER_ID.jpg
   ```

2. **Check if URL is accessible:**
   - Copy the URL from the database
   - Paste it in a browser
   - If you get a 404 error or "Not found", the file wasn't uploaded successfully
   - If you see the image, continue to next step

3. **Check ProfileAvatar widget:**
   - The widget uses `Image.network()` to load URLs
   - Open Flutter DevTools and check for network errors
   - Look for CORS issues or network failures

4. **Hot Reload Issue:**
   - After uploading, the profile data might be cached
   - Try hot restart (not just hot reload): Press `Shift + R` in terminal
   - Or fully restart the app

5. **Check Console for Image Loading Errors:**
   Run the app and watch for these errors:
   ```
   [ERROR:flutter/runtime/dart_vm_initializer.cc] Image loading failed
   ```

### Issue 2: "Failed to Upload Images" Error

**Check these in order:**

1. **Verify Bucket Name Exactly:**
   - Go to Supabase → Storage
   - Confirm bucket is named: `profile-pictures` (with hyphen, plural)
   - In the code, it's also `profile-pictures`

2. **Check Public Access:**
   - Click on the `profile-pictures` bucket
   - Verify "Public bucket" toggle is **ON**

3. **Verify All 4 RLS Policies Exist:**
   ```sql
   SELECT policyname, cmd 
   FROM pg_policies 
   WHERE tablename = 'objects' 
   AND qual LIKE '%profile-pictures%';
   ```
   
   You should see 4 policies: INSERT, SELECT, UPDATE, DELETE

4. **Check User Authentication:**
   - Make sure you're logged in
   - Verify token is valid in Supabase Auth dashboard

5. **Check File Exists Before Upload:**
   Console should show: `File size: XXXX bytes`
   If it shows `File does not exist`, the image picker didn't work correctly

### Issue 3: Profile Picture Works in Profile Screen But Not Home Screen

**Cause:** The home screen needs to load user profile data.

**Solution:** Already implemented! The home screen now:
- Loads user profile in `_loadUserProfile()`
- Displays ProfileAvatar in AppBar
- Automatically refreshes when navigating back from Profile

**If still not working:**
1. Add this to `home_screen.dart` in `initState`:
   ```dart
   @override
   void initState() {
     super.initState();
     _loadUserProfile(); // Make sure this is called
   }
   ```

2. Or refresh on resume by adding:
   ```dart
   @override
   void didChangeDependencies() {
     super.didChangeDependencies();
     _loadUserProfile();
   }
   ```

### Issue 4: Image Shows Briefly Then Disappears

**Cause:** Network image loading issue or URL becomes invalid.

**Solutions:**

1. **Add image caching:** Install `cached_network_image` package:
   ```yaml
   dependencies:
     cached_network_image: ^3.3.0
   ```

2. **Replace Image.network() in ProfileAvatar widget:**
   ```dart
   CachedNetworkImage(
     imageUrl: imageUrl,
     fit: BoxFit.cover,
     placeholder: (context, url) => CircularProgressIndicator(),
     errorWidget: (context, url, error) => _buildInitials(),
   )
   ```

### Issue 5: "Unsupported operation: _Namespace" Error

**This should now be fixed!** 

The code now uses:
```dart
final bytes = await imageFile.readAsBytes();
await _supabase.storage.from('profile-pictures').uploadBinary(filePath, bytes, ...);
```

Instead of:
```dart
await _supabase.storage.from('profile-pictures').upload(filePath, imageFile, ...);
```

## Quick Debugging Checklist

Run through this checklist:

- [ ] Bucket named `profile-pictures` exists in Supabase Storage
- [ ] Bucket is set to Public (toggle ON)
- [ ] All 4 RLS policies created (INSERT, SELECT, UPDATE, DELETE)
- [ ] Manual upload test in Supabase dashboard works
- [ ] Console shows "Successfully uploaded: {userId}.jpg"
- [ ] Console shows "Public URL: https://..."
- [ ] Database has the URL in `profile_pic_url` column
- [ ] URL opens in browser and shows the image
- [ ] App restarted (not just hot reload) after upload
- [ ] ProfileAvatar widget imported in screens

## Code Structure

### Upload Flow:
1. User taps camera icon in Edit Profile
2. Image picker shows Camera/Gallery dialog
3. User selects image → stored in `_newProfileImage`
4. User taps Save
5. `_updateProfile()` called
6. `uploadProfilePicture()` uploads bytes to Supabase
7. Returns public URL
8. `updateUserProfile()` saves URL to database
9. Profile screen refreshes and shows image

### Display Flow:
1. Screen loads → calls `_loadUserProfile()`
2. Fetches user data from database
3. Passes `profile_pic_url` to ProfileAvatar widget
4. ProfileAvatar checks if URL exists
5. If yes → shows Image.network() with loading indicator
6. If no → shows user initials

## Advanced: Check Network Requests

If images still don't display, check network requests:

1. Run app with verbose logging:
   ```bash
   flutter run -v
   ```

2. Look for HTTP requests to Supabase Storage:
   ```
   GET https://{project}.supabase.co/storage/v1/object/public/profile-pictures/{userId}.jpg
   ```

3. Check response codes:
   - **200 OK** - Image loaded successfully
   - **404 Not Found** - File doesn't exist in storage
   - **403 Forbidden** - RLS policy issue
   - **401 Unauthorized** - Authentication issue

## Notes

- Images are stored as: `{userId}.jpg` in bucket root
- The `upsert: true` option allows updating existing profile pictures
- Content type is set to `image/jpeg` for compatibility
- Maximum file size depends on your Supabase plan (default: 50MB)
- Consider adding image compression for better performance

## Still Having Issues?

If you've followed all steps and it still doesn't work:

1. **Check Flutter Console Output:**
   - Run `flutter run` in terminal
   - Look for any error messages when uploading or loading images

2. **Check Supabase Logs:**
   - Go to Supabase Dashboard → Logs
   - Filter by "storage" or "error"
   - Look for failed requests or policy violations

3. **Verify Your Setup:**
   - Take a screenshot of your Storage bucket settings
   - Take a screenshot of your policies in SQL Editor
   - Check the URL format in your database

4. **Test with a Fresh User:**
   - Create a new account
   - Try uploading a profile picture
   - Sometimes old data can cause caching issues
