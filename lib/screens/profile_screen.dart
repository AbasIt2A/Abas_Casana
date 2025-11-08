import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_listings_screen.dart';
import 'saved_items_screen.dart';
import 'edit_profile_screen.dart';
import '../services/auth_services.dart';
import '../services/database_service.dart';
import '../services/listings_service.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _dbService = DatabaseService();
  final ListingsService _listingsService = ListingsService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _initializeListingsService();
  }

  Future<void> _initializeListingsService() async {
    try {
      await _listingsService.initialize(forceReload: true);
      setState(() {
        // Trigger rebuild after listings are loaded
      });
    } catch (e) {
      print('Error initializing listings service: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      print('=== PROFILE SCREEN: Loading user profile ===');
      final profile = await _dbService.getCurrentUserProfile();
      print('Profile data: $profile');
      print('Profile pic URL from profile: ${profile?['profile_pic_url']}');
      
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
      
      print('Profile screen state updated');
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(context),
            ),
            automaticallyImplyLeading: false,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('My Activity'),
                    const SizedBox(height: 8),
                    _buildListTile(
                      icon: Icons.format_list_bulleted,
                      title: 'My Listings',
                      subtitle: 'View your posted items',
                      trailingText: '${_listingsService.getCountByStatus('Active')} Active',
                      trailingColor: Colors.green,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MyListingsScreen(),
                          ),
                        );
                        // Reload listings service to update counts after returning
                        await _initializeListingsService();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildListTile(
                      icon: Icons.favorite_border,
                      title: 'Saved Items',
                      subtitle: 'Your favorited items',
                      trailingText: '${_listingsService.favoriteCount} Saved',
                      trailingColor: Colors.pink,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SavedItemsScreen(),
                          ),
                        );
                        // Reload listings service to update counts after returning
                        await _initializeListingsService();
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Settings'),
                    const SizedBox(height: 8),
                    _buildListTile(
                      icon: Icons.person_outline,
                      title: 'Account Settings',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _buildListTile(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _buildListTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _buildListTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    _buildListTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final authService = AuthService();
                                    await authService.signOut();
                                    // Clear user data from ListingsService
                                    ListingsService().clear();
                                    // Close the dialog
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      // AuthWrapper will automatically handle navigation to LoginScreen
                                      // No need for manual navigation - just pop all screens to root
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    }
                                  },
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3F51B5), Color(0xFF303F9F)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                'My Profile',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 24),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  // Reload profile after returning from edit screen
                  print('=== RETURNED FROM EDIT PROFILE - RELOADING ===');
                  _loadUserProfile();
                },
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Stack(
                children: [
                  ProfileAvatar(
                    imageUrl: _userProfile?['profile_pic_url'],
                    userName: _userProfile?['full_name'],
                    size: 70,
                    showBorder: true,
                    borderColor: const Color(0xFFFFB300),
                    borderWidth: 3,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFB300), width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFFFB300),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoading 
                      ? 'Loading...' 
                      : (_userProfile?['full_name'] ?? 'User'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _isLoading 
                      ? 'Loading...' 
                      : (_userProfile?['email'] ?? 'No email'),
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    // Get the actual sold count from listings service
    final soldCount = _listingsService.getCountByStatus('Sold');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF3F51B5), const Color(0xFF3F51B5).withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            soldCount.toString(),
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Items Sold',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF3F51B5),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    Color? trailingColor,
    Color iconColor = Colors.grey,
    Color textColor = Colors.black87,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                iconColor.withValues(alpha: 0.2),
                iconColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: textColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: trailingColor?.withValues(alpha: 0.15) ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trailingText,
                  style: GoogleFonts.poppins(
                    color: trailingColor ?? Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
