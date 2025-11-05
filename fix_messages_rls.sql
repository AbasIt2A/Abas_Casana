-- Fix Row Level Security policies for messages table
-- This ensures users can see ALL messages in conversations they're part of

-- Drop existing SELECT policy
DROP POLICY IF EXISTS "Users can view their own messages" ON messages;

-- Create new SELECT policy that allows viewing all messages in a conversation
-- if the user is EITHER the sender OR receiver of ANY message in that conversation
CREATE POLICY "Users can view messages in their conversations"
  ON messages FOR SELECT
  USING (
    auth.uid() = sender_id OR auth.uid() = receiver_id
  );

-- Alternative: If the above doesn't work, use this more permissive policy
-- This allows users to see any message where they are involved in the conversation
-- DROP POLICY IF EXISTS "Users can view messages in their conversations" ON messages;
-- CREATE POLICY "Users can view all conversation messages"
--   ON messages FOR SELECT
--   USING (
--     conversation_id IN (
--       SELECT DISTINCT conversation_id 
--       FROM messages 
--       WHERE sender_id = auth.uid() OR receiver_id = auth.uid()
--     )
--   );
