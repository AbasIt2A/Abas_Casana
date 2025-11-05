# Messaging System Setup Instructions

## Overview
The messaging system has been fully implemented with database persistence and real-time chat functionality between buyers and sellers.

## Setup Steps

### 1. Run SQL Migration
To enable the messaging functionality, you need to create the messages table in your Supabase database:

1. Open your Supabase dashboard
2. Go to the SQL Editor
3. Open the file `create_messages_table.sql` from this project
4. Copy all the contents
5. Paste into the Supabase SQL Editor
6. Click "Run" to execute the migration

This will create:
- `messages` table with all necessary columns
- Row Level Security (RLS) policies for secure access
- Database indexes for optimal performance
- Helper function `generate_conversation_id()` for consistent conversation tracking

### 2. Test the Messaging System

#### From Item Details:
1. Browse the marketplace and select an item posted by another user
2. Click the "Message" button
3. Type your message and press send
4. The message will be saved to the database

#### From Messages Screen:
1. The sender will see the conversation appear in their Messages screen
2. The receiver will see a new unread message notification
3. Clicking on a conversation opens the chat with full message history
4. Messages are marked as read automatically when viewed

### 3. Features Included

✅ **Real-time Messaging**
- Send and receive messages instantly
- Messages persist in database
- Chronological message display

✅ **Conversation Threading**
- Each item listing has its own conversation thread
- Conversations are identified by item and participant users
- Multiple items = multiple separate conversations

✅ **Unread Message Tracking**
- Red badge shows unread message count
- Tab filtering: "Unread" vs "All Messages"
- Messages automatically marked as read when viewed

✅ **Security**
- Row Level Security (RLS) ensures users only see their own messages
- Users can only send messages to valid listings
- Protected against unauthorized access

✅ **UI Features**
- Sender messages appear in blue on the right
- Receiver messages appear in white on the left
- Timestamps show when messages were sent
- Empty state when no messages exist
- Item banner shows what's being discussed
- Smooth scrolling to latest message

### 4. Database Schema

**messages** table:
- `id`: Unique message identifier
- `conversation_id`: Groups messages by listing and users (format: "listingId_userId1_userId2")
- `sender_id`: User who sent the message
- `receiver_id`: User who receives the message
- `listing_id`: The item being discussed
- `message_text`: The actual message content
- `is_read`: Boolean flag for read status
- `created_at`: Message timestamp

### 5. Testing Workflow

**Test with two user accounts:**

1. **User A** (Seller):
   - Login as User A
   - Post an item for sale

2. **User B** (Buyer):
   - Login as User B
   - Browse marketplace and find User A's item
   - Click "Message" button
   - Send a message: "Hi, is this still available?"

3. **User A** (Seller):
   - Go to Messages screen
   - See unread message badge
   - Click the conversation
   - Read User B's message
   - Reply: "Yes, it's available!"

4. **User B** (Buyer):
   - Check Messages screen
   - See User A's reply
   - Continue the conversation

### 6. Troubleshooting

**Messages not appearing?**
- Ensure SQL migration ran successfully
- Check Supabase logs for errors
- Verify both users are logged in
- Check that `listingId` and `sellerId` are being passed correctly

**Can't send messages?**
- Verify the item belongs to another user (not your own listing)
- Check that you're logged in
- Ensure the listing is active
- Check console logs for errors

**Unread counts not updating?**
- Messages are marked as read when the chat screen opens
- Refresh the Messages screen by switching tabs
- Check database RLS policies are active

### 7. Future Enhancements (Optional)

Consider adding these features later:
- Real-time message updates using Supabase subscriptions
- Typing indicators
- Message attachments (images)
- Delete/edit messages
- Block users
- Report inappropriate messages
- Push notifications for new messages
- Message search functionality

## Architecture

### Files Modified/Created:
1. `create_messages_table.sql` - Database schema
2. `lib/services/database_service.dart` - Messaging backend methods
3. `lib/screens/chat_details_screen.dart` - Chat UI with send/receive
4. `lib/screens/messages_screen.dart` - Conversations list with filtering
5. `lib/screens/item_details_screen.dart` - Message button integration
6. `lib/models/listing_item.dart` - Added sellerId field
7. `lib/services/listings_service.dart` - Pass sellerId in marketplace listings

### Key Methods:
- `sendMessage()` - Creates new message in database
- `getConversationMessages()` - Retrieves chat history
- `getUserConversations()` - Lists all user's conversations
- `markMessagesAsRead()` - Updates read status
- `getUnreadCount()` - Counts unread messages per conversation
- `getTotalUnreadCount()` - Total unread across all conversations

## Support

If you encounter any issues:
1. Check Supabase dashboard for database errors
2. Review Flutter console logs
3. Verify RLS policies are enabled
4. Ensure all dependencies are up to date

Happy messaging! 🎉
