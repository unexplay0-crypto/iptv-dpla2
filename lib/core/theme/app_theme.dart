import 'package:flutter/material.dart';
import '../constants.dart';

/// Identidade visual "Aurora": fundo espaco profundo, acento em gradiente
/// ciano -> violeta (unico vs vermelho Netflix/YouTube), superficies
/// translucidas (glassmorphism), foco com brilho gradiente.
class AuroraColors {
  AuroraColors._();
  static const Color background = Color(0xFF070B14);
  static const Color surface = Color(0xFF0F1626);
  static const Color surfaceElevated = Color(0xFF16203A);
  static const Color onSurface = Color(0xFFE8ECF5);
  static const Color onSurfaceMuted = Color(0xFF8A94A8);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentViolet = Color(0xFF7C4DFF);
  static const Color accentMagenta = Color(0xFFFF2D92);
  static const Color glass = Color(0x1AFFFFFF);
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentCyan, accentViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F1626), Color(0x000F1626)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData dark({required bool isTv}) {
    final base = ThemeData.dark(useMaterial3: true);
    final scale = isTv ? 1.18 : 1.0;
    return base.copyWith(
      scaffoldBackgroundColor: AuroraColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AuroraColors.accentCyan,
        onPrimary: Color(0xFF070B14),
        secondary: AuroraColors.accentViolet,
        surface: AuroraColors.surface,
        surfaceVariant: AuroraColors.surfaceElevated,
        onSurface: AuroraColors.onSurface,
        onSurfaceVariant: AuroraColors.onSurfaceMuted,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AuroraColors.onSurface,
      ),
      cardTheme: CardThemeData(
        color: AuroraColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      textTheme: base.textTheme.apply(
        fontSizeFactor: scale,
        bodyColor: AuroraColors.onSurface,
        displayColor: AuroraColors.onSurface,
      ),
      focusColor: AuroraColors.accentCyan,
      highlightColor: AuroraColors.accentCyan.withOpacity(0.2),
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AuroraColors.accentCyan,
          foregroundColor: const Color(0xFF070B14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AuroraColors.surface,
        hintStyle: const TextStyle(color: AuroraColors.onSurfaceMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AuroraColors.accentCyan, width: 2),
        ),
      ),
    );
  }

  static BoxDecoration focusDecoration(bool focused, {double radius = 20}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: focused ? AuroraColors.accentGradient : null,
      border: focused
          ? null
          : Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      boxShadow: focused
          ? [
              BoxShadow(
                color: AuroraColors.accentCyan.withOpacity(0.45),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ]
          : null,
    );
  }

  static BoxDecoration get screenBackground => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1424), AuroraColors.background],
          stops: [0.0, 0.35],
        ),
      );

  static const double tvBody = AppConstants.tvBodyFont;
  static const double tvTitle = AppConstants.tvTitleFont;
}
