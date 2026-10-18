import 'package:flutter/material.dart';

class CyberColors {
  // Backgrounds
  static const Color background = Color(0xFF070B14);
  static const Color surface = Color(0xFF0D1527);
  static const Color cardSurface = Color(0xFF131F37);
  static const Color elevatedSurface = Color(0xFF1A294A);

  // Accents
  static const Color primaryCyan = Color(0xFF00F0FF);
  static const Color electricBlue = Color(0xFF2563EB);
  static const Color neonViolet = Color(0xFF8B5CF6);
  static const Color cyberPink = Color(0xFFEC4899);
  static const Color matrixGreen = Color(0xFF10B981);
  static const Color cyberAmber = Color(0xFFF59E0B);
  static const Color cyberRed = Color(0xFFEF4444);

  // Glassmorphic and Border effects
  static const Color glassFill = Color(0x1400F0FF);
  static const Color glassBorder = Color(0x3300F0FF);
  static const Color glassBorderViolet = Color(0x338B5CF6);
  static const Color subtleDivider = Color(0x1FFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [primaryCyan, neonViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF0D1527), Color(0xFF070B14)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [Color(0x4D00F0FF), Color(0x0000F0FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
