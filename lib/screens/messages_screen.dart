import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_details_screen.dart'; // Corrected import

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFF303F9F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
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
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildRecentConversations(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFFFFB300),
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: Text(
          'New',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB300),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Unread',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3F51B5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'All Messages',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentConversations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Inbox',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3F51B5),
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list, size: 18),
              label: Text(
                'Filter',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3F51B5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildConversationTile(
          context: context,
          name: 'John Smith',
          message: 'Thanks for the quick delivery!',
          time: '2m',
          avatarUrl: 'assets/images/john.jpg',
          isOnline: true,
          hasUnread: true,
        ),
        _buildConversationTile(
          context: context,
          name: 'Sarah Johnson',
          message: 'Do you have any organic fertilizers available?',
          time: '15m',
          avatarUrl: 'assets/images/sarah.jpg',
          isOnline: false,
        ),
        _buildConversationTile(
          context: context,
          name: 'Mike Wilson',
          message: 'Perfect! I\'ll take 5 of those.',
          time: '1h',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          isOnline: true,
          unreadCount: 2,
        ),
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
  }) {
    final ImageProvider imageProvider;
    if (avatarUrl.startsWith('http')) {
      imageProvider = NetworkImage(avatarUrl);
    } else {
      imageProvider = AssetImage(avatarUrl);
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ChatDetailsScreen(name: name, avatarUrl: avatarUrl),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasUnread || unreadCount > 0
                ? const Color(0xFFFFB300).withValues(alpha: 0.3)
                : Colors.grey.shade200,
            width: hasUnread || unreadCount > 0 ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
