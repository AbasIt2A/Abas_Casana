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
    // Force rebuild to show latest listings
    return WillPopScope(
      onWillPop: () async {
        // When navigating back, trigger a rebuild
        setState(() {});
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0), Color(0xFF303F9F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Text(
            'My Listings',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab('All', _listingsService.totalCount + 4, 0),
                    const SizedBox(width: 8),
                    _buildTab('Active', _listingsService.getCountByStatus('Active') + 2, 1),
                    const SizedBox(width: 8),
                    _buildTab('Sold', _listingsService.getCountByStatus('Sold') + 1, 2),
                    const SizedBox(width: 8),
                    _buildTab('Wishlist', _listingsService.favoriteCount, 3),
                    const SizedBox(width: 8),
                    _buildTab('Hidden', _listingsService.getCountByStatus('Hidden') + 1, 4),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // All Items
            _buildListingList(),
            // Active Items
            _buildListingList(filter: 'Active'),
            // Sold Items
            _buildListingList(filter: 'Sold'),
            // Wishlist Items
            _buildListingList(filter: 'Wishlist'),
            // Hidden Items
            _buildListingList(filter: 'Hidden'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
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
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 20,
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
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isActive)
                            _buildStatusChip('Active', const Color(0xFF4CAF50)),
                          if (isSold) _buildStatusChip('Sold', Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            postDate,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        price,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF3F51B5),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.visibility, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            views,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 11,
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
        gradient: text == 'Active'
            ? const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
              )
            : null,
        color: text != 'Active' ? color.withValues(alpha: 0.15) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: text == 'Active'
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: text == 'Active' ? Colors.white : color,
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
                colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Mark as Sold',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3F51B5), width: 1.5),
          ),
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3F51B5),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Edit',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3F51B5), width: 1.5),
          ),
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3F51B5),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(Icons.more_horiz, size: 20),
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Sold',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3F51B5),
            side: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'View',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Icon(Icons.delete_outline, size: 20),
        ),
      ],
    );
  }

  Widget _buildDonatedButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3F51B5),
            side: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Edit',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3F51B5),
            side: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Icon(Icons.more_horiz, size: 20),
        ),
      ],
    );
  }
}
