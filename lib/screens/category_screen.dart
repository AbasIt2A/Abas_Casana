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
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.categoryIcon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.category,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Recent',
                child: Text('Most Recent', style: GoogleFonts.poppins()),
              ),
              PopupMenuItem(
                value: 'Price Low-High',
                child: Text('Price: Low to High', style: GoogleFonts.poppins()),
              ),
              PopupMenuItem(
                value: 'Price High-Low',
                child: Text('Price: High to Low', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFF303F9F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
              child: Row(
                children: [
                  Icon(widget.categoryIcon, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Browse ${widget.category}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Sorted by: $_sortBy',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildProductList()),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.categoryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.categoryIcon,
                  size: 60,
                  color: widget.categoryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No ${widget.category} available',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        return _buildProductCard(item);
      },
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
              // Image
              Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: item.imageUrls.isNotEmpty
                          ? Image.asset(
                              item.imageUrls[0],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stack) {
                                return Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  // Condition badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getConditionColor(item.condition),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.condition,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Heart/Favorite icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _listingsService.toggleFavoriteById(item.id);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _listingsService.isFavorite(item.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _listingsService.isFavorite(item.id)
                              ? Colors.red
                              : Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.price,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFB300),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.location,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
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

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'working':
        return Colors.green;
      case 'needs repair':
      case 'broken':
        return Colors.orange;
      case 'for parts':
        return const Color(0xFF3F51B5);
      default:
        return Colors.grey;
    }
  }
}
