# 🎯 Supabase Setup Checklist

Use this checklist to ensure you've completed all setup steps correctly.

## Phase 1: Supabase Account Setup
- [ ] Created account at https://supabase.com
- [ ] Created new project
- [ ] Saved database password securely
- [ ] Project is fully initialized (no loading spinner)

## Phase 2: Get Credentials
- [ ] Navigated to Settings > API in Supabase Dashboard
- [ ] Copied Project URL (starts with https://)
- [ ] Copied anon (public) key (starts with eyJ)
- [ ] Did NOT copy service role key (that's for server-side only)

## Phase 3: Update Flutter Code
- [ ] Opened `lib/main.dart`
- [ ] Replaced `YOUR_SUPABASE_URL` with actual URL
- [ ] Replaced `YOUR_SUPABASE_ANON_KEY` with actual anon key
- [ ] Saved the file
- [ ] Ran `flutter pub get` (should complete without errors)

## Phase 4: Database Setup
- [ ] Opened Supabase Dashboard > SQL Editor
- [ ] Created new query
- [ ] Copied entire `supabase_schema.sql` content
- [ ] Pasted and ran the SQL
- [ ] Saw "Success. No rows returned" message
- [ ] Verified `users` table exists in Table Editor

## Phase 5: Storage Setup
- [ ] Opened Storage in Supabase Dashboard
- [ ] Created bucket named `profile-pictures`
- [ ] Made bucket Public
- [ ] Verified bucket appears in storage list
- [ ] Storage policies are automatically applied from SQL

## Phase 6: Authentication Configuration
- [ ] Email auth is enabled (default - check Authentication > Providers)
- [ ] Email confirmations are enabled (optional, in Authentication settings)
- [ ] (Optional) Google OAuth configured if needed

## Phase 7: Clean Up Old Firebase Files
- [ ] Deleted `android/app/google-services.json` (if exists)
- [ ] Deleted `ios/Runner/GoogleService-Info.plist` (if exists)
- [ ] Deleted `lib/firebase_options.dart` (already done)
- [ ] (Optional) Deleted `firebase.json` if not using Firebase hosting

## Phase 8: Test Your Application

### Build & Run
- [ ] Ran `flutter clean`
- [ ] Ran `flutter pub get`
- [ ] Ran `flutter run`
- [ ] App starts without errors

### Test Sign Up
- [ ] Opened app
- [ ] Clicked "Sign up"
- [ ] Filled in all fields (name, email, password, phone)
- [ ] Selected profile picture
- [ ] Clicked "Create Account"
- [ ] Received success message
- [ ] Redirected to login screen

### Test Sign In
- [ ] Entered email and password
- [ ] Clicked "Sign In"
- [ ] Successfully logged in
- [ ] Reached home screen

### Test Profile
- [ ] Navigated to profile screen
- [ ] Saw user information
- [ ] Clicked edit profile
- [ ] Changed name or phone
- [ ] Uploaded new profile picture
- [ ] Clicked Save
- [ ] Changes saved successfully

### Test Password Reset
- [ ] Went to login screen
- [ ] Clicked "Forgot password?"
- [ ] Entered email
- [ ] Clicked "Send Reset Link"
- [ ] Received email (check spam if not in inbox)
- [ ] Clicked link in email
- [ ] Reset password successfully

### Test Sign Out
- [ ] Clicked logout from profile
- [ ] Confirmed logout
- [ ] Returned to login screen
- [ ] Cannot access protected screens

## Phase 9: Verify in Supabase Dashboard

### Check Users Table
- [ ] Opened Table Editor > users
- [ ] Can see your test user
- [ ] All fields populated correctly
- [ ] Timestamps are set

### Check Auth Users
- [ ] Opened Authentication > Users
- [ ] See your test user listed
- [ ] Email is verified (if you confirmed)

### Check Storage
- [ ] Opened Storage > profile-pictures
- [ ] See your uploaded profile pictures
- [ ] Can view/download images

## Phase 10: Final Verification
- [ ] No compilation errors
- [ ] No runtime errors
- [ ] All features working as expected
- [ ] App performance is good
- [ ] Ready for development/deployment

## 📋 Troubleshooting Checklist

If something doesn't work:

### Error: "Invalid API key"
- [ ] Verified copied the **anon** key (not service role)
- [ ] No extra spaces in URL or key
- [ ] Key in single quotes in main.dart

### Error: "Table 'users' does not exist"
- [ ] Ran the SQL schema in Supabase
- [ ] Refreshed Table Editor
- [ ] No SQL errors when running schema

### Error: "Insert violates row-level security"
- [ ] RLS policies created from SQL schema
- [ ] Ran all policy creation statements
- [ ] User is authenticated when inserting

### Profile Picture Upload Fails
- [ ] Bucket `profile-pictures` exists
- [ ] Bucket is set to Public
- [ ] Storage policies applied
- [ ] User is authenticated

### Google Sign-In Not Working
- [ ] OAuth configured in Supabase
- [ ] Client ID and Secret added
- [ ] Redirect URLs match
- [ ] Tested with different Google account

## ✅ Success Criteria

Your migration is complete when:
- ✅ App builds without errors
- ✅ Users can sign up
- ✅ Users can sign in
- ✅ Users can update profile
- ✅ Profile pictures upload correctly
- ✅ Password reset works
- ✅ Sign out works
- ✅ Data persists in Supabase

## 🎉 All Done?

If you've checked everything above, congratulations! Your app is now running on Supabase.

**Next Steps:**
1. Start building new features
2. Add more database tables as needed
3. Explore Supabase real-time features
4. Set up CI/CD for deployment
5. Monitor usage in Supabase Dashboard

**Questions?**
- Review `SUPABASE_MIGRATION_GUIDE.md` for details
- Check Supabase documentation
- Join Supabase Discord community

---

*Keep this checklist for future projects or team onboarding!*
