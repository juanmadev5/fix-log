import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF00B4DB);
  static const primaryMid = Color(0xFF0085A3);
  static const primaryDark = Color(0xFF003357);

  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Light surface
  static const lightBackground = Color(0xFFF0F9FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFE0F2FE);
  static const lightBorder = Color(0xFFBAE6FD);
  static const lightTextPrimary = Color(0xFF0C1A26);
  static const lightTextSecondary = Color(0xFF4B6478);
  static const lightTextHint = Color(0xFF94A3B8);

  // Dark surface
  static const darkBackground = Color(0xFF001824);
  static const darkSurface = Color(0xFF00253A);
  static const darkSurfaceVariant = Color(0xFF003357);
  static const darkBorder = Color(0xFF005073);
  static const darkTextPrimary = Color(0xFFE0F7FF);
  static const darkTextSecondary = Color(0xFF7EC8E3);
  static const darkTextHint = Color(0xFF4B7A8F);
}
