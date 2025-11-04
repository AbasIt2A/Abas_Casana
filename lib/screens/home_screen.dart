// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'browse_screen.dart';
import 'category_screen.dart';
import 'item_details_screen.dart';
import 'messages_screen.dart';
import 'post_item_screen.dart';
import 'profile_screen.dart';
import '../models/listing_item.dart';
// auth_services import removed (not used in HomeScreen AppBar anymore)
import '../services/listings_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final ListingsService _listingsService = ListingsService();
  List<ListingItem> _featuredListings = [];
  bool _isLoadingListings = true;
  
  // Animation controllers
  late AnimationController _headerAnimationController;
  late AnimationController _categoriesAnimationController;
  late AnimationController _itemsAnimationController;
  
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _categoriesFadeAnimation;
  late Animation<Offset> _categoriesSlideAnimation;
  late Animation<double> _itemsFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadFeaturedListings();
  }
  
  void _setupAnimations() {
    // Single smooth entrance animation for all content
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Categories animation - subtle and quick
    _categoriesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    
    _categoriesFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _categoriesAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _categoriesSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _categoriesAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Items animation - minimal movement
    _itemsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    
    _itemsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _itemsAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start animations with minimal delays - almost simultaneous
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _categoriesAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _itemsAnimationController.forward();
    });
  }
  
  @override
  void dispose() {
    _headerAnimationController.dispose();
    _categoriesAnimationController.dispose();
    _itemsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedListings() async {
    setState(() {
      _isLoadingListings = true;
    });

    try {
      final listings = await _listingsService.getMarketplaceListings();
      setState(() {
        _featuredListings = listings.take(10).toList(); // Show first 10 items
        _isLoadingListings = false;
      });
    } catch (e) {
      print('Error loading featured listings: $e');
      setState(() {
        _isLoadingListings = false;
      });
    }
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      Navigator.of(context).push(_createRoute(const BrowseScreen()));
    } else if (index == 2) {
      final newItem = await Navigator.of(context).push(_createRoute(const PostItemScreen()));
      if (newItem != null && newItem is ListingItem && mounted) {
        ListingsService().addListing(newItem);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item posted successfully! View it in My Listings.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else if (index == 3) {
      Navigator.of(context).push(_createRoute(const MessagesScreen()));
    } else if (index == 4) {
      Navigator.of(context).push(_createRoute(const ProfileScreen()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  
  Route _createRoute(Widget destination) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.03, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
        var fadeAnimation = animation.drive(fadeTween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AuthService not needed in this AppBar since sign-out button removed

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 50),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/ramon_profile.jpg'),
            ),
          ),
        ],
      ),
      // ... (rest of the body and bottomNavigationBar remain the same)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _headerFadeAnimation,
              child: SlideTransition(
                position: _headerSlideAnimation,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3F51B5), Color(0xFF303F9F)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find Your Next Gadget',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Buy, sell, and discover electronics',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _categoriesFadeAnimation,
                    child: SlideTransition(
                      position: _categoriesSlideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Categories'),
                          const SizedBox(height: 16),
                          _buildCategoriesRow(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _itemsFadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Featured Items'),
                        _isLoadingListings
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _featuredListings.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(
                                        'No items from other users yet.\nCheck back later!',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: _featuredListings.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      return TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        duration: Duration(milliseconds: 350 + (index * 40)),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) {
                                          return Transform.translate(
                                            offset: Offset(0, 8 * (1 - value)),
                                            child: Opacity(
                                              opacity: 0.3 + (0.7 * value),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: _buildFeaturedItemCard(
                                            imageUrl: item.imageUrls.isNotEmpty
                                                ? item.imageUrls[0]
                                                : 'assets/images/gadget1.jpg',
                                            title: item.title,
                                            description: '${item.condition} • ${item.location}',
                                            price: item.price,
                                            status: item.condition,
                                            statusColor: _getStatusColor(item.condition),
                                            time: item.formattedDate,
                                            itemId: item.id,
                                            sellerName: item.sellerName,
                                            sellerAvatar: item.sellerAvatar,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFFB300),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }

  // --- Helper Methods ---
  // ... (_buildSearchBar, _buildSectionTitle, _buildCategoriesRow,
  //      _buildCategoryItem, _buildActionButtons, _buildFeaturedItemCard remain the same)

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
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search electronics...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF3F51B5),
      ),
    );
  }

  Widget _buildCategoriesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryItem(
          Icons.phone_iphone,
          'Phones',
          const Color(0xFF3F51B5).withValues(alpha: 0.1),
          const Color(0xFF3F51B5),
        ),
        _buildCategoryItem(
          Icons.laptop,
          'Laptops',
          const Color(0xFFFFB300).withValues(alpha: 0.15),
          const Color(0xFFFFB300),
        ),
        _buildCategoryItem(
          Icons.blender,
          'Appliances',
          Colors.purple.withValues(alpha: 0.1),
          Colors.purple,
        ),
        _buildCategoryItem(
          Icons.headphones,
          'Accessories',
          Colors.teal.withValues(alpha: 0.1),
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    IconData icon,
    String label,
    Color backgroundColor,
    Color iconColor,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: 0.3 + (0.7 * value),
          child: Transform.translate(
            offset: Offset(0, 5 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _CategoryItemTappable(
        icon: icon,
        label: label,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        onTap: () {
          Navigator.of(context).push(_createRoute(
            CategoryScreen(
              category: label,
              categoryColor: iconColor,
              categoryIcon: icon,
            ),
          ));
        },
      ),
    );
  }

  Widget _CategoryItemTappable({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Color _getStatusColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'working':
        return Colors.green;
      case 'needs repair':
        return Colors.orange;
      case 'for parts':
        return const Color(0xFF3F51B5);
      default:
        return Colors.grey;
    }
  }

  Widget _buildFeaturedItemCard({
    required String imageUrl,
    required String title,
    required String description,
    required String price,
    required String status,
    required Color statusColor,
    required String time,
    String? itemId,
    String? sellerName,
    String? sellerAvatar,
  }) {
    final heroTag = 'item_${itemId ?? title}_$imageUrl';
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(_createRoute(
            ItemDetailsScreen(
              imageUrls: [imageUrl],
              title: title,
              price: price,
              status: status,
              sellerName: sellerName,
              sellerAvatar: sellerAvatar,
            ),
          ));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Image fills the top area without internal padding so the product itself is shown
                  Hero(
                    tag: heroTag,
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            imageUrl,
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          // Use actual itemId or generate one for legacy items
                          final String favoriteId = itemId ?? 'featured_${title.replaceAll(' ', '_')}';
                          ListingsService().toggleFavoriteById(favoriteId);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ListingsService().isFavorite(
                                itemId ?? 'featured_${title.replaceAll(' ', '_')}',
                              )
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              ListingsService().isFavorite(
                                itemId ?? 'featured_${title.replaceAll(' ', '_')}',
                              )
                              ? Colors.red
                              : Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          price,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFB300),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
