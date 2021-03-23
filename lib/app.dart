import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:write_story/screens/wrapper_screens.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fontFamilyFallback = ["Kantumruy", "Quicksand"];

    return MaterialApp(
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: WrapperScreens(),
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColorDark: Color(0xFF263238),
        primaryColor: Color(0xFF0E4DA4),
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFFF6F6F6),
        disabledColor: Color(0xFF263238).withOpacity(0.2),
        dividerColor: Color(0xFFE9E9E9),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          brightness: Brightness.light,
        ),
        canvasColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Color(0xFF263238)),
        toggleableActiveColor: Color(0xFF263238),
        textTheme: buildTextTheme(fontFamilyFallback).apply(
          bodyColor: Color(0xFF263238),
          displayColor: Color(0xFF263238),
          decorationColor: Color(0xFF263238),
        ),
      ),
    );
  }

  TextTheme buildTextTheme(List<String> fontFamilyFallback) {
    return TextTheme(
      headline1: TextStyle(
        fontSize: 98,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        fontFamilyFallback: fontFamilyFallback,
      ),
      headline2: TextStyle(
        fontSize: 61,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        fontFamilyFallback: fontFamilyFallback,
      ),
      headline3: TextStyle(
        fontSize: 49,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: fontFamilyFallback,
      ),
      headline4: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        fontFamilyFallback: fontFamilyFallback,
      ),
      headline5: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: fontFamilyFallback,
      ),
      headline6: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        fontFamilyFallback: fontFamilyFallback,
      ),
      subtitle1: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        fontFamilyFallback: fontFamilyFallback,
      ),
      subtitle2: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        fontFamilyFallback: fontFamilyFallback,
      ),
      bodyText1: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        fontFamilyFallback: fontFamilyFallback,
      ),
      bodyText2: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        fontFamilyFallback: fontFamilyFallback,
      ),
      button: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
        fontFamilyFallback: fontFamilyFallback,
      ),
      caption: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        fontFamilyFallback: fontFamilyFallback,
      ),
      overline: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        fontFamilyFallback: fontFamilyFallback,
      ),
    );
  }
}
