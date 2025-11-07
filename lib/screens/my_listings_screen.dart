import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/listings_service.dart';
import '../services/database_service.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ListingsService _listingsService = ListingsService();
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  // Reload listings from database
  Future<void> _loadListings() async {
    await _listingsService.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Force rebuild to show latest listings
    return WillPopScope(
      onWillPop: () async {
        // When navigating back, trigger a rebuild
        setState(() {});
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildModernAppBar(innerBoxIsScrolled),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildSliverTabBar(),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildListingList(),
              _buildListingList(filter: 'Active'),
              _buildListingList(filter: 'Sold'),
              _buildListingList(filter: 'Hidden'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF3F51B5),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 22),
              onPressed: () {},
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'My Listings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFF3F51B5).withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF3F51B5).withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Listings',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_listingsService.totalCount}',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3F51B5),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Items',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Active Seller',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF3F51B5),
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorPadding: const EdgeInsets.symmetric(horizontal: -12, vertical: 8),
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          tabs: [
            Tab(text: 'All (${_listingsService.totalCount})'),
            Tab(text: 'Active (${_listingsService.getCountByStatus('Active')})'),
            Tab(text: 'Sold (${_listingsService.getCountByStatus('Sold')})'),
            Tab(text: 'Hidden (${_listingsService.getCountByStatus('Hidden')})'),
          ],
        ),
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
      if (filter == null ||
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

    return listingCards.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F51B5).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 60,
                      color: const Color(0xFF3F51B5).withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No items found',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your listings will appear here',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3F51B5).withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[900],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: isUserPosted && imageUrl.startsWith('/')
                            ? (kIsWeb
                                  ? Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[900],
                                      ),
                                    )
                                  : Image.file(
                                      File(imageUrl),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[900],
                                      ),
                                    ))
                            : Image.asset(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[900],
                                ),
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
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? const Color(0xFFFF4444) : Colors.grey[400],
                              size: 18,
                            ),
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
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C3E50),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isActive) _buildStatusChip('Active', const Color(0xFF4CAF50)),
                          if (isSold) _buildStatusChip('Sold', Colors.grey[600]!),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3F51B5).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 12,
                                  color: const Color(0xFF3F51B5).withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  postDate,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF3F51B5).withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        price,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3F51B5),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 12, color: Colors.grey[600]),
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
          ),
          if (isActive || isSold || isDonated) ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF3F51B5).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isActive
                  ? _buildActiveButtons(itemId: itemId)
                  : isSold
                      ? _buildSoldButtons()
                      : _buildDonatedButtons(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildActiveButtons({String? itemId}) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: itemId == null ? null : () async {
                // Mark item as sold
                try {
                  await _dbService.updateListingStatus(itemId, 'Sold');
                  setState(() {
                    // Refresh the listings
                    _loadListings();
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Item marked as sold!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Mark as Sold',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildIconButton(Icons.edit_outlined, const Color(0xFF3F51B5)),
        const SizedBox(width: 10),
        _buildIconButton(Icons.more_horiz_rounded, Colors.grey[700]!),
      ],
    );
  }

  Widget _buildSoldButtons() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 1.5,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Sold',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildIconButton(Icons.visibility_outlined, const Color(0xFF3F51B5)),
        const SizedBox(width: 10),
        _buildIconButton(Icons.delete_outline_rounded, const Color(0xFFE53935)),
      ],
    );
  }

  Widget _buildDonatedButtons() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Mark as Donated',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildIconButton(Icons.edit_outlined, const Color(0xFF3F51B5)),
        const SizedBox(width: 10),
        _buildIconButton(Icons.more_horiz_rounded, Colors.grey[700]!),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: color, size: 20),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(),
      ),
    );
  }
}

// Custom delegate for SliverPersistentHeader
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF3F51B5).withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
