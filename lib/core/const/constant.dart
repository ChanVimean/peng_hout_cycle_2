// dart format off

import 'package:flutter/material.dart';

// ============================================================
// Colors
// ============================================================
class AppColors {
  static const Color primaryColor         = Color(0xFF00A3FF); // Blue — brand primary
  static const Color secondaryColor       = Color(0xFF7F77DD); // Purple light — hover / accent
  static const Color backgroundColor      = Color(0xFFF4F4F8); // Off-white — page background
  static const Color cardBackgroundColor  = Color(0xFFFFFFFF); // White — card / surface
  static const Color selectionColor       = Color(0xFFEEEDFE); // Purple tint — selected item bg

  // Status Colors
  static const Color errorColor           = Color(0xFFEF4444); // Red — error / station over capacity
  static const Color warnColor            = Color(0xFFF59E0B); // Amber — low battery / almost full station
  static const Color successColor         = Color(0xFF22C55E); // Green — station normal / bike available

  // Status tints (backgrounds behind icons — replaces Colors.green.shade100 etc.)
  static const Color successBgColor       = Color(0xFFDCFCE7); // Green tint — available bike avatar
  static const Color errorBgColor         = Color(0xFFFEE2E2); // Red tint — over-capacity avatar

  // Text
  static const Color textPrimaryColor     = Color(0xFF1F2937); // Near-black — titles
  static const Color textSecondaryColor   = Color(0xFF6B7280); // Grey — subtitles, addresses, disabled
}

// ============================================================
// Font Sizes
// ============================================================
class AppFontSizes {
  static const double fontSizeXS  = 10;
  static const double fontSizeSM  = 12;
  static const double fontSizeMD  = 14; // body default
  static const double fontSizeLG  = 16;
  static const double fontSizeXL  = 20;
  static const double fontSize2XL = 24;
  static const double fontSize3XL = 32;
}

// ============================================================
// Font Weights
// ============================================================
class AppFontWeights {
  static const FontWeight fontWeightThin      = FontWeight.w300;
  static const FontWeight fontWeightRegular   = FontWeight.w400; // Default
  static const FontWeight fontWeightMedium    = FontWeight.w500;
  static const FontWeight fontWeightSemiBold  = FontWeight.w600;
  static const FontWeight fontWeightBold      = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w900;
}

// ============================================================
// Spacing
// ============================================================
class AppSpacing {
  static const double extraSmallPadding = 4;
  static const double smallPadding      = 8;
  static const double mediumPadding     = 12;
  static const double defaultPadding    = 16;
  static const double largePadding      = 24;
  static const double extraLargePadding = 32;
}

// ============================================================
// Border Radius
// ============================================================
class AppRadius {
  static const double radiusXS   = 4;
  static const double radiusSM   = 6;
  static const double radiusMD   = 10;
  static const double radiusLG   = 14;
  static const double radiusXL   = 20;
  static const double radiusFull = 100; // Circle
}
