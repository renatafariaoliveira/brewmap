import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BrewMap theme entrypoint.
///
/// This file centralizes:
/// - Theme builders (light/dark)
/// - Semantic color tokens via [BrewColors] (ThemeExtension)
/// - Brand colors and typography constants

ThemeData buildBrewDarkTheme() {
  return _buildBrewTheme(colors: BrewColors.dark, brightness: Brightness.dark);
}

ThemeData buildBrewLightTheme() {
  return _buildBrewTheme(colors: BrewColors.light, brightness: Brightness.light);
}

ThemeData _buildBrewTheme({
  required BrewColors colors,
  required Brightness brightness,
}) {
  final base =
      brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();

  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: colors.background,
    colorScheme: (brightness == Brightness.dark
        ? ColorScheme.dark(
            surface: colors.surface,
            onSurface: colors.textPrimary,
            primary: kAccent,
            onPrimary: colors.onAccent,
          )
        : ColorScheme.light(
            surface: colors.surface,
            onSurface: colors.textPrimary,
            primary: kAccent,
            onPrimary: colors.onAccent,
          )),
    extensions: <ThemeExtension<dynamic>>[colors],
    textTheme: GoogleFonts.dmSansTextTheme(base.textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor:
          brightness == Brightness.dark ? colors.surfaceElevated : colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kAccent, width: 1.5),
      ),
      hintStyle: TextStyle(color: colors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerColor: colors.border,
  );
}

/// Semantic app colors that change between light and dark themes.
///
/// Prefer using `context.brewColors` in widgets instead of hardcoded colors.
@immutable
class BrewColors extends ThemeExtension<BrewColors> {
  const BrewColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHover,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.selectedItem,
    required this.chipSelected,
    required this.onAccent,
    required this.mapBackground,
    required this.mapTileUrlTemplate,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceHover;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color selectedItem;
  final Color chipSelected;
  final Color onAccent;
  final Color mapBackground;
  final String mapTileUrlTemplate;

  static const BrewColors dark = BrewColors(
    background: Color(0xFF1A1A1A),
    surface: Color(0xFF242424),
    surfaceElevated: Color(0xFF2E2E2E),
    surfaceHover: Color(0xFF3A3A3A),
    textPrimary: Color(0xFFF0F0F0),
    textSecondary: Color(0xFF9A9A9A),
    border: Color(0xFF363636),
    selectedItem: Color(0xFF2A2A2A),
    chipSelected: Color(0xFF3A2800),
    onAccent: Color(0xFF1A1A1A),
    mapBackground: Color(0xFF1A1A1A),
    mapTileUrlTemplate:
        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
  );

  static const BrewColors light = BrewColors(
    background: Color(0xFFF0ECE4),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE8E4DC),
    surfaceHover: Color(0xFFD8D4CC),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF9A9A9A),
    border: Color(0xFFD4CFC4),
    selectedItem: Color(0xFFEDE9E1),
    chipSelected: Color(0xFFFFF3D6),
    onAccent: Color(0xFF1A1A1A),
    mapBackground: Color(0xFFE8E4DC),
    mapTileUrlTemplate:
        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
  );

  @override
  BrewColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceHover,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? selectedItem,
    Color? chipSelected,
    Color? onAccent,
    Color? mapBackground,
    String? mapTileUrlTemplate,
  }) {
    return BrewColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      selectedItem: selectedItem ?? this.selectedItem,
      chipSelected: chipSelected ?? this.chipSelected,
      onAccent: onAccent ?? this.onAccent,
      mapBackground: mapBackground ?? this.mapBackground,
      mapTileUrlTemplate: mapTileUrlTemplate ?? this.mapTileUrlTemplate,
    );
  }

  @override
  BrewColors lerp(BrewColors? other, double t) {
    if (other == null) return this;
    return BrewColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      selectedItem: Color.lerp(selectedItem, other.selectedItem, t)!,
      chipSelected: Color.lerp(chipSelected, other.chipSelected, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      mapBackground: Color.lerp(mapBackground, other.mapBackground, t)!,
      mapTileUrlTemplate:
          t < 0.5 ? mapTileUrlTemplate : other.mapTileUrlTemplate,
    );
  }
}

extension BrewColorsContext on BuildContext {
  BrewColors get brewColors {
    final ext = Theme.of(this).extension<BrewColors>();
    assert(
      ext != null,
      'BrewColors ThemeExtension not found. '
      'Make sure your ThemeData includes extensions: [BrewColors.light/dark].',
    );
    if (ext != null) return ext;

    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? BrewColors.dark : BrewColors.light;
  }
}

// Colors

const Color kAccent = Color(0xFFE8A020);
const Color kAccentDark = Color(0xffe8872b);
const Color kMicroColor = Color(0xFF2E7D32);
const Color kBrewpubColor = Color(0xFF1565C0);
const Color kRegionalColor = Color(0xFF6A1B9A);
const Color kLargeColor = Color(0xFFBF360C);

// Font Family

const kLogoFont = 'PlayfairDisplay';
const kHeadingFont = 'DMSans';
const kBodyFont = 'Inter';
const kMonoFont = 'DMMono';

// Typography

const kBrandTitleTextStyle = TextStyle(
  fontFamily: kLogoFont,
  fontSize: 26,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.3,
);

const kHeadingTextStyle = TextStyle(
  fontFamily: kLogoFont,
  fontSize: 20,
  fontWeight: FontWeight.w700,
);

const kBodyTextStyle = TextStyle(fontFamily: kHeadingFont, fontSize: 14);

const kMonoTextStyle = TextStyle(
  fontFamily: kMonoFont,
  fontSize: 12,
  fontWeight: FontWeight.w600,
);
