import 'package:flutter/material.dart';

const Color colorMainTheme = Color.fromRGBO(51, 11, 54, 1);
Color colorGreen = const Color.fromRGBO(34, 197, 94, 1);
Color colorRedCalendar = const Color.fromRGBO(240, 77, 35, 1);
const Color colorCustomButton = Color.fromRGBO(37, 99, 235, 1);
Color colorWhite = Colors.white;
Color colorGrey = Colors.grey.shade600;
Color colorLightGrey = Colors.grey.shade300;

TextStyle get textStyleHeading => const TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: colorMainTheme,
);

TextStyle get textStyleSubHeading =>
    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorMainTheme);

TextStyle get textStyleBody => TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: Colors.grey.shade700,
);

TextStyle get textStyleCaption => TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  color: Colors.grey.shade600,
);

ButtonStyle get primaryButtonStyle {
  return ElevatedButton.styleFrom(
    backgroundColor: colorMainTheme,
    foregroundColor: colorWhite,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
  );
}

ButtonStyle get secondaryButtonStyle {
  return OutlinedButton.styleFrom(
    foregroundColor: colorMainTheme,
    side: const BorderSide(color: colorMainTheme, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

InputDecoration get inputDecoration {
  final grey300 = Colors.grey.shade300;
  final grey50 = Colors.grey.shade50;
  return InputDecoration(
    filled: true,
    fillColor: grey50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: grey300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: grey300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: colorMainTheme, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorRedCalendar),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorRedCalendar, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}

ChipThemeData get chipTheme {
  final grey100 = Colors.grey.shade100;
  final grey300 = Colors.grey.shade300;
  return ChipThemeData(
    backgroundColor: grey100,
    selectedColor: colorMainTheme.withOpacity(0.2),
    labelStyle: const TextStyle(
      color: colorMainTheme,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: grey300),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );
}
