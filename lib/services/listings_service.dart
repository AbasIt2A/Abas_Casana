import '../models/listing_item.dart';

/// A simple singleton service to manage user listings across the app
class ListingsService {
  static final ListingsService _instance = ListingsService._internal();
  
  factory ListingsService() {
    return _instance;
  }
  
  ListingsService._internal();

  final List<ListingItem> _userListings = [];

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

  int get totalCount => _userListings.length;
  
  int getCountByStatus(String status) {
    return _userListings.where((item) => item.status == status).length;
  }
}
