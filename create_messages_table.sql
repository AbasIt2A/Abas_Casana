-- Create messages table for user-to-user conversations
CREATE TABLE IF NOT EXISTS messages (
  id BIGSERIAL PRIMARY KEY,
  conversation_id TEXT NOT NULL,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id TEXT NOT NULL,
  message_text TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_listing_id ON messages(listing_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);

-- Enable Row Level Security
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Users can view messages they sent or received
CREATE POLICY "Users can view their own messages"
  ON messages FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Users can insert messages they are sending
CREATE POLICY "Users can send messages"
  ON messages FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

-- Users can update messages to mark as read
CREATE POLICY "Users can mark messages as read"
  ON messages FOR UPDATE
  USING (auth.uid() = receiver_id);

-- Function to generate conversation_id (ensures same ID for both users)
-- conversation_id format: "listingId_smallerUserId_largerUserId"
CREATE OR REPLACE FUNCTION generate_conversation_id(
  p_listing_id TEXT,
  p_user1_id UUID,
  p_user2_id UUID
) RETURNS TEXT AS $$
BEGIN
  IF p_user1_id < p_user2_id THEN
    RETURN p_listing_id || '_' || p_user1_id::TEXT || '_' || p_user2_id::TEXT;
  ELSE
    RETURN p_listing_id || '_' || p_user2_id::TEXT || '_' || p_user1_id::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
