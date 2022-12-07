import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        toolbarTextStyle: const TextTheme(
          headline6: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).bodyText2,
        titleTextStyle: const TextTheme(
          headline6: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).headline6,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        color: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarTextStyle: const TextTheme(
          headline6: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).bodyText2,
        titleTextStyle: const TextTheme(
          headline6: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).headline6,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
    );
  }
}
