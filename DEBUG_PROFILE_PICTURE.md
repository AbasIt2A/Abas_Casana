# DEBUG GUIDE: Profile Picture Not Showing

## What I've Added

I've added extensive debug logging throughout the code to help identify where the issue is. Here's what to do:

## Step-by-Step Debugging Process

### Step 1: Run the App with Console Visible

```powershell
flutter run
```

When prompted, choose your device (probably Windows for testing).

### Step 2: Try Uploading a Profile Picture

1. Navigate to Profile → Edit Profile
2. Tap the camera icon
3. Select an image from Gallery
4. Tap Save

### Step 3: Watch the Console Output

You should see this sequence of debug messages. **Copy all of them and share with me:**

```
=== UPLOADING PROFILE PICTURE ===
User ID: [your-user-id]
Image path: [path-to-image]
Uploading profile picture: [userid].jpg
Image path: [path]
File size: [number] bytes
Upload response: [response]
Successfully uploaded: [filename]
Public URL: [url]
Upload result: [url]
SUCCESS: Got URL: [url]
=== UPDATING USER PROFILE ===
Final image URL to save: [url]
Profile update completed successfully!
```

### Step 4: Check for Errors

**If you see any of these errors, let me know which one:**

❌ **"ERROR: File does not exist"**
- The image picker didn't save the file properly
- Issue with file permissions

❌ **"Error uploading profile picture"**
- Network issue or Supabase Storage problem
- Check if bucket policies are correct

❌ **"Upload result: null"**
- Upload failed silently
- Check Supabase Storage bucket settings

❌ **"ERROR: Upload returned null!"**
- The upload method returned null
- Could be authentication or permission issue

### Step 5: Go Back to Profile Screen

After saving, you should see:
```
=== RETURNED FROM EDIT PROFILE - RELOADING ===
=== PROFILE SCREEN: Loading user profile ===
Profile data: [user data]
Profile pic URL from profile: [url]
Profile screen state updated
```

### Step 6: Check ProfileAvatar Widget

You should see one of these:

✅ **Success:**
```
ProfileAvatar: Loading image from URL: [url]
ProfileAvatar: Image loaded successfully!
```

❌ **No URL:**
```
ProfileAvatar: No image URL, showing initials for: [name]
```

❌ **Loading Error:**
```
ProfileAvatar: Loading image from URL: [url]
ProfileAvatar: Error loading image: [error]
```

### Step 7: Check Home Screen

Navigate to Home screen. You should see:
```
=== HOME SCREEN: Loading user profile ===
Profile data: [user data]
Profile pic URL: [url]
Home screen profile state updated
ProfileAvatar: Loading image from URL: [url]
ProfileAvatar: Image loaded successfully!
```

## Common Issues and What Console Shows

### Issue 1: Upload Fails - No URL Saved
**Console shows:**
```
Upload result: null
ERROR: Upload returned null!
Final image URL to save: null
```

**Fix:** Check Supabase authentication and bucket policies

### Issue 2: URL Saved But Image Not Loading
**Console shows:**
```
SUCCESS: Got URL: https://...
Profile pic URL from profile: https://...
ProfileAvatar: Loading image from URL: https://...
ProfileAvatar: Error loading image: [error]
```

**Fix:** The URL might be wrong or inaccessible. Copy the URL and try opening it in a browser.

### Issue 3: Profile Not Reloading
**Console shows:**
```
SUCCESS: Got URL: https://...
[but no "=== PROFILE SCREEN: Loading user profile ===" message]
```

**Fix:** Hot restart the app (Shift + R in terminal)

### Issue 4: URL Not Being Retrieved
**Console shows:**
```
Profile pic URL from profile: null
ProfileAvatar: No image URL, showing initials
```

**Fix:** The URL wasn't saved to database. Run the SQL check below.

## SQL Checks to Run

Open Supabase SQL Editor and run these queries:

### Query 1: Check Your Profile Data
```sql
SELECT id, full_name, profile_pic_url, updated_at 
FROM users 
ORDER BY updated_at DESC 
LIMIT 1;
```

**Expected Result:**
- `profile_pic_url` should contain: `https://[project].supabase.co/storage/v1/object/public/profile-pictures/[user-id].jpg`

**If profile_pic_url is NULL:** The update didn't save to database

### Query 2: Check Storage Files
```sql
SELECT name, created_at, metadata
FROM storage.objects
WHERE bucket_id = 'profile-pictures'
ORDER BY created_at DESC;
```

**Expected Result:**
- You should see a file named `[your-user-id].jpg`
- Created timestamp should match when you uploaded

**If no files:** Upload didn't reach storage

### Query 3: Test if URL is Accessible
Copy the `profile_pic_url` from Query 1 and:
1. Paste it in a browser
2. You should see your profile picture
3. If you get 404 or error, the file isn't accessible

## What to Share With Me

Please copy and share:

1. **All console output** from Step 2 & 3 (from "=== UPLOADING" to "Profile update completed")

2. **Results from SQL Query 1** - especially the `profile_pic_url` value

3. **Results from SQL Query 2** - the list of files in storage

4. **Any error messages** you see in red in the console

5. **What you see in the UI:**
   - Edit Profile: Do you see the selected image before saving?
   - Profile Screen: Do you see initials or image?
   - Home Screen: Do you see initials or image in top-right?

## Quick Test

If you want to test if the URL works:

1. Manually upload a test image in Supabase Storage → profile-pictures bucket
2. Name it: `[your-user-id].jpg` (replace with actual ID)
3. Copy the public URL
4. Run this SQL to manually set it:
```sql
UPDATE users 
SET profile_pic_url = 'PASTE_URL_HERE',
    updated_at = NOW()
WHERE id = 'YOUR_USER_ID';
```
5. Hot restart app
6. Check if image shows now

If manual URL works but upload doesn't, the issue is in the upload code.
If manual URL also doesn't work, the issue is with URL format or bucket settings.
