import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData buildTheme(
    Brightness brightness, {
    required Color primarySeed,
  }) {
    final base = ThemeTokens.tokensToTheme(brightness, seed: primarySeed);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
    );
  }
}
