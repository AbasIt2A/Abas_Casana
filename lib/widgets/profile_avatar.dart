import 'package:flutter/material.dart';

/// A reusable profile avatar widget that displays user profile picture
/// Falls back to initials or default icon if no image is available
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? userName;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.userName,
    this.size = 40,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    this.onTap,
  });

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      print('ProfileAvatar: Loading image from URL: $imageUrl');
    } else {
      print('ProfileAvatar: No image URL, showing initials for: $userName');
    }

    final widget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? const Color(0xFFFFB300),
                width: borderWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('ProfileAvatar: Error loading image: $error');
                  return _buildFallback();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    print('ProfileAvatar: Image loaded successfully!');
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  );
                },
              )
            : _buildFallback(),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFF3F51B5).withValues(alpha: 0.1),
      child: Center(
        child: Text(
          _getInitials(userName),
          style: TextStyle(
            color: const Color(0xFF3F51B5),
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
