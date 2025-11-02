import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/listing_item.dart';
import '../services/listings_service.dart';
import 'item_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ListingsService _listingsService = ListingsService();
  String _sortBy = 'Recent'; // Recent, Price Low-High, Price High-Low

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0), Color(0xFF303F9F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: FlexibleSpaceBar(
                    title: Text(
                      widget.category,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    background: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -60,
                          right: -40,
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
                          bottom: -30,
                          left: -50,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Icon(
                            widget.categoryIcon,
                            size: 180,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        Positioned(
                          bottom: 65,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.categoryIcon,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            leading: Container(
              margin: const EdgeInsets.only(left: 8, top: 8),
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
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12, top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.tune, color: Colors.white, size: 22),
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'Recent',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.access_time, 
                              size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Text('Most Recent', style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem(
                      value: 'Price Low-High',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_upward, 
                              size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Text('Price: Low to High', style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem(
                      value: 'Price High-Low',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_downward, 
                              size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Text('Price: High to Low', style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              child: _buildSortBadge(),
            ),
          ),
          _buildProductList(),
        ],
      ),
    );
  }

  Widget _buildSortBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.swap_vert_rounded, 
              color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Sorted by: $_sortBy',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    // Get all listings (user + sample data)
    final userListings = _listingsService.userListings
        .where((item) => item.category == widget.category)
        .toList();

    // Sample data for each category
    final sampleData = _getSampleDataForCategory();

    // Combine and sort
    final allItems = [...userListings, ...sampleData];

    if (allItems.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.categoryIcon,
                  size: 80,
                  color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No ${widget.category} available',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to list an item!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Apply sorting
    _sortItems(allItems);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = allItems[index];
            return _buildProductCard(item);
          },
          childCount: allItems.length,
        ),
      ),
    );
  }

  List<ListingItem> _getSampleDataForCategory() {
    switch (widget.category) {
      case 'Phones':
        return [
          ListingItem(
            id: 'sample_phone_1',
            title: 'iPhone 12 - Cracked Screen',
            category: 'Phones',
            condition: 'Broken',
            imageUrls: ['assets/images/gadget1.jpg'],
            price: '₱85',
            location: 'Manila',
            postDate: DateTime.now().subtract(const Duration(hours: 2)),
            status: 'Active',
          ),
          ListingItem(
            id: 'sample_phone_2',
            title: 'Samsung Galaxy S20',
            category: 'Phones',
            condition: 'Working',
            imageUrls: ['assets/images/gadget1.jpg'],
            price: '₱150',
            location: 'Quezon City',
            postDate: DateTime.now().subtract(const Duration(days: 1)),
            status: 'Active',
          ),
        ];
      case 'Laptops':
        return [
          ListingItem(
            id: 'sample_laptop_1',
            title: 'MacBook Pro 2018',
            category: 'Laptops',
            condition: 'For Parts',
            imageUrls: ['assets/images/gadget2.jpg'],
            price: '₱150',
            location: 'Makati',
            postDate: DateTime.now().subtract(const Duration(hours: 5)),
            status: 'Active',
          ),
          ListingItem(
            id: 'sample_laptop_2',
            title: 'Dell XPS 13',
            category: 'Laptops',
            condition: 'Working',
            imageUrls: ['assets/images/gadget2.jpg'],
            price: '₱200',
            location: 'Pasig',
            postDate: DateTime.now().subtract(const Duration(days: 2)),
            status: 'Active',
          ),
        ];
      case 'Appliances':
        return [
          ListingItem(
            id: 'sample_appliance_1',
            title: 'Electric Fan',
            category: 'Appliances',
            condition: 'Working',
            imageUrls: ['assets/images/gadget3.jpg'],
            price: '₱50',
            location: 'Taguig',
            postDate: DateTime.now().subtract(const Duration(hours: 12)),
            status: 'Active',
          ),
          ListingItem(
            id: 'sample_appliance_2',
            title: 'Microwave Oven',
            category: 'Appliances',
            condition: 'Needs Repair',
            imageUrls: ['assets/images/gadget3.jpg'],
            price: '₱75',
            location: 'Manila',
            postDate: DateTime.now().subtract(const Duration(days: 3)),
            status: 'Active',
          ),
        ];
      case 'Accessories':
        return [
          ListingItem(
            id: 'sample_accessory_1',
            title: 'Xbox Controller',
            category: 'Accessories',
            condition: 'Working',
            imageUrls: ['assets/images/gadget3.jpg'],
            price: '₱25',
            location: 'Pasay',
            postDate: DateTime.now().subtract(const Duration(days: 1)),
            status: 'Active',
          ),
          ListingItem(
            id: 'sample_accessory_2',
            title: 'Wireless Mouse',
            category: 'Accessories',
            condition: 'Working',
            imageUrls: ['assets/images/gadget3.jpg'],
            price: '₱30',
            location: 'Mandaluyong',
            postDate: DateTime.now().subtract(const Duration(hours: 8)),
            status: 'Active',
          ),
        ];
      default:
        return [];
    }
  }

  void _sortItems(List<ListingItem> items) {
    switch (_sortBy) {
      case 'Recent':
        items.sort((a, b) => b.postDate.compareTo(a.postDate));
        break;
      case 'Price Low-High':
        items.sort((a, b) {
          final priceA = _extractPrice(a.price);
          final priceB = _extractPrice(b.price);
          return priceA.compareTo(priceB);
        });
        break;
      case 'Price High-Low':
        items.sort((a, b) {
          final priceA = _extractPrice(a.price);
          final priceB = _extractPrice(b.price);
          return priceB.compareTo(priceA);
        });
        break;
    }
  }

  double _extractPrice(String priceString) {
    // Extract numeric value from price string (e.g., "₱85" -> 85.0)
    final numericString = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  Widget _buildProductCard(ListingItem item) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ItemDetailsScreen(
                imageUrls: item.imageUrls,
                title: item.title,
                price: item.price,
                status: item.condition,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.15),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3F51B5).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: item.imageUrls.isNotEmpty
                            ? Image.asset(
                                item.imageUrls[0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) {
                                  return Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey[400],
                                      size: 50,
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey[400],
                                  size: 50,
                                ),
                              ),
                      ),
                    ),
                    // Gradient overlay to cover any text in images
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Condition badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getConditionGradient(item.condition),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getConditionColor(item.condition).withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          item.condition,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    // Heart/Favorite icon
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _listingsService.toggleFavoriteById(item.id);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _listingsService.isFavorite(item.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _listingsService.isFavorite(item.id)
                                ? const Color(0xFFFF5252)
                                : Colors.grey[600],
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              item.price,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.location,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'working':
        return const Color(0xFF4CAF50);
      case 'needs repair':
      case 'broken':
        return const Color(0xFFFF9800);
      case 'for parts':
        return const Color(0xFF3F51B5);
      default:
        return Colors.grey;
    }
  }

  List<Color> _getConditionGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'working':
        return [const Color(0xFF4CAF50), const Color(0xFF45A049)];
      case 'needs repair':
      case 'broken':
        return [const Color(0xFFFF9800), const Color(0xFFF57C00)];
      case 'for parts':
        return [const Color(0xFF3F51B5), const Color(0xFF303F9F)];
      default:
        return [Colors.grey, Colors.grey[700]!];
    }
  }
}
