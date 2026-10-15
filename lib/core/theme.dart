import 'package:flutter/material.dart';

/// Brand palette.
const navy = Color(0xFF03045E);
const blue = Color(0xFF023E8A);
const ice = Color(0xFFCAF0F8);

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: blue, brightness: b).copyWith(
    primary: dark ? ice : blue,
    onPrimary: dark ? navy : Colors.white,
    secondaryContainer: dark ? blue : Color.lerp(ice, blue, .25)!,
    onSecondaryContainer: dark ? ice : navy,
    surface: dark ? navy : ice,
    onSurface: dark ? ice : navy,
    surfaceContainerHighest: dark ? Color.lerp(navy, blue, .45)! : Color.lerp(ice, blue, .14)!,
    surfaceContainerLowest: dark ? Color.lerp(navy, blue, .2)! : Color.lerp(ice, Colors.white, .65)!,
    outlineVariant: dark ? Color.lerp(navy, ice, .25)! : Color.lerp(ice, blue, .3)!,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: 'serif', fontSize: 20, color: scheme.onSurface),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      indicatorColor: scheme.secondaryContainer,
    ),
  );
}
