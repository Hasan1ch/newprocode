import 'package:flutter/material.dart';
import 'package:procode/config/app_colors.dart';

/// Button style variations for different use cases
enum ButtonType { primary, secondary, outline, text, gradient }

/// Predefined button sizes for consistency
enum ButtonSize { small, medium, large }

/// Legacy enum for backward compatibility with existing code
enum ButtonVariant { primary, secondary, outline, text, gradient }

/// Extension to convert legacy ButtonVariant to new ButtonType
/// Maintains compatibility while migrating to new API
extension ButtonVariantExtension on ButtonVariant {
  ButtonType get toButtonType {
    switch (this) {
      case ButtonVariant.primary:
        return ButtonType.primary;
      case ButtonVariant.secondary:
        return ButtonType.secondary;
      case ButtonVariant.outline:
        return ButtonType.outline;
      case ButtonVariant.text:
        return ButtonType.text;
      case ButtonVariant.gradient:
        return ButtonType.gradient;
    }
  }
}

/// Highly customizable button widget used throughout the app
/// Supports multiple styles, sizes, loading states, and icons
/// This is the foundation for all buttons in ProCode
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType? type; // New API
  final ButtonVariant? variant; // Legacy API support
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final bool iconOnRight;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type,
    this.variant, // Support both APIs
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconOnRight = false,
    this.width,
    this.padding,
    this.borderRadius,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine if button should be interactive
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    // Use variant if provided (legacy), otherwise use type, default to primary
    final buttonType = variant?.toButtonType ?? type ?? ButtonType.primary;

    return SizedBox(
      width: width,
      height: _getHeight(),
      child: buttonType == ButtonType.gradient
          ? _buildGradientButton(context, theme, isEnabled)
          : _buildRegularButton(context, theme, isEnabled, buttonType),
    );
  }

  /// Builds standard Material button types
  Widget _buildRegularButton(BuildContext context, ThemeData theme,
      bool isEnabled, ButtonType buttonType) {
    switch (buttonType) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getElevatedButtonStyle(theme),
          child: _buildButtonContent(theme, Colors.white),
        );

      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getSecondaryButtonStyle(theme),
          child: _buildButtonContent(theme, Colors.white),
        );

      case ButtonType.outline:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getOutlinedButtonStyle(theme),
          child: _buildButtonContent(theme, theme.colorScheme.primary),
        );

      case ButtonType.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getTextButtonStyle(theme),
          child: _buildButtonContent(theme, theme.colorScheme.primary),
        );

      default:
        return const SizedBox();
    }
  }

  /// Builds gradient button with custom decoration
  /// Used for CTAs and special actions
  Widget _buildGradientButton(
      BuildContext context, ThemeData theme, bool isEnabled) {
    final colors = gradientColors ?? AppColors.primaryGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isEnabled ? colors : [Colors.grey.shade400, Colors.grey.shade600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
        // Shadow for depth effect
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius:
              borderRadius ?? BorderRadius.circular(_getBorderRadius()),
          child: Padding(
            padding: padding ?? _getPadding(),
            child: _buildButtonContent(theme, Colors.white),
          ),
        ),
      ),
    );
  }

  /// Builds button content with text, icon, and loading state
  Widget _buildButtonContent(ThemeData theme, Color textColor) {
    // Show loading spinner when loading
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: _getTextStyle(theme).copyWith(color: textColor),
      textAlign: TextAlign.center,
    );

    // Return just text if no icon
    if (icon == null) {
      return textWidget;
    }

    // Configure icon theme
    final iconWidget = IconTheme(
      data: IconThemeData(
        size: _getIconSize(),
        color: textColor,
      ),
      child: icon!,
    );

    final spacing = SizedBox(width: size == ButtonSize.small ? 4 : 8);

    // Arrange icon and text based on iconOnRight
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconOnRight
          ? [textWidget, spacing, iconWidget]
          : [iconWidget, spacing, textWidget],
    );
  }

  /// Primary button style configuration
  ButtonStyle _getElevatedButtonStyle(ThemeData theme) {
    return ElevatedButton.styleFrom(
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      ),
      elevation: 0, // Flat design
    );
  }

  /// Secondary button style configuration
  ButtonStyle _getSecondaryButtonStyle(ThemeData theme) {
    return ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.secondary,
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      ),
      elevation: 0,
    );
  }

  /// Outlined button style configuration
  ButtonStyle _getOutlinedButtonStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      ),
      side: BorderSide(
        color: theme.colorScheme.primary,
        width: 1.5,
      ),
    );
  }

  /// Text button style configuration
  ButtonStyle _getTextButtonStyle(ThemeData theme) {
    return TextButton.styleFrom(
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      ),
    );
  }

  /// Returns height based on button size
  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  /// Returns padding based on button size
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  /// Returns border radius based on button size
  double _getBorderRadius() {
    switch (size) {
      case ButtonSize.small:
        return 8;
      case ButtonSize.medium:
        return 12;
      case ButtonSize.large:
        return 16;
    }
  }

  /// Returns text style based on button size
  TextStyle _getTextStyle(ThemeData theme) {
    switch (size) {
      case ButtonSize.small:
        return theme.textTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.w600,
        );
      case ButtonSize.medium:
        return theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
        );
      case ButtonSize.large:
        return theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w600,
        );
    }
  }

  /// Returns icon size based on button size
  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

/// Convenience widget for primary buttons
/// Reduces boilerplate for common button type
class PrimaryButton extends CustomButton {
  const PrimaryButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? icon,
    bool iconOnRight = false,
    ButtonSize size = ButtonSize.medium,
    double? width,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          type: ButtonType.primary,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          icon: icon,
          iconOnRight: iconOnRight,
          width: width,
        );
}

/// Convenience widget for secondary buttons
class SecondaryButton extends CustomButton {
  const SecondaryButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? icon,
    bool iconOnRight = false,
    ButtonSize size = ButtonSize.medium,
    double? width,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          type: ButtonType.secondary,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          icon: icon,
          iconOnRight: iconOnRight,
          width: width,
        );
}

/// Convenience widget for outline buttons
class OutlineButton extends CustomButton {
  const OutlineButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? icon,
    bool iconOnRight = false,
    ButtonSize size = ButtonSize.medium,
    double? width,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          type: ButtonType.outline,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          icon: icon,
          iconOnRight: iconOnRight,
          width: width,
        );
}

/// Convenience widget for text buttons
class TextButtonCustom extends CustomButton {
  const TextButtonCustom({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? icon,
    bool iconOnRight = false,
    ButtonSize size = ButtonSize.medium,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          type: ButtonType.text,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          icon: icon,
          iconOnRight: iconOnRight,
        );
}

/// Convenience widget for gradient buttons
/// Used for primary CTAs and special actions
class GradientButton extends CustomButton {
  const GradientButton({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? icon,
    bool iconOnRight = false,
    ButtonSize size = ButtonSize.medium,
    double? width,
    List<Color>? gradientColors,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          type: ButtonType.gradient,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          icon: icon,
          iconOnRight: iconOnRight,
          width: width,
          gradientColors: gradientColors,
        );
}
