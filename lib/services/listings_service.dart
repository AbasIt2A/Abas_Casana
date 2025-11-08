import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/listing_item.dart';
import 'database_service.dart';

/// A simple singleton service to manage user listings across the app
class ListingsService {
  static final ListingsService _instance = ListingsService._internal();

  factory ListingsService() {
    return _instance;
  }

  ListingsService._internal();

  final DatabaseService _dbService = DatabaseService();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  final List<ListingItem> _userListings = [];
  final Set<String> _favoriteItemIds = {}; // Track favorites by item ID
  bool _isInitialized = false;
  String? _currentUserId;

  List<ListingItem> get userListings => List.unmodifiable(_userListings);

  // Clear all data (called on logout)
  void clear() {
    _userListings.clear();
    _favoriteItemIds.clear();
    _isInitialized = false;
    _currentUserId = null;
  }

  // Initialize and load data from database
  Future<void> initialize() async {
    final user = _supabase.auth.currentUser;
    
    // If no user is logged in, clear data
    if (user == null) {
      clear();
      return;
    }
    
    // If already initialized for this user, skip
    if (_isInitialized && _currentUserId == user.id) {
      return;
    }
    
    // If switching users, clear old data first
    if (_currentUserId != null && _currentUserId != user.id) {
      clear();
    }
    
    // Load data for current user
    _currentUserId = user.id;
    await _loadUserListings(user.id);
    await _loadUserFavorites(user.id);
    _isInitialized = true;
  }

  Future<void> _loadUserListings(String userId) async {
    try {
      final listings = await _dbService.getUserListings(userId);
      _userListings.clear();
      
      for (var listing in listings) {
        _userListings.add(ListingItem(
          id: listing['id'].toString(),
          title: listing['title'],
          category: listing['category'],
          condition: listing['condition'],
          imageUrls: List<String>.from(listing['image_urls'] ?? []),
          price: listing['price'],
          location: listing['location'],
          postDate: DateTime.parse(listing['created_at']),
          status: listing['status'] ?? 'Active',
          views: listing['views'] ?? 0,
          messages: listing['messages'] ?? 0,
          isFavorite: false,
          description: listing['description'],
        ));
      }
    } catch (e) {
      print('Error loading user listings: $e');
    }
  }

  Future<void> _loadUserFavorites(String userId) async {
    try {
      final favorites = await _dbService.getUserFavorites(userId);
      _favoriteItemIds.clear();
      
      for (var fav in favorites) {
        _favoriteItemIds.add(fav['item_id'].toString());
      }
    } catch (e) {
      print('Error loading user favorites: $e');
    }
  }

  Future<void> addListing(ListingItem item) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Save to database
      final listingId = await _dbService.createListing(
        userId: user.id,
        title: item.title,
        category: item.category,
        condition: item.condition,
        imageUrls: item.imageUrls,
        price: item.price,
        location: item.location,
        description: item.description,
        status: item.status,
      );

      if (listingId != null) {
        // Update the item with the database ID
        final updatedItem = ListingItem(
          id: listingId,
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
          isFavorite: item.isFavorite,
          description: item.description,
        );
        
        _userListings.insert(0, updatedItem); // Add to the beginning
      }
    } catch (e) {
      print('Error adding listing: $e');
      rethrow;
    }
  }

  Future<void> removeListing(String id) async {
    try {
      await _dbService.deleteListing(id);
      _userListings.removeWhere((item) => item.id == id);
    } catch (e) {
      print('Error removing listing: $e');
      rethrow;
    }
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
        description: item.description,
      );
    }
  }

  // Toggle favorite for any item (including sample/featured items)
  Future<void> toggleFavoriteById(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      if (_favoriteItemIds.contains(id)) {
        // Remove from favorites
        await _dbService.removeFromFavorites(userId: user.id, itemId: id);
        _favoriteItemIds.remove(id);
        print('DEBUG: Removed favorite: $id');
      } else {
        // Add to favorites
        // All items from database are 'listing' type
        // Legacy prefixes like 'featured_' or 'sample_' are no longer used
        await _dbService.addToFavorites(
          userId: user.id,
          itemId: id,
          itemType: 'listing',
        );
        _favoriteItemIds.add(id);
        print('DEBUG: Added favorite: $id');
        print('DEBUG: Total favorites after add: ${_favoriteItemIds.length}');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
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

  // Count of favorited marketplace items (from other users)
  int get favoriteCount => _favoriteItemIds.length;

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

  // Get all marketplace listings (from all users)
  Future<List<ListingItem>> getMarketplaceListings({
    String? category,
    String? condition,
  }) async {
    try {
      final listings = await _dbService.getAllActiveListings(
        category: category,
        condition: condition,
      );

      return listings.map((listing) {
        return ListingItem(
          id: listing['id'].toString(),
          title: listing['title'],
          category: listing['category'],
          condition: listing['condition'],
          imageUrls: List<String>.from(listing['image_urls'] ?? []),
          price: listing['price'],
          location: listing['location'],
          postDate: DateTime.parse(listing['created_at']),
          status: listing['status'] ?? 'Active',
          views: listing['views'] ?? 0,
          messages: listing['messages'] ?? 0,
          isFavorite: _favoriteItemIds.contains(listing['id'].toString()),
          sellerName: listing['users']?['full_name'],
          sellerAvatar: listing['users']?['profile_pic_url'],
          description: listing['description'],
          sellerId: listing['user_id']?.toString(),
        );
      }).toList();
    } catch (e) {
      print('Error getting marketplace listings: $e');
      return [];
    }
  }

  // Get listing details with seller info
  Future<Map<String, dynamic>?> getListingDetails(String listingId) async {
    try {
      return await _dbService.getListingDetails(listingId);
    } catch (e) {
      print('Error getting listing details: $e');
      return null;
    }
  }
}
