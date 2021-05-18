import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/app.dart';
import 'package:storypad/database/w_database.dart';
import 'package:storypad/services/lock_service.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

const initSupportedLocales = [
  Locale('en'),
  Locale('km'),
];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp();
  await WDatabase.instance.database;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }

  bool enable = await LockService.instance.enable;
  runApp(
    ProviderScope(
      child: AppLocalization(enable: enable),
    ),
  );
}

class AppLocalization extends StatelessWidget {
  final bool enable;
  const AppLocalization({Key? key, required this.enable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      startLocale: Locale("en"),
      supportedLocales: initSupportedLocales,
      path: "assets/translations",
      useOnlyLangCode: true,
      fallbackLocale: Locale('en'),
      child: App(enable: enable),
    );
  }
}
