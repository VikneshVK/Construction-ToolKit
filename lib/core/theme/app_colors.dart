import 'package:flutter/material.dart';

/// Central color token system for BuildCalc adhering to DESIGN.md.
/// High-contrast jobsite theme designed for outdoor sunlight legibility and OLED efficiency.
class AppColors {
  // Canvas & Surfaces
  static const Color bgCanvas = Color(0xFF0F1115);    // Deep Matte Void
  static const Color bgSurface = Color(0xFF181C22);   // Steel Charcoal (Cards & Containers)
  static const Color bgElevated = Color(0xFF222831);  // Gunmetal Gray (Inputs & Elevators)
  static const Color bgInput = Color(0xFF1E242C);     // Input field base
  
  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF303844); // 1px clean tool edge
  static const Color borderFocused = Color(0xFFD4AF37); // Gold focus ring
  static const Color borderLight = Color(0xFF3F4B5A);

  // Semantic Color Role System:
  // - Gold: Active / selected / interactive only (Selected tabs, active presets, sliders, interactive controls)
  // - Green: Pass / success / recommended (Code PASS, successful checks, positive recommendations)
  // - Blue: Technical information (Technical/calculated reference information and diagram guidance)
  // - White: Primary result (Main calculated number and highest-priority output)
  // - Gray: Secondary information (Labels, descriptions, supporting values)

  // Interactive / Active (Gold only)
  static const Color brandGold = Color(0xFFD4AF37);       // Safety Gold / Active State
  static const Color brandGoldHover = Color(0xFFE5B824);  // Pressed / Active
  static const Color brandGoldMuted = Color(0x33D4AF37);  // 20% tint for active chips

  // Technical Information & Blueprint Reference (Blue)
  static const Color technicalBlue = Color(0xFF38BDF8);   // Technical/calculated reference & diagrams
  static const Color technicalBlueBg = Color(0x2638BDF8); // 15% tint for technical info badges
  static const Color technicalBlueDark = Color(0xFF0284C7);

  // Typography & Readout Colors
  static const Color textPrimary = Color(0xFFF5F7FA);   // Crisp Chalk White (Primary results & high-priority text)
  static const Color textSecondary = Color(0xFF9CA3AF); // High-legibility neutral gray (Labels, descriptions, supporting values)
  static const Color textMuted = Color(0xFF6B7280);     // Timestamps, subtle subtext
  static const Color textInverse = Color(0xFF0F1115);   // On gold background

  // Category Tints
  static const Color categoryMaterials = Color(0xFFFF7849); // Safety Orange / Brick
  static const Color categoryRoofing = Color(0xFF38BDF8);   // Sky Blueprint Blue
  static const Color categoryStairs = Color(0xFFA855F7);    // Precision Violet
  static const Color categoryMeasurements = Color(0xFF10B981); // Machinist Emerald

  // Semantic Status Tints
  static const Color statusSuccess = Color(0xFF22C55E);  // Compliance Pass / Recommended (Green)
  static const Color statusSuccessBg = Color(0x2622C55E);
  
  static const Color statusWarning = Color(0xFFF59E0B);  // Code Limit / Advisory (Amber)
  static const Color statusWarningBg = Color(0x26F59E0B);
  
  static const Color statusError = Color(0xFFEF4444);    // Invalid Geometry / Danger (Red)
  static const Color statusErrorBg = Color(0x26EF4444);
}
