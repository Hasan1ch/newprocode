import 'package:flutter/material.dart';
import 'package:procode/config/app_colors.dart';

enum GradientType { linear, radial, sweep }

enum GradientDirection { horizontal, vertical, diagonal, diagonalReverse }

class GradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final GradientType type;
  final GradientDirection direction;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final AlignmentGeometry? center;
  final double? radius;
  final double? startAngle;
  final double? endAngle;
  final List<double>? stops;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final BlendMode? blendMode;
  final TileMode tileMode;

  const GradientContainer({
    super.key,
    required this.child,
    this.colors,
    this.type = GradientType.linear,
    this.direction = GradientDirection.vertical,
    this.begin,
    this.end,
    this.center,
    this.radius,
    this.startAngle,
    this.endAngle,
    this.stops,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.border,
    this.boxShadow,
    this.blendMode,
    this.tileMode = TileMode.clamp,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ?? [AppColors.primary, AppColors.primaryDark];

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: _buildGradient(gradientColors),
        borderRadius: shape == BoxShape.circle ? null : borderRadius,
        shape: shape,
        border: border,
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }

  Gradient _buildGradient(List<Color> colors) {
    switch (type) {
      case GradientType.linear:
        return LinearGradient(
          colors: colors,
          begin: begin ?? _getBeginAlignment(),
          end: end ?? _getEndAlignment(),
          stops: stops,
          tileMode: tileMode,
        );
      case GradientType.radial:
        return RadialGradient(
          colors: colors,
          center: center ?? Alignment.center,
          radius: radius ?? 0.5,
          stops: stops,
          tileMode: tileMode,
        );
      case GradientType.sweep:
        return SweepGradient(
          colors: colors,
          center: center ?? Alignment.center,
          startAngle: startAngle ?? 0.0,
          endAngle: endAngle ?? 3.14 * 2,
          stops: stops,
          tileMode: tileMode,
        );
    }
  }

  AlignmentGeometry _getBeginAlignment() {
    switch (direction) {
      case GradientDirection.horizontal:
        return Alignment.centerLeft;
      case GradientDirection.vertical:
        return Alignment.topCenter;
      case GradientDirection.diagonal:
        return Alignment.topLeft;
      case GradientDirection.diagonalReverse:
        return Alignment.topRight;
    }
  }

  AlignmentGeometry _getEndAlignment() {
    switch (direction) {
      case GradientDirection.horizontal:
        return Alignment.centerRight;
      case GradientDirection.vertical:
        return Alignment.bottomCenter;
      case GradientDirection.diagonal:
        return Alignment.bottomRight;
      case GradientDirection.diagonalReverse:
        return Alignment.bottomLeft;
    }
  }
}

// Specialized Gradient Containers
class PrimaryGradientContainer extends GradientContainer {
  const PrimaryGradientContainer({
    super.key,
    required super.child,
    super.direction = GradientDirection.horizontal,
    super.padding,
    super.margin,
    super.width,
    super.height,
    super.borderRadius,
    super.boxShadow,
  }) : super(
          colors: const [AppColors.primary, AppColors.primaryDark],
        );
}

class SecondaryGradientContainer extends GradientContainer {
  const SecondaryGradientContainer({
    super.key,
    required super.child,
    super.direction = GradientDirection.horizontal,
    super.padding,
    super.margin,
    super.width,
    super.height,
    super.borderRadius,
    super.boxShadow,
  }) : super(
          colors: const [AppColors.secondary, AppColors.secondaryLight],
        );
}

class SuccessGradientContainer extends GradientContainer {
  const SuccessGradientContainer({
    super.key,
    required super.child,
    super.direction = GradientDirection.horizontal,
    super.padding,
    super.margin,
    super.width,
    super.height,
    super.borderRadius,
    super.boxShadow,
  }) : super(
          colors: const [AppColors.success, Color(0xFF66BB6A)],
        );
}

// Gradient Card
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final GradientDirection direction;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double elevation;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.colors,
    this.direction = GradientDirection.diagonal,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.elevation = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      colors: colors,
      direction: direction,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: (colors?.first ?? AppColors.primary).withOpacity(0.3),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation),
        ),
      ],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}

// Gradient Background
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final GradientType type;
  final GradientDirection direction;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.type = GradientType.linear,
    this.direction = GradientDirection.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      colors: colors,
      type: type,
      direction: direction,
      width: double.infinity,
      height: double.infinity,
      child: child,
    );
  }
}

// Gradient AppBar
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final List<Color>? colors;
  final double elevation;
  final bool centerTitle;

  const GradientAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.colors,
    this.elevation = 0,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: AppBar(
        title: title != null
            ? Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
        leading: leading,
        actions: actions,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}

// Gradient Icon
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color>? colors;
  final GradientDirection direction;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.colors,
    this.direction = GradientDirection.diagonal,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ?? [AppColors.primary, AppColors.primaryDark];

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: gradientColors,
          begin: _getBeginAlignment(),
          end: _getEndAlignment(),
        ).createShader(bounds);
      },
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }

  AlignmentGeometry _getBeginAlignment() {
    switch (direction) {
      case GradientDirection.horizontal:
        return Alignment.centerLeft;
      case GradientDirection.vertical:
        return Alignment.topCenter;
      case GradientDirection.diagonal:
        return Alignment.topLeft;
      case GradientDirection.diagonalReverse:
        return Alignment.topRight;
    }
  }

  AlignmentGeometry _getEndAlignment() {
    switch (direction) {
      case GradientDirection.horizontal:
        return Alignment.centerRight;
      case GradientDirection.vertical:
        return Alignment.bottomCenter;
      case GradientDirection.diagonal:
        return Alignment.bottomRight;
      case GradientDirection.diagonalReverse:
        return Alignment.bottomLeft;
    }
  }
}

// Gradient Text
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color>? colors;
  final GradientDirection direction;
  final TextAlign? textAlign;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.colors,
    this.direction = GradientDirection.horizontal,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = colors ?? [AppColors.primary, AppColors.primaryDark];

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: gradientColors,
          begin: _getBeginAlignment(),
          end: _getEndAlignment(),
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: (style ?? theme.textTheme.bodyLarge)?.copyWith(
          color: Colors.white,
        ),
        textAlign: textAlign,
      ),
    );
  }

  AlignmentGeometry _getBeginAlignment() {
    switch (direction) {
      case GradientDirection.horizontal:
        return Alignment.centerLeft;
      case GradientDirection.vertical:
        return Alignment.topCenter;
      case GradientDirection.diagonal:
        return Alignment.topLeft;
      case GradientDirection.diagonalReverse:
        return Alignment.topRight;
    }
  }

  AlignmentGeometry _getEndAlignment() {
    switch (direction) {
      case GradientDirection.horizontal:
        return Alignment.centerRight;
      case GradientDirection.vertical:
        return Alignment.bottomCenter;
      case GradientDirection.diagonal:
        return Alignment.bottomRight;
      case GradientDirection.diagonalReverse:
        return Alignment.bottomLeft;
    }
  }
}
