// dart format off

import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/const/constant.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.backgroundColor,

    colorScheme: ColorScheme.fromSeed(
      seedColor:  AppColors.primaryColor,
      primary:    AppColors.primaryColor,
      secondary:  AppColors.secondaryColor,
      error:      AppColors.errorColor,
      surface:    AppColors.cardBackgroundColor,
    ),

    // Cards & sheets — white surfaces on the off-white page
    cardColor: AppColors.cardBackgroundColor,

    // Bottom nav (MainShell) — primary blue for the selected tab
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor:  AppColors.cardBackgroundColor,
      indicatorColor:   AppColors.selectionColor,
    ),

    // FilledButton on login/register screens
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
    ),

    // Text hierarchy — titles vs subtitles/addresses
    textTheme: const TextTheme(
      titleLarge:  TextStyle(color: AppColors.textPrimaryColor),
      titleMedium: TextStyle(color: AppColors.textPrimaryColor),
      bodyMedium:  TextStyle(color: AppColors.textPrimaryColor),
      bodySmall:   TextStyle(color: AppColors.textSecondaryColor),
    ),
  );
}