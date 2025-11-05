// Model for listing items
class ListingItem {
  final String id;
  final String title;
  final String category;
  final String condition;
  final List<String> imageUrls;
  final String price;
  final String location;
  final DateTime postDate;
  final String status;
  final int views;
  final int messages;
  final bool isFavorite;
  final String? sellerName;
  final String? sellerAvatar;
  final String? description;
  final String? sellerId;

  ListingItem({
    required this.id,
    required this.title,
    required this.category,
    required this.condition,
    required this.imageUrls,
    required this.price,
    required this.location,
    required this.postDate,
    this.status = 'Active',
    this.views = 0,
    this.messages = 0,
    this.isFavorite = false,
    this.sellerName,
    this.sellerAvatar,
    this.description,
    this.sellerId,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inDays == 0) {
      return 'Posted today';
    } else if (difference.inDays == 1) {
      return 'Posted 1 day ago';
    } else if (difference.inDays < 7) {
      return 'Posted ${difference.inDays} days ago';
    } else if (difference.inDays < 14) {
      return 'Posted 1 week ago';
    } else {
      return 'Posted ${(difference.inDays / 7).floor()} weeks ago';
    }
  }
}
