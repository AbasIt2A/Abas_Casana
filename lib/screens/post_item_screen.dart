import 'dart:io' show File;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/listing_item.dart';
import '../services/database_service.dart';

enum Condition { working, needsRepair, forParts }

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final DatabaseService _dbService = DatabaseService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Condition? _selectedCondition;
  String? _selectedCategory;
  List<XFile> _selectedImages = [];
  bool _isPosting = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Post Item',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Item Name *'),
                TextFormField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter item name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe your item (condition, features, etc.)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Category *'),
                _buildCategoryDropdown(),
                const SizedBox(height: 24),
                _buildSectionTitle('Condition *'),
                _buildConditionRadios(),
                const SizedBox(height: 24),
                _buildSectionTitle('Photos'),
                const Text(
                  'Add up to 5 photos to help buyers see your item',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                _buildPhotoUploaders(),
                const SizedBox(height: 24),
                _buildSectionTitle('Price'),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: '₱ ',
                    hintText: '0.00',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Location *'),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: 'Enter your location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildPostButton(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      hint: const Text('Select category'),
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: ['Phones', 'Laptops', 'Appliances', 'Accessories']
          .map((label) => DropdownMenuItem(value: label, child: Text(label)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildConditionRadios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<Condition>(
          title: const Text('Working'),
          value: Condition.working,
          groupValue: _selectedCondition,
          onChanged: (Condition? value) {
            setState(() {
              _selectedCondition = value;
            });
          },
        ),
        RadioListTile<Condition>(
          title: const Text('Needs Repair'),
          value: Condition.needsRepair,
          groupValue: _selectedCondition,
          onChanged: (Condition? value) {
            setState(() {
              _selectedCondition = value;
            });
          },
        ),
        RadioListTile<Condition>(
          title: const Text('For Parts'),
          value: Condition.forParts,
          groupValue: _selectedCondition,
          onChanged: (Condition? value) {
            setState(() {
              _selectedCondition = value;
            });
          },
        ),
        if (_selectedCondition == null)
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0),
            child: Text(
              'Please select a condition',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (_selectedImages.length < 5) {
            _selectedImages.add(image);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Widget _buildPhotoUploaders() {
    return Column(
      children: [
        // Display selected images
        if (_selectedImages.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedImages.asMap().entries.map((entry) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                            entry.value.path,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(entry.value.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImages.removeAt(entry.key);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        if (_selectedImages.isNotEmpty) const SizedBox(height: 16),
        // Photo picker buttons centered
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!kIsWeb)
              _buildPhotoBox(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            if (!kIsWeb) const SizedBox(width: 16),
            _buildPhotoBox(
              icon: Icons.photo_library_outlined,
              label: kIsWeb ? 'Choose Files' : 'Gallery',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: Colors.grey,
        strokeWidth: 1,
        dashPattern: const [6, 3],
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey, size: 30),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  String _getConditionString() {
    switch (_selectedCondition) {
      case Condition.working:
        return 'Working';
      case Condition.needsRepair:
        return 'Needs Repair';
      case Condition.forParts:
        return 'For Parts';
      default:
        return '';
    }
  }

  void _handlePostItem() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check condition selection
    if (_selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a condition')),
      );
      return;
    }

    // Get current user
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // Generate temporary listing ID
      final tempListingId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Upload images to Supabase storage if any
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        print('Starting image upload for ${_selectedImages.length} images...');
        try {
          // Upload each image using XFile directly (avoids File namespace issues)
          for (int i = 0; i < _selectedImages.length; i++) {
            final xFile = _selectedImages[i];
            final fileName = '${tempListingId}_$i.jpg';
            
            print('Reading image $i: ${xFile.path}');
            
            // Read bytes directly from XFile (works across platforms)
            final bytes = await xFile.readAsBytes();
            print('Image $i size: ${bytes.length} bytes');
            
            // Upload to Supabase
            print('Uploading $fileName...');
            await _supabase.storage
                .from('listing-images')
                .uploadBinary(
                  fileName,
                  bytes,
                  fileOptions: const FileOptions(
                    upsert: true,
                    contentType: 'image/jpeg',
                  ),
                );
            
            print('Successfully uploaded: $fileName');
            
            // Get public URL
            final String downloadUrl = _supabase.storage
                .from('listing-images')
                .getPublicUrl(fileName);
            
            print('Public URL: $downloadUrl');
            imageUrls.add(downloadUrl);
          }
          
          print('Upload completed. URLs received: ${imageUrls.length}');
          if (imageUrls.isEmpty) {
            throw Exception('No images were uploaded successfully');
          }
          print('Successfully uploaded ${imageUrls.length} images');
        } catch (uploadError) {
          print('Image upload error: $uploadError');
          throw Exception('Failed to upload images: $uploadError');
        }
      }

      // Create listing in database
      print('Creating listing in database...');
      final listingId = await _dbService.createListing(
        userId: currentUser.id,
        title: _itemNameController.text.trim(),
        category: _selectedCategory!,
        condition: _getConditionString(),
        imageUrls: imageUrls,
        price: _priceController.text.trim().isEmpty
            ? 'Free'
            : '₱${_priceController.text.trim()}',
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (listingId == null) {
        throw Exception('Failed to create listing in database');
      }

      print('Successfully created listing with ID: $listingId');

      // Create listing item object to return
      final newItem = ListingItem(
        id: listingId,
        title: _itemNameController.text.trim(),
        category: _selectedCategory!,
        condition: _getConditionString(),
        imageUrls: imageUrls,
        price: _priceController.text.trim().isEmpty
            ? 'Free'
            : '₱${_priceController.text.trim()}',
        location: _locationController.text.trim(),
        postDate: DateTime.now(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        // Return to previous screen with the new item
        Navigator.pop(context, newItem);
      }
    } catch (e) {
      print('ERROR posting item: $e');
      print('Error type: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  Widget _buildPostButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _isPosting ? null : _handlePostItem,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D63F3),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isPosting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Post Item',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
