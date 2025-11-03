import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create or update user profile
  Future<void> createUserProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phoneNumber,
    String? profilePicUrl,
  }) async {
    try {
      await _supabase.from('users').insert({
        'id': userId,
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'profile_pic_url': profilePicUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Upload profile picture and get URL
  Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final fileName = '$userId.jpg';
      final filePath = 'profile_pictures/$fileName';

      // Upload the file to Supabase Storage
      await _supabase.storage
          .from('profile-pictures')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get the public URL
      final String downloadUrl = _supabase.storage
          .from('profile-pictures')
          .getPublicUrl(filePath);

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? profilePicUrl,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (profilePicUrl != null) updateData['profile_pic_url'] = profilePicUrl;

      await _supabase.from('users').update(updateData).eq('id', userId);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return await getUserProfile(user.id);
    }
    return null;
  }

  // Create a new listing
  Future<String?> createListing({
    required String userId,
    required String title,
    required String category,
    required String condition,
    required List<String> imageUrls,
    required String price,
    required String location,
    String status = 'Active',
  }) async {
    try {
      final response = await _supabase.from('listings').insert({
        'user_id': userId,
        'title': title,
        'category': category,
        'condition': condition,
        'image_urls': imageUrls,
        'price': price,
        'location': location,
        'status': status,
        'views': 0,
        'messages': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      return response['id'].toString();
    } catch (e) {
      print('Error creating listing: $e');
      return null;
    }
  }

  // Get user's listings
  Future<List<Map<String, dynamic>>> getUserListings(String userId) async {
    try {
      final response = await _supabase
          .from('listings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting user listings: $e');
      return [];
    }
  }

  // Update listing
  Future<void> updateListing({
    required String listingId,
    String? title,
    String? category,
    String? condition,
    List<String>? imageUrls,
    String? price,
    String? location,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (category != null) updateData['category'] = category;
      if (condition != null) updateData['condition'] = condition;
      if (imageUrls != null) updateData['image_urls'] = imageUrls;
      if (price != null) updateData['price'] = price;
      if (location != null) updateData['location'] = location;
      if (status != null) updateData['status'] = status;

      await _supabase.from('listings').update(updateData).eq('id', listingId);
    } catch (e) {
      print('Error updating listing: $e');
      rethrow;
    }
  }

  // Delete listing
  Future<void> deleteListing(String listingId) async {
    try {
      await _supabase.from('listings').delete().eq('id', listingId);
    } catch (e) {
      print('Error deleting listing: $e');
      rethrow;
    }
  }

  // Add to favorites
  Future<void> addToFavorites({
    required String userId,
    required String itemId,
    required String itemType, // 'listing', 'featured', 'sample'
  }) async {
    try {
      await _supabase.from('favorites').insert({
        'user_id': userId,
        'item_id': itemId,
        'item_type': itemType,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites({
    required String userId,
    required String itemId,
  }) async {
    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('item_id', itemId);
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Get user's favorites
  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  // Check if item is favorited
  Future<bool> isFavorited({
    required String userId,
    required String itemId,
  }) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('item_id', itemId);

      return response.isNotEmpty;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}
