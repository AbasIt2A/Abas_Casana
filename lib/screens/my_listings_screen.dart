import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'My Listings',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.green,
            ),
            tabs: [
              Tab(text: 'All (${_listingsService.totalCount + 4})'),
              Tab(
                text:
                    'Active (${_listingsService.getCountByStatus('Active') + 2})',
              ),
              Tab(
                text: 'Sold (${_listingsService.getCountByStatus('Sold') + 1})',
              ),
              Tab(text: 'Wishlist (${_listingsService.favoriteCount})'),
              Tab(
                text:
                    'Hidden (${_listingsService.getCountByStatus('Hidden') + 1})',
              ),
            ],
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

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive)
                            _buildStatusChip('Active', Colors.green),
                          if (isSold) _buildStatusChip('Sold', Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        postDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        views,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActiveButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark as Sold'),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: () {}, child: const Text('Edit')),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: () {}, child: const Icon(Icons.more_horiz)),
      ],
    );
  }

  Widget _buildSoldButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(onPressed: () {}, child: const Text('Sold')),
        ),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: () {}, child: const Text('View')),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Icon(Icons.delete_outline),
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
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark as Donated'),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: () {}, child: const Text('Edit')),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: () {}, child: const Icon(Icons.more_horiz)),
      ],
    );
  }
}
