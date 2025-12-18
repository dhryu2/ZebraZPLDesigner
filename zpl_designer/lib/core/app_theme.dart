import 'package:flutter/material.dart';

/// Modern design system inspired by Figma, Notion, Adobe CC
class AppTheme {
  // Color Palette - Dark Theme (Primary)
  static const Color bgPrimary = Color(0xFF1E1E1E);
  static const Color bgSecondary = Color(0xFF252526);
  static const Color bgTertiary = Color(0xFF2D2D30);
  static const Color bgElevated = Color(0xFF333337);

  // Surface colors
  static const Color surfaceDefault = Color(0xFF3C3C3C);
  static const Color surfaceHover = Color(0xFF4A4A4D);
  static const Color surfaceActive = Color(0xFF505053);
  static const Color surfaceBorder = Color(0xFF474747);

  // Text colors
  static const Color textPrimary = Color(0xFFE4E4E7);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);
  static const Color textDisabled = Color(0xFF52525B);

  // Accent colors
  static const Color accentPrimary = Color(0xFF3B82F6);  // Blue
  static const Color accentHover = Color(0xFF60A5FA);
  static const Color accentSuccess = Color(0xFF22C55E);
  static const Color accentWarning = Color(0xFFF59E0B);
  static const Color accentError = Color(0xFFEF4444);

  // Canvas colors
  static const Color canvasBg = Color(0xFF1A1A1A);
  static const Color canvasGrid = Color(0xFF2A2A2A);
  static const Color canvasPaper = Color(0xFFFFFFFF);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;

  // Border radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;

  // Panel sizes
  static const double leftPanelWidth = 48.0;
  static const double rightPanelWidth = 280.0;
  static const double topBarHeight = 40.0;
  static const double statusBarHeight = 24.0;

  // Typography
  static const TextStyle heading1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  // Input decoration
  static InputDecoration inputDecoration({
    String? label,
    String? hint,
    String? suffix,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      suffixIcon: suffixIcon,
      labelStyle: labelMedium,
      hintStyle: bodySmall.copyWith(color: textTertiary),
      filled: true,
      fillColor: surfaceDefault,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingSm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: surfaceBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: accentPrimary, width: 1.5),
      ),
      isDense: true,
    );
  }

  // Button styles
  static ButtonStyle primaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return surfaceDefault;
      if (states.contains(WidgetState.hovered)) return accentHover;
      return accentPrimary;
    }),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingSm),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
    ),
    elevation: WidgetStateProperty.all(0),
    textStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );

  static ButtonStyle secondaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) return surfaceHover;
      return surfaceDefault;
    }),
    foregroundColor: WidgetStateProperty.all(textPrimary),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingSm),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: const BorderSide(color: surfaceBorder),
      ),
    ),
    elevation: WidgetStateProperty.all(0),
    textStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );

  static ButtonStyle iconButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return accentPrimary.withOpacity(0.2);
      if (states.contains(WidgetState.hovered)) return surfaceHover;
      return Colors.transparent;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return accentPrimary;
      return textSecondary;
    }),
    padding: WidgetStateProperty.all(const EdgeInsets.all(spacingSm)),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
    ),
    minimumSize: WidgetStateProperty.all(const Size(32, 32)),
  );

  // ThemeData
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgPrimary,
    colorScheme: const ColorScheme.dark(
      primary: accentPrimary,
      secondary: accentPrimary,
      surface: bgSecondary,
      error: accentError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgSecondary,
      foregroundColor: textPrimary,
      elevation: 0,
      titleTextStyle: heading1,
    ),
    cardTheme: CardThemeData(
      color: bgSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: surfaceBorder),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: surfaceBorder,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 18,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: bgElevated,
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(color: surfaceBorder),
      ),
      textStyle: bodySmall,
      padding: const EdgeInsets.symmetric(horizontal: spacingSm, vertical: spacingXs),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: bgElevated,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: const BorderSide(color: surfaceBorder),
      ),
      textStyle: bodyMedium,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: bgSecondary,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXl),
      ),
      titleTextStyle: heading1,
      contentTextStyle: bodyMedium,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDefault,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingSm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: surfaceBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: accentPrimary, width: 1.5),
      ),
      labelStyle: labelMedium,
      hintStyle: bodySmall.copyWith(color: textTertiary),
      isDense: true,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDefault,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        isDense: true,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accentPrimary;
        return Colors.transparent;
      }),
      side: const BorderSide(color: textTertiary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: accentPrimary,
      inactiveTrackColor: surfaceDefault,
      thumbColor: accentPrimary,
      overlayColor: accentPrimary.withOpacity(0.2),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(surfaceHover),
      radius: const Radius.circular(radiusSm),
      thickness: WidgetStateProperty.all(6),
    ),
    textTheme: const TextTheme(
      headlineLarge: heading1,
      headlineMedium: heading2,
      bodyLarge: bodyMedium,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelMedium: labelMedium,
    ),
  );
}

// Box decoration helpers
extension AppDecorations on AppTheme {
  static BoxDecoration panel = BoxDecoration(
    color: AppTheme.bgSecondary,
    border: Border.all(color: AppTheme.surfaceBorder),
  );

  static BoxDecoration panelSection = BoxDecoration(
    color: AppTheme.bgTertiary,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
  );

  static BoxDecoration elevated = BoxDecoration(
    color: AppTheme.bgElevated,
    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
    border: Border.all(color: AppTheme.surfaceBorder),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
