import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/widgets/app_text.dart';

enum ButtonVariant { outline, filled, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final ButtonVariant variant;
  final IconData? icon;
  final double? width;
  final bool isLoading;
  final Color? color;
  final Color? textColor;

  const AppButton(
    this.text, {
    super.key,
    required this.onTap,
    this.variant = ButtonVariant.filled, // Default: .filled
    this.icon,
    this.width,
    this.isLoading = false,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDisabled = onTap == null || isLoading;

    // Determine Background Colors based on Variant
    Color getBgColor() {
      if (isDisabled) return theme.disabledColor.withAlpha(20);

      switch (variant) {
        case ButtonVariant.filled:
          return color ?? theme.colorScheme.primary;
        case ButtonVariant.outline:
        case ButtonVariant.text:
          return Colors.transparent;
      }
    }

    // Determine Content Colors based on Variant
    Color getContentColor() {
      if (isDisabled) return theme.disabledColor;

      switch (variant) {
        case ButtonVariant.filled:
          return textColor ?? theme.colorScheme.onPrimary;
        case ButtonVariant.outline:
        case ButtonVariant.text:
          return textColor ?? color ?? theme.colorScheme.onSurface;
      }
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: getBgColor(),
              borderRadius: BorderRadius.circular(12),
              border: variant == ButtonVariant.outline
                  ? Border.all(color: getContentColor())
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: getContentColor(),
                      ),
                    )
                  : Row(
                      spacing: 8.0,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null)
                          Icon(icon, color: getContentColor(), size: 20),
                        AppText(
                          text,
                          variant: TextVariant.big,
                          fontWeight: FontWeight.w600,
                          color: getContentColor(),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
