import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final String? itemTitle;
  final String? itemPrice;
  final String? itemImageUrl;
  final String? itemStatus;
  final String? listingId;
  final String? sellerId;
  final String? conversationId; // Add this parameter
  final String? autoMessage; // New parameter for auto-sending message

  const ChatDetailsScreen({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.itemTitle,
    this.itemPrice,
    this.itemImageUrl,
    this.itemStatus,
    this.listingId,
    this.sellerId,
    this.conversationId, // Add this parameter
    this.autoMessage, // New parameter
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DatabaseService _databaseService = DatabaseService();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _conversationId;
  String? _currentUserId;
  Timer? _messagePollingTimer;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('ERROR: No user logged in');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to view messages')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      _currentUserId = user.id;
      print('=== CHAT INITIALIZATION ===');
      print('Current User ID: $_currentUserId');
      print('Current User Email: ${user.email}');
      print('Widget conversationId: ${widget.conversationId}');
      print('Widget listingId: ${widget.listingId}');
      print('Widget sellerId: ${widget.sellerId}');
      
      // Use provided conversationId if available (from Messages screen)
      // Otherwise generate it (from ItemDetails screen)
      if (widget.conversationId != null && widget.conversationId!.isNotEmpty) {
        _conversationId = widget.conversationId;
        print('Using provided conversation ID: $_conversationId');
      } else if (widget.sellerId != null && widget.listingId != null) {
        _conversationId = _databaseService.generateConversationId(
          widget.listingId!,
          user.id,
          widget.sellerId!,
        );
        print('Generated new conversation ID: $_conversationId');
      } else {
        print('ERROR: Cannot create conversation - missing sellerId or listingId');
        setState(() => _isLoading = false);
        return;
      }

      await _loadMessages();
      await _markMessagesAsRead();
      
      // If autoMessage is provided, send it automatically
      if (widget.autoMessage != null && widget.autoMessage!.isNotEmpty) {
        _messageController.text = widget.autoMessage!;
        // Wait a moment for the UI to be ready, then send the message
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await _sendMessage();
        }
      }
      
      // Start polling for new messages every 3 seconds
      _startMessagePolling();
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startMessagePolling() {
    _messagePollingTimer?.cancel();
    print('=== POLLING SETUP ===');
    print('Starting message polling for conversation: $_conversationId');
    print('Current user ID: $_currentUserId');
    print('Listing ID: ${widget.listingId}');
    print('Seller ID: ${widget.sellerId}');
    print('==================');
    
    _messagePollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (mounted && _conversationId != null) {
        print('Polling for new messages... (Conversation: $_conversationId)');
        final messages = await _databaseService.getConversationMessages(_conversationId!);
        print('Poll result: ${messages.length} messages found');
        
        // Print all message IDs for debugging
        for (var i = 0; i < messages.length; i++) {
          print('  Message $i: "${messages[i]['message_text']}" from ${messages[i]['sender_id']}');
        }
        
        if (mounted && messages.length != _messages.length) {
          print('Message count changed! Old: ${_messages.length}, New: ${messages.length}');
          setState(() {
            _messages = messages;
          });
          _scrollToBottom();
        }
      } else {
        print('Stopping message polling - screen disposed');
        timer.cancel();
      }
    });
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) {
      print('ERROR: Cannot load messages - conversation ID is null');
      return;
    }

    try {
      final messages = await _databaseService.getConversationMessages(_conversationId!);
      
      // Only update if messages have changed
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        
        // Auto-scroll to bottom when new messages arrive
        if (messages.isNotEmpty) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (_conversationId == null || _currentUserId == null) return;

    try {
      await _databaseService.markMessagesAsRead(_conversationId!, _currentUserId!);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    
    // Debug logging
    print('=== SEND MESSAGE DEBUG ===');
    print('Text: $text');
    print('_isSending: $_isSending');
    print('_currentUserId: $_currentUserId');
    print('widget.sellerId: ${widget.sellerId}');
    print('widget.listingId: ${widget.listingId}');
    print('_conversationId: $_conversationId');
    
    if (text.isEmpty) {
      print('ERROR: Message text is empty');
      return;
    }
    
    if (_isSending) {
      print('ERROR: Already sending a message');
      return;
    }
    
    if (_currentUserId == null) {
      print('ERROR: Current user ID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Not logged in')),
      );
      return;
    }
    
    if (widget.sellerId == null) {
      print('ERROR: Seller ID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Seller information missing')),
      );
      return;
    }
    
    if (widget.listingId == null) {
      print('ERROR: Listing ID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Item information missing')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      print('Attempting to send message...');
      
      // Determine the receiver: if current user is the seller, receiver is the other user in conversation
      // Otherwise, receiver is the seller
      String receiverId;
      if (_currentUserId == widget.sellerId) {
        // Current user is the seller, so find the buyer from conversation ID
        // Conversation ID format: listingId_userId1_userId2
        final parts = _conversationId!.split('_');
        if (parts.length == 3) {
          // Get the other user ID (not the current user)
          receiverId = parts[1] == _currentUserId ? parts[2] : parts[1];
        } else {
          throw Exception('Invalid conversation ID format');
        }
      } else {
        // Current user is the buyer, receiver is the seller
        receiverId = widget.sellerId!;
      }
      
      print('Receiver ID determined: $receiverId');
      
      await _databaseService.sendMessage(
        conversationId: _conversationId!,
        senderId: _currentUserId!,
        receiverId: receiverId,
        listingId: widget.listingId!,
        messageText: text,
      );

      print('Message sent successfully!');
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _messagePollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildModernAppBar(),
      body: Column(
        children: [
          _buildItemBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessagesList(),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final senderId = message['sender_id']?.toString();
        final currentId = _currentUserId?.toString();
        final isMe = senderId != null && currentId != null && senderId == currentId;
        final timestamp = DateTime.parse(message['created_at']);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(widget.avatarUrl),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF3F51B5) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message['message_text'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMe) const SizedBox(width: 50),
              if (!isMe) const SizedBox(width: 50),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Start the conversation',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message about "${widget.itemTitle ?? 'this item'}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF3F51B5),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFB300), width: 2),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.avatarUrl.isNotEmpty 
                  ? NetworkImage(widget.avatarUrl) 
                  : null,
              child: widget.avatarUrl.isEmpty
                  ? Text(
                      widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3F51B5),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Active now',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildItemBanner() {
    final displayImage = widget.itemImageUrl ?? 'assets/images/gadget1.jpg';
    final displayTitle = widget.itemTitle ?? 'Item';
    final displayPrice = widget.itemPrice?.replaceFirst('₱', '').trim() ?? '0';
    final displayStatus = widget.itemStatus ?? 'For Sale';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFF3F51B5).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                displayImage,
                width: 70,
                height: 70,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayTitle,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F51B5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₱$displayPrice',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              displayStatus,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3F51B5).withValues(alpha: 0.15),
                    const Color(0xFF5C6BC0).withValues(alpha: 0.15),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline, 
                  color: Color(0xFF3F51B5), size: 24),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(
                    color: const Color(0xFF3F51B5).withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F51B5).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.sentiment_satisfied_alt_outlined,
                          color: const Color(0xFF3F51B5).withValues(alpha: 0.7),
                          size: 22,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.send_rounded, 
                  color: _isSending ? Colors.white.withOpacity(0.5) : Colors.white, 
                  size: 22),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
