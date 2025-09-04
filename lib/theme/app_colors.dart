import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF6B46C1);
  static const Color secondaryPurple = Color(0xFF9333EA);
  static const Color lightPurple = Color(0xFFDDD6FE);
  static const Color ultraLightPurple = Color(0xFFF3F0FF);
  
  static const Color dreamBlue = Color(0xFF4F46E5);
  static const Color lightBlue = Color(0xFFE0E7FF);
  
  static const Color starYellow = Color(0xFFFBBF24);
  static const Color sunsetOrange = Color(0xFFEAB308);
  
  static const Color cloudWhite = Color(0xFFFEFEFE);
  static const Color fogGrey = Color(0xFFF9FAFB);
  static const Color mistGrey = Color(0xFFE5E7EB);
  static const Color shadowGrey = Color(0xFF6B7280);
  static const Color nightGrey = Color(0xFF374151);
  
  static const Color dreamPink = Color(0xFFEC4899);
  static const Color lightPink = Color(0xFFFCE7F3);
  
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient dreamGradient = LinearGradient(
    colors: [dreamBlue, dreamPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [starYellow, sunsetOrange, dreamPink],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}