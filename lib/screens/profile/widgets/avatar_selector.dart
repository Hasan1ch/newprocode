import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:procode/config/constants.dart';

/// Avatar selector widget that allows users to choose profile pictures
/// Supports camera, gallery upload, and predefined avatar selection
class AvatarSelector extends StatefulWidget {
  final String? currentAvatarUrl;
  final Function(String) onAvatarSelected;

  const AvatarSelector({
    super.key,
    this.currentAvatarUrl,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath; // Path to user-selected image
  String? _selectedDefaultAvatar; // Name of selected default avatar

  @override
  void initState() {
    super.initState();
    // Check if current avatar is one of the default options
    if (widget.currentAvatarUrl != null) {
      final defaultIndex = AppConstants.defaultAvatars.indexWhere(
        (avatar) => widget.currentAvatarUrl!.contains(avatar),
      );
      if (defaultIndex != -1) {
        _selectedDefaultAvatar = AppConstants.defaultAvatars[defaultIndex];
      }
    }
  }

  /// Handles image picking from camera or gallery
  /// Applies size and quality constraints for optimal performance
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512, // Limit size for storage efficiency
        maxHeight: 512,
        imageQuality: 85, // Balance quality and file size
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _selectedDefaultAvatar = null; // Clear default selection
        });
        widget.onAvatarSelected(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  /// Selects a default avatar from predefined options
  void _selectDefaultAvatar(String avatarName) {
    setState(() {
      _selectedDefaultAvatar = avatarName;
      _selectedImagePath = null; // Clear custom image selection
    });
    widget.onAvatarSelected('assets/images/avatars/$avatarName');
  }

  /// Shows bottom sheet with avatar selection options
  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar for visual feedback
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Choose Avatar',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Upload options for camera and gallery
            Row(
              children: [
                Expanded(
                  child: _buildUploadOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUploadOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Default avatar grid
            Text(
              'Or choose a default avatar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Grid of predefined avatars
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: AppConstants.defaultAvatars.length,
              itemBuilder: (context, index) {
                final avatarName = AppConstants.defaultAvatars[index];
                final isSelected = avatarName == _selectedDefaultAvatar;

                return GestureDetector(
                  onTap: () {
                    _selectDefaultAvatar(avatarName);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Highlight selected avatar
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/images/avatars/$avatarName',
                      ),
                      radius: 35,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Builds upload option card for camera/gallery
  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showAvatarOptions,
      child: Stack(
        children: [
          // Main avatar display
          CircleAvatar(
            radius: 60,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            backgroundImage: _getAvatarImage(),
            child: _getAvatarChild(),
          ),
          // Camera icon overlay
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Determines which image to display based on selection state
  ImageProvider? _getAvatarImage() {
    if (_selectedImagePath != null) {
      return FileImage(File(_selectedImagePath!));
    } else if (_selectedDefaultAvatar != null) {
      return AssetImage('assets/images/avatars/$_selectedDefaultAvatar');
    } else if (widget.currentAvatarUrl != null &&
        widget.currentAvatarUrl!.startsWith('http')) {
      return NetworkImage(widget.currentAvatarUrl!);
    }
    return null;
  }

  /// Returns placeholder icon when no avatar is selected
  Widget? _getAvatarChild() {
    if (_selectedImagePath == null &&
        _selectedDefaultAvatar == null &&
        widget.currentAvatarUrl == null) {
      return const Icon(Icons.person, size: 40);
    }
    return null;
  }
}
