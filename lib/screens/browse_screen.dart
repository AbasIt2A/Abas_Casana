import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'item_details_screen.dart';
import '../services/listings_service.dart';
import '../models/listing_item.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String? selectedFilter = 'All Items';
  bool isGridView = true;
  final ListingsService _listingsService = ListingsService();
  List<ListingItem> _browseListings = [];
  bool _isLoadingListings = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBrowseListings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBrowseListings() async {
    setState(() {
      _isLoadingListings = true;
    });

    try {
      String? conditionFilter;
      String? categoryFilter;

      // Map filter to database values
      if (selectedFilter == 'Working') {
        conditionFilter = 'Working';
      } else if (selectedFilter == 'Needs Repair') {
        conditionFilter = 'Needs Repair';
      } else if (selectedFilter == 'For Parts') {
        conditionFilter = 'For Parts';
      } else if (selectedFilter == 'Phones') {
        categoryFilter = 'Phones';
      } else if (selectedFilter == 'Laptops') {
        categoryFilter = 'Laptops';
      } else if (selectedFilter == 'Appliances') {
        categoryFilter = 'Appliances';
      } else if (selectedFilter == 'Accessories') {
        categoryFilter = 'Accessories';
      }

      final listings = await _listingsService.getMarketplaceListings(
        condition: conditionFilter,
        category: categoryFilter,
      );

      setState(() {
        _browseListings = listings;
        _isLoadingListings = false;
      });
    } catch (e) {
      print('Error loading browse listings: $e');
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
        title: Text(
          'Browse Market',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
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
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterAndLayoutButtons(),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildTagFilters(),
                const SizedBox(height: 20),
                isGridView ? _buildGridItems() : _buildListItems(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
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
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search electronics...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              child: const Icon(Icons.clear, color: Colors.grey, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterAndLayoutButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, size: 20),
            label: Text(
              'Filters',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3F51B5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.grid_view,
                  color: isGridView ? const Color(0xFFFFB300) : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isGridView = true;
                  });
                },
              ),
              Container(width: 1, height: 24, color: Colors.grey[300]),
              IconButton(
                icon: Icon(
                  Icons.list,
                  color: isGridView ? Colors.grey : const Color(0xFFFFB300),
                ),
                onPressed: () {
                  setState(() {
                    isGridView = false;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagFilters() {
    final tags = [
      'All Items',
      'Working',
      'Needs Repair',
      'For Parts',
      'Phones',
      'Laptops',
      'Appliances',
      'Accessories',
    ];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = selectedFilter == tag;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  selectedFilter = selected ? tag : null;
                });
                // Reload listings with new filter
                _loadBrowseListings();
              },
              selectedColor: const Color(0xFFFFB300),
              backgroundColor: Colors.white,
              labelStyle: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFFB300)
                    : Colors.grey.shade300,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: isSelected ? 2 : 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridItems() {
    if (_isLoadingListings) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Filter listings based on search query
    final filteredListings = _searchQuery.isEmpty
        ? _browseListings
        : _browseListings.where((item) {
            return item.title.toLowerCase().contains(_searchQuery) ||
                item.category.toLowerCase().contains(_searchQuery) ||
                item.condition.toLowerCase().contains(_searchQuery) ||
                (item.description?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();

    if (filteredListings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                _searchQuery.isEmpty ? Icons.inventory_2_outlined : Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? 'No items from other users.\nTry changing the filter or check back later.'
                    : 'No results found for "$_searchQuery"',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredListings.length,
      itemBuilder: (context, index) {
        final item = filteredListings[index];
        return _buildBrowseGridItem(item);
      },
    );
  }

  Widget _buildBrowseGridItem(ListingItem item) {
    Color statusColor = _getStatusColor(item.condition);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(
              imageUrls: item.imageUrls,
              title: item.title,
              price: item.price,
              status: item.condition,
              sellerName: item.sellerName,
              sellerAvatar: item.sellerAvatar,
              description: item.description,
              listingId: item.id,
              sellerId: item.sellerId,
              location: item.location,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: () {
                      final imageUrl = item.imageUrls.isNotEmpty ? item.imageUrls[0] : 'assets/images/gadget1.jpg';
                      final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
                      
                      return isNetworkImage
                          ? Image.network(
                              imageUrl,
                              height: 140,
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
                                return Container(
                                  height: 140,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                                );
                              },
                            )
                          : Image.asset(
                              imageUrl,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 140,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                                );
                              },
                            );
                    }(),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.condition,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        ListingsService().toggleFavoriteById(item.id);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ListingsService().isFavorite(item.id) ? Icons.favorite : Icons.favorite_border,
                        color: ListingsService().isFavorite(item.id) ? Colors.red : Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.price,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF3F51B5),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildListItems() {
    if (_isLoadingListings) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Filter listings based on search query
    final filteredListings = _searchQuery.isEmpty
        ? _browseListings
        : _browseListings.where((item) {
            return item.title.toLowerCase().contains(_searchQuery) ||
                item.category.toLowerCase().contains(_searchQuery) ||
                item.condition.toLowerCase().contains(_searchQuery) ||
                (item.description?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();

    if (filteredListings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                _searchQuery.isEmpty ? Icons.inventory_2_outlined : Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? 'No items from other users.\nTry changing the filter or check back later.'
                    : 'No results found for "$_searchQuery"',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredListings.length,
      itemBuilder: (context, index) {
        final item = filteredListings[index];
        return _buildBrowseListItem(item);
      },
    );
  }

  Widget _buildBrowseListItem(ListingItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(
              imageUrls: item.imageUrls,
              title: item.title,
              price: item.price,
              status: item.condition,
              sellerName: item.sellerName,
              sellerAvatar: item.sellerAvatar,
              description: item.description,
              listingId: item.id,
              sellerId: item.sellerId,
              location: item.location,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: () {
                  final imageUrl = item.imageUrls.isNotEmpty ? item.imageUrls[0] : 'assets/images/gadget1.jpg';
                  final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
                  
                  return isNetworkImage
                      ? Image.network(
                          imageUrl,
                          width: 120,
                          height: 120,
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
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            );
                          },
                        )
                      : Image.asset(
                          imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            );
                          },
                        );
                }(),
              ),
            ),
            // Item Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              ListingsService().toggleFavoriteById(item.id);
                            });
                          },
                          child: Icon(
                            ListingsService().isFavorite(item.id) ? Icons.favorite : Icons.favorite_border,
                            color: ListingsService().isFavorite(item.id) ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.condition).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.condition,
                        style: TextStyle(
                          color: _getStatusColor(item.condition),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.price,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF3F51B5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.location,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
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
}

