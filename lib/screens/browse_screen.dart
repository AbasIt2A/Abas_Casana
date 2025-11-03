import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'item_details_screen.dart';
import '../services/listings_service.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String? selectedFilter = 'All Items';
  bool isGridView = true;

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
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/profile.png'),
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
    // All available items with their categories
    final allItems = [
      {
        'imageUrl': 'assets/images/gadget1.jpg',
        'title': 'iPhone 12 - Cracked',
        'price': '\$45',
        'status': 'For Parts',
        'statusColor': Colors.red,
        'category': 'Phones',
      },
      {
        'imageUrl': 'assets/images/gadget2.jpg',
        'title': 'Dell Laptop',
        'price': '\$120',
        'status': 'Working',
        'statusColor': Colors.green,
        'category': 'Laptops',
      },
      {
        'imageUrl': 'assets/images/gadget4.jpg',
        'title': 'iPad Mini',
        'price': '\$90',
        'status': 'Working',
        'statusColor': Colors.green,
        'category': 'Phones',
      },
      {
        'imageUrl': 'assets/images/gadget5.jpg',
        'title': 'PS4 Console - Disc Drive Issue',
        'price': '\$85',
        'status': 'Needs Repair',
        'statusColor': Colors.orange,
        'category': 'Phones',
      },
      {
        'imageUrl': 'assets/images/gadget3.jpg',
        'title': 'MacBook Pro 2018',
        'price': '\$150',
        'status': 'For Parts',
        'statusColor': Colors.blue,
        'category': 'Laptops',
      },
      {
        'imageUrl': 'assets/images/gadget1.jpg',
        'title': 'Samsung Galaxy S20',
        'price': '\$95',
        'status': 'Working',
        'statusColor': Colors.green,
        'category': 'Phones',
      },
      {
        'imageUrl': 'assets/images/gadget2.jpg',
        'title': 'HP Laptop - Battery Dead',
        'price': '\$75',
        'status': 'Needs Repair',
        'statusColor': Colors.orange,
        'category': 'Laptops',
      },
    ];

    // Filter items based on selected filter
    final filteredItems = allItems.where((item) {
      if (selectedFilter == null || selectedFilter == 'All Items') {
        return true;
      } else if (selectedFilter == 'Working' ||
          selectedFilter == 'For Parts' ||
          selectedFilter == 'Needs Repair') {
        return item['status'] == selectedFilter;
      } else {
        // Category filter (Phones, Laptops)
        return item['category'] == selectedFilter;
      }
    }).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No items found',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting a different filter',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.65,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(
          imageUrl: item['imageUrl'] as String,
          title: item['title'] as String,
          description: '',
          price: item['price'] as String,
          status: item['status'] as String,
          statusColor: item['statusColor'] as Color,
          showViewButton: true,
        );
      },
    );
  }

  Widget _buildListItems() {
    // All available items with their categories
    final allItems = [
      {
        'imageUrl': 'assets/images/gadget1.jpg',
        'title': 'iPhone 12 - Cracked',
        'description': 'Screen broken, otherwise works fine',
        'price': '\$45',
        'status': 'For Parts',
        'statusColor': Colors.red,
        'category': 'Phones',
      },
      {
        'imageUrl': 'assets/images/gadget2.jpg',
        'title': 'Dell Laptop',
        'description': 'Used, good condition',
        'price': '\$120',
        'status': 'Working',
        'statusColor': Colors.green,
        'category': 'Laptops',
      },
      {
        'imageUrl': 'assets/images/gadget4.jpg',
        'title': 'iPad Mini',
        'description': 'Great condition, minor scratches',
        'price': '\$90',
        'status': 'Working',
        'statusColor': Colors.green,
        'category': 'Phones',
      },
      {
        'imageUrl': 'assets/images/gadget5.jpg',
        'title': 'PS4 Console - Disc Drive Issue',
        'description': 'Disc drive not working, needs repair',
        'price': '\$85',
        'status': 'Needs Repair',
        'statusColor': Colors.orange,
        'category': 'Phones',
      },
      {
        'imageUrl': 'assets/images/gadget3.jpg',
        'title': 'MacBook Pro 2018',
        'description': 'Water damage, good for parts',
        'price': '\$150',
        'status': 'For Parts',
        'statusColor': Colors.blue,
        'category': 'Laptops',
      },
      {
        'imageUrl': 'assets/images/gadget1.jpg',
        'title': 'Samsung Galaxy S20',
        'description': 'Fully functional, no issues',
        'price': '\$95',
        'status': 'Working',
        'statusColor': Colors.green,
        'category': 'Phones',
      },
      {
        'imageUrl': 'assets/images/gadget2.jpg',
        'title': 'HP Laptop - Battery Dead',
        'description': 'Battery needs replacement, otherwise works',
        'price': '\$75',
        'status': 'Needs Repair',
        'statusColor': Colors.orange,
        'category': 'Laptops',
      },
    ];

    // Filter items based on selected filter
    final filteredItems = allItems.where((item) {
      if (selectedFilter == null || selectedFilter == 'All Items') {
        return true;
      } else if (selectedFilter == 'Working' ||
          selectedFilter == 'For Parts' ||
          selectedFilter == 'Needs Repair') {
        return item['status'] == selectedFilter;
      } else {
        // Category filter (Phones, Laptops)
        return item['category'] == selectedFilter;
      }
    }).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No items found',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting a different filter',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filteredItems.map((item) {
        return Column(
          children: [
            _buildItemCard(
              imageUrl: item['imageUrl'] as String,
              title: item['title'] as String,
              description: item['description'] as String,
              price: item['price'] as String,
              status: item['status'] as String,
              statusColor: item['statusColor'] as Color,
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildItemCard({
    required String imageUrl,
    required String title,
    required String description,
    required String price,
    required String status,
    required Color statusColor,
    bool showViewButton = false,
    bool showClaimButton = false,
  }) {
    bool isListView = description.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(
              title: title,
              price: price,
              status: status,
              imageUrls: [imageUrl], // <-- FIXED: use imageUrls
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
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
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        // Generate unique ID for browse items based on title
                        final itemId = 'browse_${title.replaceAll(' ', '_')}';
                        ListingsService().toggleFavoriteById(itemId);
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
                              'browse_${title.replaceAll(' ', '_')}',
                            )
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            ListingsService().isFavorite(
                              'browse_${title.replaceAll(' ', '_')}',
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isListView && description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFB300),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (showViewButton) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ItemDetailsScreen(
                                title: title,
                                price: price,
                                status: status,
                                imageUrls: [imageUrl],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F51B5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                        ),
                        child: Text(
                          'View',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (showClaimButton) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'Claim',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
