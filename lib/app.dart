import 'package:flutter/material.dart';
import 'package:write_your_story/home_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fontFamilyFallback = ["Kantumruy", "Quicksand"];
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: buildTextTheme(fontFamilyFallback),
      ),
      home: HomeScreen(),
    );
  }

  TextTheme buildTextTheme(List<String> fontFamilyFallback) {
    return TextTheme(
      headline1: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: fontFamilyFallback,
      ),
      headline2: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        fontFamilyFallback: fontFamilyFallback,
      ),
      headline3: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: fontFamilyFallback,
      ),
      subtitle1: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontFamilyFallback: fontFamilyFallback,
      ),
      subtitle2: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: fontFamilyFallback,
      ),
      bodyText1: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: fontFamilyFallback,
      ),
      bodyText2: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: fontFamilyFallback,
      ),
      button: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamilyFallback: fontFamilyFallback,
      ),
      caption: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: fontFamilyFallback,
      ),
      overline: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        fontFamilyFallback: fontFamilyFallback,
      ),
    );
  }
}
