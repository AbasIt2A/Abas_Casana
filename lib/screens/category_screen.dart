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
  List<ListingItem> _categoryListings = [];
  bool _isLoadingListings = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryListings();
  }

  Future<void> _loadCategoryListings() async {
    setState(() {
      _isLoadingListings = true;
    });

    try {
      // Get marketplace listings for this category (other users only, no hardcoded items)
      final listings = await _listingsService.getMarketplaceListings(
        category: widget.category,
      );

      setState(() {
        _categoryListings = listings;
        _isLoadingListings = false;
      });
    } catch (e) {
      print('Error loading category listings: $e');
      setState(() {
        _isLoadingListings = false;
      });
    }
  }

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
    if (_isLoadingListings) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_categoryListings.isEmpty) {
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
                'Check back later for new items!',
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
    _sortItems(_categoryListings);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _categoryListings.length,
      itemBuilder: (context, index) {
        final item = _categoryListings[index];
        return _buildProductCard(item);
      },
    );
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
                      child: () {
                        if (item.imageUrls.isEmpty) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          );
                        }
                        
                        final imageUrl = item.imageUrls[0];
                        final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
                        
                        return isNetworkImage
                            ? Image.network(
                                imageUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                      size: 40,
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                imageUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                      size: 40,
                                    ),
                                  );
                                },
                              );
                      }(),
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
