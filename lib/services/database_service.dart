import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create or update user profile
  // Note: The auth trigger automatically creates a basic profile
  // This method updates it with additional information
  Future<void> createUserProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phoneNumber,
    String? profilePicUrl,
  }) async {
    try {
      // Wait a moment for the auth trigger to create the basic profile
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update the profile with additional info
      await _supabase.from('users').update({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'profile_pic_url': profilePicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      print('Profile updated successfully for user: $userId');
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Upload profile picture and get URL
  Future<String?> uploadProfilePicture(XFile imageFile, String userId) async {
    try {
      final fileName = '$userId.jpg';
      final filePath = fileName; // Store in root of bucket

      print('Uploading profile picture: $fileName');
      print('Image path: ${imageFile.path}');

      // Read file bytes directly from XFile (works on web and mobile)
      final bytes = await imageFile.readAsBytes();
      print('File size: ${bytes.length} bytes');

      // Upload the file to Supabase Storage using uploadBinary
      final response = await _supabase.storage
          .from('profile-pictures')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      print('Upload response: $response');
      print('Successfully uploaded: $fileName');

      // Get the public URL
      final String downloadUrl = _supabase.storage
          .from('profile-pictures')
          .getPublicUrl(filePath);

      print('Public URL: $downloadUrl');
      return downloadUrl;
    } catch (e, stackTrace) {
      print('Error uploading profile picture: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Upload listing images and get URLs
  Future<List<String>> uploadListingImages(List<String> imagePaths, String listingId) async {
    final List<String> imageUrls = [];
    
    for (int i = 0; i < imagePaths.length; i++) {
      try {
        final imagePath = imagePaths[i];
        final fileName = '${listingId}_$i.jpg';
        final filePath = fileName;

        print('Uploading image $i: $fileName');
        print('Image path: $imagePath');
        
        // Read file bytes directly from path
        final file = File(imagePath);
        
        // Verify file exists
        if (!await file.exists()) {
          print('ERROR: File does not exist: $imagePath');
          continue;
        }
        
        // Read file bytes
        final bytes = await file.readAsBytes();
        print('File size: ${bytes.length} bytes');
        
        // Upload the file to Supabase Storage
        final response = await _supabase.storage
            .from('listing-images')
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'image/jpeg',
              ),
            );

        print('Upload response: $response');
        print('Successfully uploaded: $fileName');

        // Get the public URL
        final String downloadUrl = _supabase.storage
            .from('listing-images')
            .getPublicUrl(filePath);

        print('Public URL: $downloadUrl');
        imageUrls.add(downloadUrl);
      } catch (e, stackTrace) {
        print('Error uploading image $i: $e');
        print('Stack trace: $stackTrace');
        // Continue with next image instead of failing completely
      }
    }
    
    if (imageUrls.isEmpty && imagePaths.isNotEmpty) {
      throw Exception('Failed to upload any images. Check console logs for details.');
    }
    
    return imageUrls;
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
    String? description,
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
        'description': description,
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

  // Get all active listings from all users (marketplace view)
  // Excludes current user's own listings
  Future<List<Map<String, dynamic>>> getAllActiveListings({
    String? category,
    String? condition,
    int limit = 50,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return []; // No listings if not logged in
      }

      var query = _supabase
          .from('listings')
          .select('*')
          .eq('status', 'Active')
          .neq('user_id', currentUser.id); // Exclude current user's listings

      if (category != null) {
        query = query.eq('category', category);
      }

      if (condition != null) {
        query = query.eq('condition', condition);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final listings = List<Map<String, dynamic>>.from(response);
      
      // Manually fetch user info for each listing
      for (var listing in listings) {
        final userId = listing['user_id'];
        if (userId != null) {
          final userProfile = await getUserProfile(userId);
          listing['users'] = {
            'full_name': userProfile?['full_name'],
            'profile_pic_url': userProfile?['profile_pic_url'],
          };
        }
      }

      return listings;
    } catch (e) {
      print('Error getting all listings: $e');
      return [];
    }
  }

  // Get listing details with seller info
  Future<Map<String, dynamic>?> getListingDetails(String listingId) async {
    try {
      final response = await _supabase
          .from('listings')
          .select('*')
          .eq('id', listingId)
          .single();

      final listing = Map<String, dynamic>.from(response);
      
      // Fetch user info separately
      final userId = listing['user_id'];
      if (userId != null) {
        final userProfile = await getUserProfile(userId);
        listing['users'] = {
          'full_name': userProfile?['full_name'],
          'profile_pic_url': userProfile?['profile_pic_url'],
          'phone_number': userProfile?['phone_number'],
        };
      }

      return listing;
    } catch (e) {
      print('Error getting listing details: $e');
      return null;
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

  // Update listing status (e.g., mark as sold)
  Future<void> updateListingStatus(String listingId, String newStatus) async {
    try {
      await _supabase.from('listings').update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', listingId);
    } catch (e) {
      print('Error updating listing status: $e');
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

  // ==================== MESSAGING METHODS ====================
  
  // Generate conversation ID (smaller UUID first for consistency)
  String generateConversationId(String listingId, String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return '${listingId}_${users[0]}_${users[1]}';
  }

  // Send a message
  Future<String?> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String listingId,
    required String messageText,
  }) async {
    try {
      final response = await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'listing_id': listingId,
        'message_text': messageText,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return response['id'].toString();
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Get messages for a conversation
  Future<List<Map<String, dynamic>>> getConversationMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting conversation messages: $e');
      return [];
    }
  }

  // Get all conversations for a user (grouped by conversation_id)
  Future<List<Map<String, dynamic>>> getUserConversations(String userId) async {
    try {
      // Get all messages involving the user
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false);

      final messages = List<Map<String, dynamic>>.from(response);
      
      // Group by conversation_id and get the latest message for each
      final Map<String, Map<String, dynamic>> conversationsMap = {};
      
      for (var message in messages) {
        final convId = message['conversation_id'];
        if (!conversationsMap.containsKey(convId)) {
          // Store the conversation with properly formatted data
          conversationsMap[convId] = {
            'conversation_id': convId,
            'last_message': message['message_text'],
            'last_message_time': message['created_at'],
            'listing_id': message['listing_id'],
            'sender_id': message['sender_id'],
            'receiver_id': message['receiver_id'],
          };
        }
      }

      return conversationsMap.values.toList();
    } catch (e) {
      print('Error getting user conversations: $e');
      return [];
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .eq('receiver_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Get unread message count for a conversation
  Future<int> getUnreadCount(String conversationId, String userId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .eq('receiver_id', userId)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Get total unread messages for a user
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('receiver_id', userId)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      print('Error getting total unread count: $e');
      return 0;
    }
  }

  // Get listing info for a conversation
  Future<Map<String, dynamic>?> getListingForConversation(String conversationId) async {
    try {
      // Extract listing_id from conversation_id (format: listingId_userId1_userId2)
      final parts = conversationId.split('_');
      if (parts.isEmpty) return null;
      
      final listingId = parts[0];
      
      final response = await _supabase
          .from('listings')
          .select()
          .eq('id', listingId)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting listing for conversation: $e');
      return null;
    }
  }

  // Get other user's info from conversation
  Future<Map<String, dynamic>?> getOtherUserInfo(String conversationId, String currentUserId) async {
    try {
      // Parse conversation_id: listingId_userId1_userId2
      final parts = conversationId.split('_');
      if (parts.length != 3) return null;

      final otherUserId = parts[1] == currentUserId ? parts[2] : parts[1];
      return await getUserProfile(otherUserId);
    } catch (e) {
      print('Error getting other user info: $e');
      return null;
    }
  }
}
