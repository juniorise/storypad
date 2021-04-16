import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/app.dart';
import 'package:write_story/database/w_database.dart';

const initSupportedLocales = [
  Locale('en'),
  Locale('km'),
];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  await WDatabase.instance.database;

  runApp(
    ProviderScope(
      child: AppLocalization(),
    ),
  );
}

class AppLocalization extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      startLocale: Locale("en"),
      supportedLocales: initSupportedLocales,
      path: "assets/translations",
      useOnlyLangCode: true,
      fallbackLocale: Locale('en'),
      child: App(),
    );
  }
}
