import 'package:flutter/material.dart';
import 'package:open_pdf/utils/constants.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: Colors.black,
  splashColor: Colors.transparent,
  // primaryColorLight: Colors.grey,
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF20232a),
  appBarTheme: const AppBarTheme(
    // iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Color(0xFF20232a),
    elevation: Constants.globalElevation,
    surfaceTintColor: Colors.transparent,
    // color: Color(0xFF20232a),
  ),
  disabledColor: ColorConstants.color,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 4.0,
    backgroundColor: const Color(0xFF20232a),
    selectedIconTheme: IconThemeData(color: ColorConstants.primaryColor),
    selectedLabelStyle: const TextStyle(
      fontSize: 12,
    ),
    selectedItemColor: ColorConstants.primaryColor,
    unselectedItemColor: Colors.white,
    unselectedLabelStyle: const TextStyle(
      fontSize: 12,
    ),
    unselectedIconTheme: const IconThemeData(color: Colors.white),
  ),
  tabBarTheme: TabBarTheme(
    indicatorColor: ColorConstants.primaryColor,
    dividerColor: const Color.fromARGB(255, 45, 44, 44),
    labelStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: ColorConstants.primaryColor,
    ),
    unselectedLabelStyle: const TextStyle(fontSize: 15, color: Colors.grey),
  ),
  // iconButtonTheme: IconButtonThemeData(
  //   style: ButtonStyle(
  //     iconColor: WidgetStateProperty.all<Color>(
  //       ColorConstants.primaryColor,
  //     ),
  //   ),
  // ),
  // iconTheme: IconThemeData(color: ColorConstants.primaryColor),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    displayLarge: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: ColorConstants.primaryColor,
    linearTrackColor: ColorConstants.color,
  ),
  cardTheme: const CardTheme(
    color: Color.fromARGB(255, 27, 28, 27),
  ),
  colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark, primarySwatch: Colors.amber)
      .copyWith(
    primary: ColorConstants.primaryColor.withOpacity(0.8),
    surface: const Color.fromARGB(255, 55, 48, 48),
  ),
);
