import 'package:flutter/material.dart';

class AppTheme {
  static const Color oliveGreen = Color(0xFF556B2F);
  static const Color oliveDark = Color(0xFF3B4B20);
  static const Color oliveLight = Color(0xFF6E893F);
  static const Color oliveSoft = Color(0xFFEBF1E3);

  static const Color deepMaroon = Color(0xFF820000);
  static const Color maroonDark = Color(0xFF590000);
  static const Color maroonLight = Color(0xFFA51B1B);
  static const Color maroonSoft = Color(0xFFFCEBEB);

  static const Color textFieldBackground = Color(0xFFFAF0F0);
  static const Color textFieldBorder = Color(0xFFECD8D8);

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color canvasBackground = Color(0xFFF8F9F5);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardSage = Color(0xFFF2F6ED);
  static const Color cardSageDark = Color(0xFFE1E8D9);
  static const Color cardSageLight = Color(0xFFF9FBF7);

  static const Color borderLight = Color(0xFFDCE3D4);
  static const Color borderSubtle = Color(0xFFE9EFE3);

  static const Color textPrimary = Color(0xFF1B2212);
  static const Color textSecondary = Color(0xFF566249);
  static const Color textTertiary = Color(0xFF8B977F);

  static const Color priorityLow = oliveGreen;
  static const Color priorityLowBg = oliveSoft;
  static const Color priorityMedium = Color(0xFFB47D14);
  static const Color priorityMediumBg = Color(0xFFFDF4E2);
  static const Color priorityHigh = deepMaroon;
  static const Color priorityHighBg = maroonSoft;

  static const Color primary = oliveGreen;
  static const Color primaryDark = oliveDark;
  static const Color primaryLight = oliveLight;
  static const Color primarySoft = oliveSoft;
  static const Color secondary = deepMaroon;
  static const Color secondaryDark = maroonDark;
  static const Color secondaryLight = maroonLight;
  static const Color secondarySoft = maroonSoft;
  static const Color scaffoldBackground = canvasBackground;
  static const Color surfaceMuted = textFieldBackground;
  static const Color deleteRed = deepMaroon;
  static const Color deleteRedBg = maroonSoft;

  static const Color goldenCream = cardSage;
  static const Color goldenCreamDark = cardSageDark;
  static const Color goldenCreamLight = cardSageLight;
  static const Color cardBackground = cardSurface;
  static const Color obsidian = oliveGreen;
  static const Color dividerColor = borderLight;
  static const Color textMuted = textTertiary;

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF283618).withValues(alpha: 0.07),
      blurRadius: 18,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get softCardShadow => cardShadow;

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: oliveGreen.withValues(alpha: 0.32),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get secondaryButtonShadow => [
    BoxShadow(
      color: deepMaroon.withValues(alpha: 0.28),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get goldenCardShadow => [
    BoxShadow(
      color: const Color(0xFF283618).withValues(alpha: 0.09),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.light,
      primaryColor: oliveGreen,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: const ColorScheme.light(
        primary: oliveGreen,
        onPrimary: pureWhite,
        secondary: deepMaroon,
        onSecondary: pureWhite,
        surface: cardSurface,
        onSurface: textPrimary,
        error: deepMaroon,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.8,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: pureWhite,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: deepMaroon,
        foregroundColor: pureWhite,
        elevation: 6,
        shape: CircleBorder(),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: pureWhite,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Local typography helper using only pre-bundled Inter font files from assets.
/// Zero network requests or Google Server font fetching.
class AppFonts {
  static const String fontFamily = 'Inter';

  static TextStyle inter({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final style = TextStyle(
      fontFamily: fontFamily,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
    return textStyle != null ? textStyle.merge(style) : style;
  }
}

/// Alias mapping GoogleFonts to local AppFonts so no remote font calls are ever made
typedef GoogleFonts = AppFonts;
