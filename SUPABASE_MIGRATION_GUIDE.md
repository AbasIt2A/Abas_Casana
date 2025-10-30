# Firebase to Supabase Migration Guide

## Migration Complete ✅

Your Flutter application has been successfully migrated from Firebase to Supabase.

## What Changed

### 1. Dependencies (pubspec.yaml)
**Removed:**
- `firebase_core: ^2.24.0`
- `firebase_auth: ^4.15.0`
- `google_sign_in: ^6.1.6`
- `cloud_firestore: ^4.13.3`
- `firebase_storage: ^11.5.3`

**Added:**
- `supabase_flutter: ^2.5.0`
- `supabase: ^2.1.0`

### 2. Files Modified

#### main.dart
- Removed Firebase initialization
- Added Supabase initialization
- Updated AuthWrapper to use Supabase `AuthState`
- **Action Required:** Replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` with your actual Supabase credentials

#### services/auth_services.dart
- Migrated from `FirebaseAuth` to `SupabaseClient`
- Updated authentication methods:
  - `signUpWithEmailAndPassword()` - Returns `AuthResponse` instead of `UserCredential`
  - `signInWithEmailAndPassword()` - Returns `AuthResponse` instead of `UserCredential`
  - `signInWithGoogle()` - Uses Supabase OAuth provider
  - `sendPasswordResetEmail()` - Uses `resetPasswordForEmail()`
  - User properties: `uid` → `id`, `emailVerified` → `emailConfirmedAt`
- Changed exception handling from `FirebaseAuthException` to `AuthException`

#### services/database_service.dart
- Migrated from `FirebaseFirestore` to Supabase Database (PostgreSQL)
- Changed from Firestore collections to SQL tables
- Updated field names (camelCase → snake_case):
  - `fullName` → `full_name`
  - `phoneNumber` → `phone_number`
  - `profilePicUrl` → `profile_pic_url`
- Migrated from Firebase Storage to Supabase Storage
- Updated storage bucket name to `profile-pictures`

#### screens/signup_screen.dart
- Updated imports from Firebase to Supabase
- Changed `UserCredential` to `AuthResponse`
- Updated exception handling to `AuthException`
- Updated user ID access: `user.uid` → `user.id`

#### screens/login_screen.dart
- Updated imports to use Supabase
- Changed exception handling from `FirebaseAuthException` to `AuthException`

#### screens/edit_profile_screen.dart
- Updated database field names to snake_case format
- Changed user ID access: `user.uid` → `user.id`

## Setup Required

### 1. Create Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Create a new project
3. Note your Project URL and Anon Key

### 2. Update main.dart
Replace the placeholders in `lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Replace with your Supabase URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your Supabase anon key
);
```

### 3. Create Database Tables

Run this SQL in your Supabase SQL Editor:

```sql
-- Create users table
CREATE TABLE users (
  id UUID REFERENCES auth.users PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone_number TEXT,
  profile_pic_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### 4. Create Storage Bucket

1. In Supabase Dashboard, go to Storage
2. Create a new bucket called `profile-pictures`
3. Set it to **Public** bucket
4. Add this policy:

```sql
-- Allow authenticated users to upload their own profile pictures
CREATE POLICY "Users can upload their own profile picture"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-pictures' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Allow users to update their own profile pictures
CREATE POLICY "Users can update their own profile picture"
  ON storage.objects FOR UPDATE
  WITH CHECK (
    bucket_id = 'profile-pictures' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Allow anyone to view profile pictures (public bucket)
CREATE POLICY "Anyone can view profile pictures"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-pictures');
```

### 5. Configure Google Sign-In (Optional)

1. In Supabase Dashboard, go to Authentication > Providers
2. Enable Google provider
3. Add your OAuth credentials from Google Cloud Console
4. Add authorized redirect URI: `https://your-project-ref.supabase.co/auth/v1/callback`

### 6. Email Authentication Settings

1. In Supabase Dashboard, go to Authentication > Email
2. Enable Email provider
3. Configure email templates if needed
4. Set up email confirmation (enabled by default)

## Key Differences Between Firebase and Supabase

| Feature | Firebase | Supabase |
|---------|----------|----------|
| Database | NoSQL (Firestore) | PostgreSQL (SQL) |
| Auth | Firebase Auth | Supabase Auth (GoTrue) |
| Storage | Firebase Storage | Supabase Storage |
| User ID | `uid` | `id` |
| Field Format | camelCase | snake_case |
| Auth Exception | `FirebaseAuthException` | `AuthException` |
| Auth Response | `UserCredential` | `AuthResponse` |
| Email Verified | `emailVerified` | `emailConfirmedAt` |

## Testing Checklist

- [ ] Sign up with email and password
- [ ] Sign in with email and password
- [ ] Sign in with Google (if configured)
- [ ] Password reset functionality
- [ ] Profile picture upload
- [ ] Update profile information
- [ ] Email verification
- [ ] Sign out

## Additional Notes

1. **Data Migration:** You'll need to migrate existing user data from Firebase to Supabase manually if you have existing users.

2. **Google Sign-In:** The OAuth flow in Supabase works differently. Make sure to test it thoroughly after configuration.

3. **Row Level Security:** Supabase uses PostgreSQL RLS policies for security. The policies above are basic - adjust them based on your needs.

4. **Real-time Features:** If you were using Firestore real-time listeners, you can use Supabase real-time subscriptions.

5. **Firebase Options:** The `firebase_options.dart` file is no longer needed and will show errors. You can delete it:
   ```bash
   del lib\firebase_options.dart
   ```

6. **Android/iOS Configuration:** Remove Firebase configuration files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

## Troubleshooting

### Issue: "Target of URI doesn't exist: 'package:supabase_flutter/supabase_flutter.dart'"
**Solution:** Run `flutter pub get`

### Issue: User sign-up not working
**Solution:** Check that your database table is created and RLS policies are set correctly

### Issue: Profile picture upload fails
**Solution:** Verify that the `profile-pictures` bucket exists and has correct policies

### Issue: Google Sign-In not working
**Solution:** Make sure OAuth is configured in Supabase dashboard and redirect URLs are set

## Support

For Supabase documentation:
- https://supabase.com/docs
- https://supabase.com/docs/reference/dart/introduction

For Flutter Supabase package:
- https://pub.dev/packages/supabase_flutter
