import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/app.dart';
import 'package:storypad/constants/app_constant.dart';
import 'package:storypad/services/storages/local_storages/w_database.dart';
import 'package:storypad/services/views/lock_service.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }

  await WDatabase.instance.database;
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await EasyLocalization.ensureInitialized();
  await LockService.instance.enable;

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
      supportedLocales: AppConstant.initSupportedLocales,
      path: "assets/translations",
      useOnlyLangCode: true,
      fallbackLocale: Locale('en'),
      child: App(),
    );
  }
}
