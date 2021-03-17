import 'package:auto_orientation/auto_orientation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/app.dart';
import 'package:write_story/database/w_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EasyLocalization.ensureInitialized();

  await WDatabase.instance.database;
  AutoOrientation.portraitAutoMode();

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
      startLocale: Locale("km"),
      supportedLocales: [
        Locale('en'),
        Locale('km'),
      ],
      path: "assets/translations",
      useOnlyLangCode: true,
      fallbackLocale: Locale('en'),
      child: App(),
    );
  }
}
