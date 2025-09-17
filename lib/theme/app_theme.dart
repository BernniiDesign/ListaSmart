import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores moderna y cálida
  static const Color _terracotta = Color(0xFFE07A5F); // Terracota principal
  static const Color _sage = Color(0xFF81B29A); // Verde salvia
  static const Color _cream = Color(0xFFF2E9E4); // Crema suave
  static const Color _warmGray = Color(0xFF3D405B); // Gris cálido
  static const Color _charcoal = Color(0xFF1A1B23); // Carbón oscuro
  static const Color _softCoral = Color(0xFFF4A261); // Coral suave
  static const Color _mutedTeal = Color(0xFF264653); // Verde azulado apagado

  static ThemeData get light {
    const seed = _terracotta;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAF9F6), // Blanco cálido
      fontFamily: 'SF Pro Display', // Tipografía moderna (fallback a sistema)
    );
    
    return base.copyWith(
      // Configuración de tipografías modernas y legibles
      textTheme: base.textTheme.copyWith(
        displayLarge: base.textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
          color: _warmGray,
        ),
        displayMedium: base.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: _warmGray,
        ),
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: _warmGray,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: _warmGray,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: _warmGray,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: _warmGray,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.5,
          color: _warmGray,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.4,
          color: _warmGray.withOpacity(0.8),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFAF9F6),
        foregroundColor: _warmGray,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _warmGray,
          letterSpacing: 0,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: _terracotta.withOpacity(0.1),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _cream.withOpacity(0.8),
            width: 1,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _cream, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _cream, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _terracotta, width: 2),
        ),
        labelStyle: TextStyle(
          color: _warmGray.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: _warmGray.withOpacity(0.5),
          fontWeight: FontWeight.w400,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _terracotta,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _terracotta,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _warmGray,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: _softCoral,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _terracotta,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 80,
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _warmGray,
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: _terracotta, size: 24);
          }
          return IconThemeData(color: _warmGray.withOpacity(0.6), size: 24);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(Colors.white),
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _terracotta;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _warmGray,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _warmGray.withOpacity(0.7),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: _cream,
        labelStyle: TextStyle(
          color: _warmGray,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      dividerTheme: DividerThemeData(
        color: _cream,
        thickness: 1,
        space: 1,
      ),

      colorScheme: base.colorScheme.copyWith(
        primary: _terracotta,
        secondary: _sage,
        tertiary: _softCoral,
        surface: Colors.white,
        onSurface: _warmGray,
        surfaceVariant: _cream,
        onSurfaceVariant: _warmGray.withOpacity(0.8),
        outline: _cream.withOpacity(0.8),
        primaryContainer: _cream,
        onPrimaryContainer: _warmGray,
        secondaryContainer: _sage.withOpacity(0.1),
        onSecondaryContainer: _warmGray,
      ),
    );
  }

  static ThemeData get dark {
    const seed = _terracotta;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _charcoal,
      fontFamily: 'SF Pro Display',
    );
    
    return base.copyWith(
      // Tipografías optimizadas para modo oscuro
      textTheme: base.textTheme.copyWith(
        displayLarge: base.textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
          color: _cream,
        ),
        displayMedium: base.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: _cream,
        ),
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: _cream,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: _cream,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: _cream,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: _cream,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.5,
          color: _cream.withOpacity(0.9),
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.4,
          color: _cream.withOpacity(0.7),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _charcoal,
        foregroundColor: _cream,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _cream,
          letterSpacing: 0,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black26,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: _mutedTeal,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _warmGray.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _mutedTeal,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _warmGray.withOpacity(0.3), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _warmGray.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _softCoral, width: 2),
        ),
        labelStyle: TextStyle(
          color: _cream.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: _cream.withOpacity(0.5),
          fontWeight: FontWeight.w400,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _softCoral,
          foregroundColor: _charcoal,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _softCoral,
          foregroundColor: _charcoal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _softCoral,
        contentTextStyle: TextStyle(
          color: _charcoal,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: _terracotta,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _softCoral,
        foregroundColor: _charcoal,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _mutedTeal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 80,
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _cream,
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: _softCoral, size: 24);
          }
          return IconThemeData(color: _cream.withOpacity(0.6), size: 24);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(_charcoal),
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _softCoral;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _cream,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _cream.withOpacity(0.7),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: _warmGray.withOpacity(0.3),
        labelStyle: TextStyle(
          color: _cream,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      dividerTheme: DividerThemeData(
        color: _warmGray.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),

      colorScheme: base.colorScheme.copyWith(
        primary: _softCoral,
        secondary: _sage,
        tertiary: _terracotta,
        surface: _mutedTeal,
        onSurface: _cream,
        surfaceVariant: _warmGray.withOpacity(0.2),
        onSurfaceVariant: _cream.withOpacity(0.8),
        outline: _warmGray.withOpacity(0.4),
        primaryContainer: _warmGray.withOpacity(0.3),
        onPrimaryContainer: _cream,
        secondaryContainer: _sage.withOpacity(0.2),
        onSecondaryContainer: _cream,
      ),
    );
  }

  // Getters para acceder a colores específicos
  static Color get terracotta => _terracotta;
  static Color get sage => _sage;
  static Color get cream => _cream;
  static Color get warmGray => _warmGray;
  static Color get softCoral => _softCoral;
}