import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/listings_service.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ListingsService _listingsService = ListingsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Force rebuild to show latest listings
    return WillPopScope(
      onWillPop: () async {
        // When navigating back, trigger a rebuild
        setState(() {});
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Stack(
          children: [
            // Premium gradient header
            SafeArea(
              bottom: false,
              child: Container(
                height: screenHeight * 0.24,
                width: screenWidth,
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
                  clipBehavior: Clip.none,
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
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Content section with tabs
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: screenHeight * 0.79,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildListingList(),
                          _buildListingList(filter: 'Active'),
                          _buildListingList(filter: 'Sold'),
                          _buildListingList(filter: 'Wishlist'),
                          _buildListingList(filter: 'Hidden'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'My Listings',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ],
          ),
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
              icon: const Icon(Icons.filter_list, color: Colors.white, size: 22),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF3F51B5),
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'All (${_listingsService.totalCount + 4})'),
          Tab(text: 'Active (${_listingsService.getCountByStatus('Active') + 2})'),
          Tab(text: 'Sold (${_listingsService.getCountByStatus('Sold') + 1})'),
          Tab(text: 'Wishlist (${_listingsService.favoriteCount})'),
          Tab(text: 'Hidden (${_listingsService.getCountByStatus('Hidden') + 1})'),
        ],
      ),
    );
  }

  // Helper method to get item data from ID
  Map<String, String>? _getItemDataFromId(String itemId) {
    // Featured items from home screen
    if (itemId.startsWith('featured_')) {
      final featuredItems = {
        'featured_iPhone_12_-_Cracked_Screen': {
          'title': 'iPhone 12 - Cracked Screen',
          'price': '\$85',
          'imageUrl': 'assets/images/gadget1.jpg',
          'status': 'Broken',
          'postDate': '2h ago',
        },
        'featured_MacBook_Pro_2018': {
          'title': 'MacBook Pro 2018',
          'price': '\$150',
          'imageUrl': 'assets/images/gadget2.jpg',
          'status': 'For Parts',
          'postDate': '5h ago',
        },
        'featured_Xbox_Controller': {
          'title': 'Xbox Controller',
          'price': '\$25',
          'imageUrl': 'assets/images/gadget3.jpg',
          'status': 'Working',
          'postDate': '1d ago',
        },
      };
      return featuredItems[itemId];
    }

    // Browse items
    if (itemId.startsWith('browse_')) {
      final browseItems = {
        'browse_iPhone_12_-_Cracked': {
          'title': 'iPhone 12 - Cracked',
          'price': '\$45',
          'imageUrl': 'assets/images/gadget1.jpg',
          'status': 'For Parts',
          'postDate': 'Posted 2 days ago',
        },
        'browse_Dell_Laptop': {
          'title': 'Dell Laptop',
          'price': '\$120',
          'imageUrl': 'assets/images/gadget2.jpg',
          'status': 'Working',
          'postDate': 'Posted 3 days ago',
        },
        'browse_iPad_Mini': {
          'title': 'iPad Mini',
          'price': '\$90',
          'imageUrl': 'assets/images/gadget4.jpg',
          'status': 'Working',
          'postDate': 'Posted 1 week ago',
        },
        'browse_PS4_Console': {
          'title': 'PS4 Console',
          'price': '\$85',
          'imageUrl': 'assets/images/gadget5.jpg',
          'status': 'Working',
          'postDate': 'Posted 5 days ago',
        },
      };
      return browseItems[itemId];
    }

    // Sample items from category screens
    final categoryItems = {
      'sample_phone_1': {
        'title': 'iPhone 12 - Cracked Screen',
        'price': '₱85',
        'imageUrl': 'assets/images/gadget1.jpg',
        'status': 'Broken',
        'postDate': '2h ago',
      },
      'sample_phone_2': {
        'title': 'Samsung Galaxy S20',
        'price': '₱150',
        'imageUrl': 'assets/images/gadget1.jpg',
        'status': 'Working',
        'postDate': '1d ago',
      },
      'sample_laptop_1': {
        'title': 'MacBook Pro 2018',
        'price': '₱150',
        'imageUrl': 'assets/images/gadget2.jpg',
        'status': 'For Parts',
        'postDate': '5h ago',
      },
      'sample_laptop_2': {
        'title': 'Dell XPS 13',
        'price': '₱200',
        'imageUrl': 'assets/images/gadget2.jpg',
        'status': 'Working',
        'postDate': '2d ago',
      },
      'sample_appliance_1': {
        'title': 'Electric Fan',
        'price': '₱50',
        'imageUrl': 'assets/images/gadget3.jpg',
        'status': 'Working',
        'postDate': '12h ago',
      },
      'sample_appliance_2': {
        'title': 'Microwave Oven',
        'price': '₱75',
        'imageUrl': 'assets/images/gadget3.jpg',
        'status': 'Needs Repair',
        'postDate': '3d ago',
      },
      'sample_accessory_1': {
        'title': 'Xbox Controller',
        'price': '₱25',
        'imageUrl': 'assets/images/gadget3.jpg',
        'status': 'Working',
        'postDate': '1d ago',
      },
      'sample_accessory_2': {
        'title': 'Wireless Mouse',
        'price': '₱30',
        'imageUrl': 'assets/images/gadget3.jpg',
        'status': 'Working',
        'postDate': '8h ago',
      },
    };
    return categoryItems[itemId];
  }

  Widget _buildListingList({String? filter}) {
    // Combine user listings with sample data
    final List<Widget> listingCards = [];

    // Add user's posted items first
    for (var item in _listingsService.userListings) {
      if (filter == 'Wishlist') {
        // Only show favorite items in Wishlist tab
        if (item.isFavorite) {
          listingCards.add(
            _buildListingCard(
              imageUrl: item.imageUrls.isNotEmpty
                  ? item.imageUrls[0]
                  : 'assets/images/gadget1.jpg',
              title: item.title,
              postDate: item.formattedDate,
              price: item.price,
              views: '${item.views} views • ${item.messages} messages',
              status: item.status,
              isUserPosted: true,
              isFavorite: item.isFavorite,
              itemId: item.id,
            ),
          );
        }
      } else if (filter == null ||
          (filter == 'Active' && item.status == 'Active') ||
          (filter == 'Sold' && item.status == 'Sold') ||
          (filter == 'Hidden' && item.status == 'Hidden')) {
        listingCards.add(
          _buildListingCard(
            imageUrl: item.imageUrls.isNotEmpty
                ? item.imageUrls[0]
                : 'assets/images/gadget1.jpg',
            title: item.title,
            postDate: item.formattedDate,
            price: item.price,
            views: '${item.views} views • ${item.messages} messages',
            status: item.status,
            isUserPosted: true,
            isFavorite: item.isFavorite,
            itemId: item.id,
          ),
        );
      }
    }

    // Add favorited sample items to wishlist
    if (filter == 'Wishlist') {
      for (var favoriteId in _listingsService.favoriteIds) {
        final itemData = _getItemDataFromId(favoriteId);
        if (itemData != null) {
          listingCards.add(
            _buildListingCard(
              imageUrl: itemData['imageUrl']!,
              title: itemData['title']!,
              postDate: itemData['postDate']!,
              price: itemData['price']!,
              views: '0 views • 0 messages',
              status: itemData['status']!,
              isFavorite: true,
              itemId: favoriteId,
            ),
          );
        }
      }
    }

    // Add sample data for demonstration
    if (filter == null || filter == 'Active') {
      listingCards.add(
        _buildListingCard(
          imageUrl: 'assets/images/gadget1.jpg',
          title: 'iPhone 12 - Cracked Screen',
          postDate: 'Posted 2 days ago',
          price: '₱85',
          views: '3 views • 1 message',
          status: 'Active',
        ),
      );
      listingCards.add(
        _buildListingCard(
          imageUrl: 'assets/images/gadget3.jpg',
          title: 'PS4 Controller - Broken Stick',
          postDate: 'Posted 3 days ago',
          price: '₱25',
          views: '6 views • 0 messages',
          status: 'Active',
        ),
      );
    }

    if (filter == null || filter == 'Sold') {
      listingCards.add(
        _buildListingCard(
          imageUrl: 'assets/images/gadget2.jpg',
          title: 'Dell Laptop - Missing Keys',
          postDate: 'Sold 5 days ago',
          price: '₱45',
          views: '12 views • 4 messages',
          status: 'Sold',
        ),
      );
    }

    if (filter == null || filter == 'Hidden') {
      listingCards.add(
        _buildListingCard(
          imageUrl: 'assets/images/ipad_mini.jpg',
          title: 'iPad Air - Screen Scratches',
          postDate: 'Posted 1 week ago',
          price: 'Free',
          views: '8 views • 2 messages',
          status: 'Donated',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: listingCards,
    );
  }

  Widget _buildListingCard({
    required String imageUrl,
    required String title,
    required String postDate,
    required String price,
    required String views,
    required String status,
    bool isUserPosted = false,
    bool isFavorite = false,
    String? itemId,
  }) {
    bool isSold = status == 'Sold';
    bool isDonated = status == 'Donated';
    bool isActive = status == 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF3F51B5).withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: isUserPosted && imageUrl.startsWith('/')
                          ? (kIsWeb
                                ? Image.network(
                                    imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                    ),
                                  )
                                : Image.file(
                                    File(imageUrl),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                    ),
                                  ))
                          : Image.asset(
                              imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                              ),
                            ),
                    ),
                    if (isUserPosted && itemId != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _listingsService.toggleFavorite(itemId);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? const Color(0xFFFF6B6B) : Colors.grey[600],
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive)
                            _buildStatusChip('Active', const Color(0xFF4CAF50)),
                          if (isSold) _buildStatusChip('Sold', Colors.grey[600]!),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            postDate,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          price,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            views,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
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
            const SizedBox(height: 12),
            if (isActive) _buildActiveButtons(),
            if (isSold) _buildSoldButtons(),
            if (isDonated) _buildDonatedButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildActiveButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Mark as Sold',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: const Color(0xFF3F51B5),
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, size: 20),
            color: const Color(0xFF3F51B5),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget _buildSoldButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'Sold',
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.visibility_outlined, size: 20),
            color: const Color(0xFF3F51B5),
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, size: 20),
            color: const Color(0xFFFF6B6B),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget _buildDonatedButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Mark as Donated',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: const Color(0xFF3F51B5),
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, size: 20),
            color: const Color(0xFF3F51B5),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}
