import 'package:flutter/material.dart';
import 'package:procode/config/theme.dart';

/// Reusable app bar widget with consistent styling
/// Maintains visual consistency across all screens in ProCode
/// Implements PreferredSizeWidget for proper scaffold integration
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.elevation = 0, // Flat design by default
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Use custom card color for dark theme consistency
      backgroundColor: AppTheme.cardColor,
      elevation: elevation,
      centerTitle: true, // iOS-style centered title
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      // Custom leading widget or default back button
      leading: leading ??
          (showBackButton
              ? IconButton(
                  // iOS-style back arrow for consistency
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      // Optional action buttons for screen-specific functionality
      actions: actions,
    );
  }

  /// Required by PreferredSizeWidget interface
  /// Returns standard toolbar height for proper layout
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
