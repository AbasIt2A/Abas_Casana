import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';
import 'chat_details_screen.dart'; // Corrected import

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _showOnlyUnread = true; // true = Unread, false = All Messages
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  int _totalUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('No user logged in');
        setState(() => _isLoading = false);
        return;
      }

      print('=== LOADING CONVERSATIONS ===');
      print('Current user ID: ${user.id}');

      // Get all conversations for the current user
      final conversations = await _databaseService.getUserConversations(user.id);
      print('Found ${conversations.length} conversations');
      
      // Get total unread count
      final unreadCount = await _databaseService.getTotalUnreadCount(user.id);
      print('Total unread count: $unreadCount');
      
      // Enrich conversations with listing and user info
      for (var conv in conversations) {
        print('\n--- Processing conversation: ${conv['conversation_id']} ---');
        print('Last message: ${conv['last_message']}');
        
        // Get listing details
        final listing = await _databaseService.getListingForConversation(conv['conversation_id']);
        print('Listing: ${listing?['title']}');
        conv['listing'] = listing;
        
        // Get other user info
        final otherUser = await _databaseService.getOtherUserInfo(conv['conversation_id'], user.id);
        print('Other user: ${otherUser?['full_name']}');
        conv['other_user'] = otherUser;
        
        // Get unread count for this conversation
        final convUnreadCount = await _databaseService.getUnreadCount(conv['conversation_id'], user.id);
        print('Unread count: $convUnreadCount');
        conv['unread_count'] = convUnreadCount;
      }
      
      print('\n=== CONVERSATIONS LOADED ===');
      setState(() {
        _conversations = conversations;
        _totalUnreadCount = unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() => _isLoading = false);
    }
  }

  int _getUnreadCount() {
    return _totalUnreadCount;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Premium gradient background
          SafeArea(
            bottom: false,
            child: Container(
              height: screenHeight * 0.24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0), Color(0xFF303F9F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(context),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Premium white card section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                      child: Column(
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          _buildFilterTabs(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        children: [
                          _buildRecentConversations(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB300).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_comment, color: Colors.white, size: 22),
          label: Text(
            'New',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3F51B5).withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    // Calculate unread count
    final unreadCount = _getUnreadCount();
    
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showOnlyUnread = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: _showOnlyUnread
                    ? const LinearGradient(
                        colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                      )
                    : null,
                color: _showOnlyUnread ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _showOnlyUnread
                      ? const Color(0xFF3F51B5).withValues(alpha: 0.3)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: _showOnlyUnread
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3F51B5).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Unread',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _showOnlyUnread ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showOnlyUnread = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: !_showOnlyUnread
                    ? const LinearGradient(
                        colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                      )
                    : null,
                color: !_showOnlyUnread ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: !_showOnlyUnread
                      ? const Color(0xFF3F51B5).withValues(alpha: 0.3)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: !_showOnlyUnread
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3F51B5).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  'All Messages',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !_showOnlyUnread ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentConversations(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Filter conversations based on selected tab
    final filteredConversations = _showOnlyUnread
        ? _conversations.where((conv) => (conv['unread_count'] as int) > 0).toList()
        : _conversations;

    final unreadCount = _conversations
        .where((conv) => (conv['unread_count'] as int) > 0)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _showOnlyUnread ? 'Unread ($unreadCount)' : 'All Messages',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3F51B5),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _loadConversations,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3F51B5).withValues(alpha: 0.1),
                      const Color(0xFFFFB300).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3F51B5).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 16, color: Color(0xFF3F51B5)),
                    const SizedBox(width: 4),
                    Text(
                      'Refresh',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3F51B5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (filteredConversations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showOnlyUnread ? 'No unread messages' : 'No messages yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showOnlyUnread
                        ? 'All caught up!'
                        : 'Start a conversation to see messages here',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...filteredConversations.map((conv) {
            final otherUser = conv['other_user'] as Map<String, dynamic>?;
            final listing = conv['listing'] as Map<String, dynamic>?;
            final unreadCount = conv['unread_count'] as int;
            
            // Determine who is the seller (listing owner) and who is the buyer
            final sellerId = listing?['user_id']?.toString();
            final otherUserId = otherUser?['id']?.toString();
            
            // Format timestamp
            String timeAgo = 'Unknown';
            if (conv['last_message_time'] != null) {
              final timestamp = DateTime.parse(conv['last_message_time']);
              final difference = DateTime.now().difference(timestamp);
              
              if (difference.inMinutes < 1) {
                timeAgo = 'Just now';
              } else if (difference.inMinutes < 60) {
                timeAgo = '${difference.inMinutes}m';
              } else if (difference.inHours < 24) {
                timeAgo = '${difference.inHours}h';
              } else if (difference.inDays < 7) {
                timeAgo = '${difference.inDays}d';
              } else {
                timeAgo = '${(difference.inDays / 7).floor()}w';
              }
            }
            
            return _buildConversationTile(
              context: context,
              name: otherUser?['full_name'] ?? 'Unknown User',
              message: conv['last_message'] ?? 'No messages yet',
              time: timeAgo,
              avatarUrl: otherUser?['profile_pic_url'] ?? 'https://i.pravatar.cc/150?img=1',
              isOnline: false, // We don't have online status yet
              unreadCount: unreadCount,
              conversationId: conv['conversation_id'],
              listingId: listing?['id']?.toString(),
              sellerId: sellerId,
              itemTitle: listing?['title'],
              itemPrice: listing?['price'],
              itemImageUrl: (listing?['image_urls'] as List?)?.isNotEmpty == true 
                  ? listing!['image_urls'][0] 
                  : null,
              itemStatus: listing?['status'],
            );
          }).toList(),
      ],
    );
  }

  Widget _buildConversationTile({
    required BuildContext context,
    required String name,
    required String message,
    required String time,
    required String avatarUrl,
    bool isOnline = false,
    bool hasUnread = false,
    int unreadCount = 0,
    String? conversationId,
    String? listingId,
    String? sellerId,
    String? itemTitle,
    String? itemPrice,
    String? itemImageUrl,
    String? itemStatus,
  }) {
    final ImageProvider imageProvider;
    if (avatarUrl.startsWith('http')) {
      imageProvider = NetworkImage(avatarUrl);
    } else {
      imageProvider = AssetImage(avatarUrl);
    }

    return InkWell(
      onTap: () {
        // Navigate to chat with full context
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatDetailsScreen(
              name: name,
              avatarUrl: avatarUrl,
              itemTitle: itemTitle,
              itemPrice: itemPrice,
              itemImageUrl: itemImageUrl,
              itemStatus: itemStatus,
              listingId: listingId,
              sellerId: sellerId,
              conversationId: conversationId, // Pass the conversation ID!
            ),
          ),
        ).then((_) {
          // Reload conversations when returning from chat
          _loadConversations();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasUnread || unreadCount > 0
                ? const Color(0xFFFFB300).withValues(alpha: 0.4)
                : Colors.grey.shade200,
            width: hasUnread || unreadCount > 0 ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: hasUnread || unreadCount > 0
                  ? const Color(0xFFFFB300).withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF3F51B5).withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: imageProvider,
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      height: 14,
                      width: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: hasUnread || unreadCount > 0
                                ? Colors.black87
                                : Colors.grey[600],
                            fontWeight: hasUnread || unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (hasUnread || unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount > 0 ? unreadCount.toString() : 'NEW',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
