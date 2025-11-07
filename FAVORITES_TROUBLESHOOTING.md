# Favorites/Saved Items Troubleshooting Guide

## Issue Fixed
The SavedItemsScreen was not initializing the ListingsService, so it couldn't load favorites from the Supabase database.

## Changes Made

### 1. `saved_items_screen.dart`
- Added `await _listingsService.initialize()` in `_loadSavedItems()` method
- Added debug logging to track favorites loading

## How to Test the Fix

### Step 1: Verify Supabase Table
1. Go to Supabase Dashboard → **Table Editor**
2. Check if `favorites` table exists
3. If not, run `verify_favorites_table.sql` in SQL Editor

### Step 2: Test the Favorites Flow
1. **Run your app**
2. **Browse marketplace** (Browse or Category screens)
3. **Heart an item** - tap the heart icon on any item
4. **Check console logs** - you should see:
   ```
   Favorite added/removed for item: [item_id]
   ```
5. **Navigate to Profile → Saved Items**
6. **Check console logs** - you should see:
   ```
   DEBUG: Total favorites in service: [number]
   DEBUG: Favorite IDs: {[list of IDs]}
   DEBUG: Total marketplace listings: [number]
   DEBUG: Filtered saved items: [number]
   ```
7. **Verify the hearted item appears** in the Saved Items screen

### Step 3: Verify Database
1. Go to Supabase Dashboard → **Table Editor**
2. Open `favorites` table
3. You should see records with:
   - `user_id`: Your user ID
   - `item_id`: The listing ID you favorited
   - `item_type`: 'listing', 'featured', or 'sample'
   - `created_at`: Timestamp

## Common Issues and Solutions

### Issue 1: Table doesn't exist
**Symptom**: Console shows errors like "relation 'favorites' does not exist"

**Solution**: Run the SQL script:
```bash
# In Supabase SQL Editor, run:
verify_favorites_table.sql
```

### Issue 2: Favorites save but don't appear
**Symptom**: Heart icon fills, but Saved Items screen is empty

**Possible causes**:
1. **ListingsService not initialized** - FIXED ✅
2. **Wrong user logged in** - Check auth state
3. **Item ID mismatch** - Check console logs

**Debug steps**:
- Check console logs for "DEBUG: Total favorites in service"
- If 0, check Supabase table directly
- If table has data but service shows 0, check RLS policies

### Issue 3: Permission/RLS errors
**Symptom**: Console shows "permission denied" or "RLS policy violation"

**Solution**: Verify RLS policies in Supabase:
1. Go to **Authentication → Policies**
2. Ensure `favorites` table has:
   - ✅ "Users can view their own favorites"
   - ✅ "Users can insert their own favorites"
   - ✅ "Users can delete their own favorites"

### Issue 4: Heart state not persistent
**Symptom**: Heart icon unfills when navigating away and back

**Solution**: This is now fixed because:
- `ListingsService` is a singleton
- Favorites are loaded from database on initialize
- State is maintained across screens

## Architecture Overview

```
User taps heart
    ↓
toggleFavoriteById() called
    ↓
DatabaseService.addToFavorites()
    ↓
Supabase 'favorites' table INSERT
    ↓
_favoriteItemIds Set updated in memory
    ↓
UI refreshes with setState()
    ↓
SavedItemsScreen shows favorited items
```

## Debug Mode

To see detailed logs, check your Flutter console for:
- ✅ Favorite add/remove operations
- ✅ Total favorites count
- ✅ Favorite IDs list
- ✅ Filtered saved items count

## No Bucket Needed!

**Important**: You don't need to create a Supabase Storage bucket for favorites. 

- **Buckets** are for storing files (images, videos, documents)
- **Tables** are for storing data (favorites, users, listings)
- The `favorites` table stores only metadata (user_id, item_id, item_type)

Your existing buckets:
- `profile-pictures` - stores user avatars ✅
- `listing-images` - stores product photos ✅

## Testing Checklist

- [ ] Favorites table exists in Supabase
- [ ] RLS policies are enabled and correct
- [ ] Heart icon toggles on/off when clicked
- [ ] Console shows favorite add/remove logs
- [ ] Saved Items screen initializes ListingsService
- [ ] Favorited items appear in Saved Items screen
- [ ] Unfavoriting removes item from Saved Items
- [ ] Favorites persist after app restart
- [ ] Favorites work across different screens (Browse, Category, Home)

## If Still Not Working

1. **Clear app data** and log in again
2. **Check Supabase logs** in Dashboard → Logs
3. **Share console output** showing the DEBUG logs
4. **Verify auth state** - ensure user is logged in
5. **Check network** - ensure internet connection
