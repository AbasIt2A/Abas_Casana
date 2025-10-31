import '../models/listing_item.dart';

/// A simple singleton service to manage user listings across the app
class ListingsService {
  static final ListingsService _instance = ListingsService._internal();

  factory ListingsService() {
    return _instance;
  }

  ListingsService._internal();

  final List<ListingItem> _userListings = [];
  final Set<String> _favoriteItemIds = {}; // Track favorites by item ID

  List<ListingItem> get userListings => List.unmodifiable(_userListings);

  void addListing(ListingItem item) {
    _userListings.insert(0, item); // Add to the beginning
  }

  void removeListing(String id) {
    _userListings.removeWhere((item) => item.id == id);
  }

  void updateListing(ListingItem updatedItem) {
    final index = _userListings.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _userListings[index] = updatedItem;
    }
  }

  void toggleFavorite(String id) {
    final index = _userListings.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _userListings[index];
      _userListings[index] = ListingItem(
        id: item.id,
        title: item.title,
        category: item.category,
        condition: item.condition,
        imageUrls: item.imageUrls,
        price: item.price,
        location: item.location,
        postDate: item.postDate,
        status: item.status,
        views: item.views,
        messages: item.messages,
        isFavorite: !item.isFavorite,
      );
    }
  }

  // Toggle favorite for any item (including sample/featured items)
  void toggleFavoriteById(String id) {
    if (_favoriteItemIds.contains(id)) {
      _favoriteItemIds.remove(id);
    } else {
      _favoriteItemIds.add(id);
    }
  }

  bool isFavorite(String id) {
    return _favoriteItemIds.contains(id);
  }

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteItemIds);

  int get totalCount => _userListings.length;

  int getCountByStatus(String status) {
    return _userListings.where((item) => item.status == status).length;
  }

  int get favoriteCount =>
      _userListings.where((item) => item.isFavorite).length +
      _favoriteItemIds.length;

  // Get all favorite items with their metadata
  Map<String, Map<String, String>> getAllFavoriteItems() {
    final Map<String, Map<String, String>> favorites = {};

    // Add user posted favorites
    for (var item in _userListings.where((item) => item.isFavorite)) {
      favorites[item.id] = {
        'title': item.title,
        'price': item.price,
        'imageUrl': item.imageUrls.isNotEmpty
            ? item.imageUrls[0]
            : 'assets/images/gadget1.jpg',
        'status': item.status,
        'postDate': item.formattedDate,
      };
    }

    return favorites;
  }
}
