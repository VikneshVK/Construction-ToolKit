import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radii.dart';

/// ThemeData generator for BuildCalc adhering to DESIGN.md.
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgCanvas,
      canvasColor: AppColors.bgCanvas,
      cardColor: AppColors.bgSurface,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandGold,
        onPrimary: AppColors.textInverse,
        surface: AppColors.bgSurface,
        onSurface: AppColors.textPrimary,
        error: AppColors.statusError,
        onError: AppColors.textPrimary,
        outline: AppColors.borderSubtle,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgCanvas,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.screenTitle,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.brandGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(color: AppColors.statusError, width: 1.0),
        ),
        labelStyle: AppTypography.fieldLabel,
        hintStyle: AppTypography.helperText,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGold,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonRadius),
          textStyle: AppTypography.buttonPrimary,
          minimumSize: const Size.fromHeight(54),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonRadius),
          textStyle: AppTypography.buttonSecondary,
          minimumSize: const Size.fromHeight(48),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}
