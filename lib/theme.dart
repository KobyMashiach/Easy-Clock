// ignore_for_file: deprecated_member_use

import 'package:easy_clock/models/data_models/alarm_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'constants.dart';

// Our light/Primary Theme

Color changeColor = kPrimaryColor;

ThemeData themeData(BuildContext context) {
  return ThemeData(
    appBarTheme: appBarLightTheme,
    primaryColor: changeColor,
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Colors.white,
    iconTheme: const IconThemeData(color: kBodyTextColorLight),
    primaryIconTheme: const IconThemeData(color: kPrimaryIconLightColor),
    textTheme: GoogleFonts.latoTextTheme().copyWith(
      bodyText1: const TextStyle(color: kBodyTextColorLight),
      bodyText2: const TextStyle(color: kBodyTextColorLight),
      headline4: const TextStyle(color: kTitleTextLightColor, fontSize: 32),
      headline1: const TextStyle(color: kTitleTextLightColor, fontSize: 80),
    ),
    colorScheme: ColorScheme.light(
      secondary: kSecondaryLightColor,
      secondaryContainer: kAccentLightColor,
      primary: changeColor,
      onPrimary: Colors.white,
      // on light theme surface = Colors.white by default
    ),
  );
}

// Dark Them
ThemeData darkThemeData(BuildContext context) {
  return ThemeData.dark().copyWith(
    primaryColor: changeColor,
    scaffoldBackgroundColor: const Color(0xFF0D0C0E),
    appBarTheme: appBarDarkTheme,
    backgroundColor: kBackgroundDarkColor,
    iconTheme: const IconThemeData(color: kBodyTextColorDark),
    primaryIconTheme: const IconThemeData(color: kPrimaryIconDarkColor),
    textTheme: GoogleFonts.latoTextTheme().copyWith(
      bodyText1: const TextStyle(color: kBodyTextColorDark),
      bodyText2: const TextStyle(color: kBodyTextColorDark),
      headline4: const TextStyle(color: kTitleTextDarkColor, fontSize: 32),
      headline1: const TextStyle(color: kTitleTextDarkColor, fontSize: 80),
    ),
    colorScheme: ColorScheme.dark(
      secondary: kSecondaryDarkColor,
      secondaryContainer: kAccentDarkColor,
      surface: kSurfaceDarkColor,
      onSurface: Colors.white,
      primary: changeColor,
      onPrimary: kBackgroundDarkColor,
    ),
  );
}

AppBarTheme appBarLightTheme = AppBarTheme(
  // affect the color of SystemUI
  color: Colors.white.withOpacity(0),
  elevation: 0,
);
AppBarTheme appBarDarkTheme = AppBarTheme(
  // affect the color of SystemUI
  color: Colors.black.withOpacity(0),
  elevation: 0,
);

// ignore: prefer_const_declarations
final box = Boxes.getNewColor;

Widget buildColorPicker() => ColorPicker(
      pickerColor: changeColor,
      enableAlpha: false,
      showLabel: false,
      portraitOnly: true,
      onColorChanged: (newColor) => changeColor = newColor,
    );

class Boxes {
  static Box<SaveColorLocal> getNewColor() =>
      Hive.box<SaveColorLocal>('saveColorLocal');
}
