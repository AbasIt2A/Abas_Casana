-- ============================================
-- FIX TRIGGER TO WORK WITH EMAIL CONFIRMATION
-- ============================================
-- Run this in your Supabase SQL Editor

-- Step 1: Drop and recreate the trigger function with proper permissions
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER -- This makes it run with elevated permissions
SET search_path = public
AS $$
BEGIN
  -- Insert with explicit error handling
  INSERT INTO public.users (id, email, full_name, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING; -- Prevent duplicate key errors
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the auth user creation
    RAISE WARNING 'Error creating user profile: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 2: Recreate the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Step 3: Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.users TO postgres, service_role;
GRANT SELECT, INSERT, UPDATE ON public.users TO authenticated;

-- Step 4: Modify RLS policy to allow the trigger to insert
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;

CREATE POLICY "Enable insert for new users"
  ON public.users
  FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

COMMENT ON POLICY "Enable insert for new users" ON public.users IS 'Allows trigger to create profiles during signup';

-- ============================================
-- OPTIONAL: Manually add the bonoy119 user
-- ============================================
-- Uncomment and run this if you want to manually add the existing bonoy119 user:

-- INSERT INTO public.users (id, email, full_name, phone_number, created_at, updated_at)
-- VALUES (
--   '3b525efe-4f57-4242-865d-5e47dab9dc13',
--   'bonoy119@gmail.com',
--   'Bonoy User',
--   NULL,
--   NOW(),
--   NOW()
-- );
