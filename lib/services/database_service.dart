import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create or update user profile
  Future<void> createUserProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phoneNumber,
    String? profilePicUrl,
  }) async {
    try {
      await _db.collection('users').doc(userId).set({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'profilePicUrl': profilePicUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Upload profile picture and get URL
  Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      final Reference storageRef = _storage.ref().child('profile_pictures/$userId.jpg');

      // Upload the file to Firebase Storage
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
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
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (profilePicUrl != null) updateData['profilePicUrl'] = profilePicUrl;

      await _db.collection('users').doc(userId).update(updateData);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return await getUserProfile(currentUser.uid);
    }
    return null;
  }
}