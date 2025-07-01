import 'package:flutter/material.dart';
import 'package:procode/config/app_colors.dart';

enum ButtonType { primary, secondary, outline, text, gradient }

enum ButtonSize { small, medium, large }

// Add this enum for backward compatibility with auth screens
enum ButtonVariant { primary, secondary, outline, text, gradient }

// Extension method to convert ButtonVariant to ButtonType
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

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType? type; // Make nullable
  final ButtonVariant? variant; // Add this
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
    this.variant, // Add this
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
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    // Use variant if provided, otherwise use type, default to primary
    final buttonType = variant?.toButtonType ?? type ?? ButtonType.primary;

    return SizedBox(
      width: width,
      height: _getHeight(),
      child: buttonType == ButtonType.gradient
          ? _buildGradientButton(context, theme, isEnabled)
          : _buildRegularButton(context, theme, isEnabled, buttonType),
    );
  }

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

  Widget _buildButtonContent(ThemeData theme, Color textColor) {
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

    if (icon == null) {
      return textWidget;
    }

    final iconWidget = IconTheme(
      data: IconThemeData(
        size: _getIconSize(),
        color: textColor,
      ),
      child: icon!,
    );

    final spacing = SizedBox(width: size == ButtonSize.small ? 4 : 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconOnRight
          ? [textWidget, spacing, iconWidget]
          : [iconWidget, spacing, textWidget],
    );
  }

  ButtonStyle _getElevatedButtonStyle(ThemeData theme) {
    return ElevatedButton.styleFrom(
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      ),
      elevation: 0,
    );
  }

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

  ButtonStyle _getTextButtonStyle(ThemeData theme) {
    return TextButton.styleFrom(
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      ),
    );
  }

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

// Convenience constructors
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
