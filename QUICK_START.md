# Quick Start Guide - Supabase Setup

## Step 1: Create Supabase Project (5 minutes)

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in
3. Click **New Project**
4. Fill in:
   - Project name: `marketplace-app` (or your preferred name)
   - Database password: (create a strong password and save it)
   - Region: Choose closest to your users
5. Click **Create new project**
6. Wait for setup to complete (~2 minutes)

## Step 2: Get Your Credentials (1 minute)

1. In your Supabase Dashboard, go to **Settings** > **API**
2. You'll see:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **Project API keys** > **anon** **public**: `eyJhbGciOiJIUzI1...`
3. Copy both values

## Step 3: Update Your Flutter App (1 minute)

Open `lib/main.dart` and replace:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Paste your Project URL here
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Paste your anon key here
);
```

**Example:**
```dart
await Supabase.initialize(
  url: 'https://abcdefghij.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWoiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYzNjM4MjIwMCwiZXhwIjoxOTUxOTU4MjAwfQ.xxxxx',
);
```

## Step 4: Set Up Database (2 minutes)

1. In Supabase Dashboard, click **SQL Editor** (left sidebar)
2. Click **New query**
3. Copy the entire contents of `supabase_schema.sql` file
4. Paste it into the SQL editor
5. Click **Run** (or press Ctrl+Enter)
6. You should see "Success. No rows returned"

## Step 5: Set Up Storage (2 minutes)

1. In Supabase Dashboard, click **Storage** (left sidebar)
2. Click **New bucket**
3. Enter bucket name: `profile-pictures`
4. Make it **Public** (toggle the switch)
5. Click **Create bucket**
6. Click on the bucket you just created
7. Click **Policies** tab
8. The policies from `supabase_schema.sql` should already be applied

## Step 6: Configure Authentication (2 minutes)

### Email Authentication (Already enabled by default)
1. Go to **Authentication** > **Providers**
2. Email should already be enabled
3. ✅ Done!

### Google Sign-In (Optional)
1. Go to **Authentication** > **Providers**
2. Find **Google** and click to enable
3. You'll need:
   - Google OAuth Client ID
   - Google OAuth Client Secret
4. Get these from [Google Cloud Console](https://console.cloud.google.com):
   - Create a new project or use existing
   - Enable Google+ API
   - Create OAuth 2.0 credentials
   - Add authorized redirect URI: `https://your-project.supabase.co/auth/v1/callback`
5. Paste credentials in Supabase
6. Click **Save**

## Step 7: Test Your App (5 minutes)

### Run the app:
```bash
flutter run
```

### Test these features:
- ✅ Sign up with email and password
- ✅ Sign in with email and password
- ✅ Upload profile picture
- ✅ Update profile information
- ✅ Password reset (check your email)
- ✅ Sign out

## Troubleshooting

### Error: "Invalid API key"
- ✅ Check that you copied the **anon** key, not the service role key
- ✅ Make sure there are no extra spaces in the URL or key

### Error: "Failed to initialize Supabase"
- ✅ Check your internet connection
- ✅ Verify the Project URL is correct (should start with https://)

### Sign up works but can't see user profile
- ✅ Make sure you ran the SQL schema (`supabase_schema.sql`)
- ✅ Check the RLS policies are enabled

### Profile picture upload fails
- ✅ Verify the `profile-pictures` bucket exists
- ✅ Make sure it's set to **Public**
- ✅ Check storage policies are applied

### Google Sign-In not working
- ✅ Make sure you configured OAuth in Supabase dashboard
- ✅ Check redirect URLs in Google Cloud Console
- ✅ Test with a different Google account

## Next Steps

1. **Add more features** - Check out Supabase documentation for:
   - Real-time subscriptions
   - Database triggers
   - Edge functions

2. **Secure your app** - Review and customize RLS policies

3. **Deploy** - When ready, deploy your Flutter app:
   - Android: `flutter build apk`
   - iOS: `flutter build ios`
   - Web: `flutter build web`

## Useful Resources

- 📚 [Supabase Documentation](https://supabase.com/docs)
- 🎯 [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- 💬 [Supabase Discord Community](https://discord.supabase.com)
- 🐛 [Report Issues](https://github.com/supabase/supabase/issues)

## Need Help?

- Check the detailed migration guide: `SUPABASE_MIGRATION_GUIDE.md`
- Review the SQL schema: `supabase_schema.sql`
- Visit Supabase Discord for community support

---

**Total Setup Time: ~15-20 minutes**

Good luck! 🚀
