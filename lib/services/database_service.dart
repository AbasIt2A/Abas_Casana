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
}
