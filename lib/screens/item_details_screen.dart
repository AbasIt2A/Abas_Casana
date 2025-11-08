import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_details_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final List<String> imageUrls;
  final String title;
  final String price;
  final String status;
  final String? sellerName;
  final String? sellerAvatar;
  final String? description;
  final String? listingId;
  final String? sellerId;
  final String? location;

  const ItemDetailsScreen({
    super.key,
    required this.imageUrls,
    required this.title,
    required this.price,
    required this.status,
    this.sellerName,
    this.sellerAvatar,
    this.description,
    this.listingId,
    this.sellerId,
    this.location,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalImages = widget.imageUrls.isNotEmpty
        ? widget.imageUrls.length
        : 1;
    
    // Remove ₱ symbol if already present in price
    final displayPrice = widget.price.replaceFirst('₱', '').trim();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF303F9F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Item Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(totalImages),
            _buildPageIndicator(totalImages),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceAndCondition(displayPrice),
                  const SizedBox(height: 20),
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.description ?? 
                    'No description provided for this item.',
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSellerInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(displayPrice),
    );
  }

  Widget _buildImageCarousel(int totalImages) {
    return Container(
      height: 320,
      color: Colors.white,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: totalImages,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = widget.imageUrls.isNotEmpty
                  ? widget.imageUrls[index]
                  : 'assets/images/image_placeholder.png';
              
              // Check if it's a URL or local asset
              final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
              
              return isNetworkImage
                  ? Image.network(
                      imageUrl,
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
                        return const Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    );
            },
          ),
          Positioned(
            top: 10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFF303F9F)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${_currentPage + 1}/$totalImages',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int totalImages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalImages, (index) {
          return Container(
            width: _currentPage == index ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: _currentPage == index
                  ? const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                    )
                  : null,
              color: _currentPage == index ? null : Colors.grey.shade300,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPriceAndCondition(String displayPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  '₱$displayPrice',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3F51B5),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_offer, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Negotiable',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              widget.status,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seller Information',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F51B5),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF3F51B5).withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFB300), width: 3),
                ),
                child: widget.sellerAvatar != null &&
                        widget.sellerAvatar!.isNotEmpty &&
                        (widget.sellerAvatar!.startsWith('http://') ||
                            widget.sellerAvatar!.startsWith('https://'))
                    ? CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(widget.sellerAvatar!),
                        backgroundColor: Colors.grey[300],
                        onBackgroundImageError: (exception, stackTrace) {
                          // Error handled by showing default icon
                        },
                        child: null,
                      )
                    : CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sellerName ?? 'Unknown Seller',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.location ?? 'Location not specified',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3F51B5),
                ),
                child: Text(
                  'View',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(String displayPrice) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Use the seller name from widget, fallback to 'Mark Santos'
                final sellerName = widget.sellerName ?? 'Mark Santos';
                final sellerAvatar =
                    widget.sellerAvatar ?? 'assets/images/profile.png';

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatDetailsScreen(
                      name: sellerName,
                      avatarUrl: sellerAvatar,
                      itemTitle: widget.title,
                      itemPrice: widget.price,
                      itemImageUrl: widget.imageUrls.isNotEmpty 
                          ? widget.imageUrls[0] 
                          : null,
                      itemStatus: widget.status,
                      listingId: widget.listingId,
                      sellerId: widget.sellerId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
              label: Text(
                'Message',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3F51B5),
                side: const BorderSide(color: Color(0xFF3F51B5), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to chat with auto-message
                final sellerName = widget.sellerName ?? 'Seller';
                final sellerAvatar = widget.sellerAvatar ?? 'assets/images/profile.png';

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatDetailsScreen(
                      name: sellerName,
                      avatarUrl: sellerAvatar,
                      itemTitle: widget.title,
                      itemPrice: widget.price,
                      itemImageUrl: widget.imageUrls.isNotEmpty 
                          ? widget.imageUrls[0] 
                          : null,
                      itemStatus: widget.status,
                      listingId: widget.listingId,
                      sellerId: widget.sellerId,
                      autoMessage: "Hi, I'm interested in the item. Is it still available?",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Buy Now - ₱$displayPrice',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
