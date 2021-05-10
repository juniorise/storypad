import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/configs/theme_config.dart';
import 'package:storypad/notifier/font_manager_notifier.dart';
import 'package:storypad/notifier/lock_screen_notifier.dart';
import 'package:storypad/notifier/theme_notifier.dart';
import 'package:storypad/screens/lock_screen.dart';
import 'package:storypad/screens/wrapper_screens.dart';

class App extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final fontNotifier = useProvider(fontManagerProvider);
    final notifier = useProvider(themeProvider);
    final lockScreenNotifier =
        useProvider(lockScreenProvider(LockScreenFlowType.UNLOCK));

    String initialRoute;
    if (!lockScreenNotifier.inited) {
      initialRoute = "/";
    } else if (lockScreenNotifier.storageLockNumberMap != null) {
      initialRoute = "/lockscreen";
    } else {
      initialRoute = "/unlocked";
    }

    return MaterialApp(
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '': (context) => Scaffold(),
        '/unlocked': (context) => WrapperScreens(),
        '/lockscreen': (context) {
          return LockScreenWrapper(LockScreenFlowType.UNLOCK);
        }
      },
      theme: !notifier.isDarkMode
          ? ThemeConfig(fontNotifier.fontFamilyFallback).light
          : ThemeConfig(fontNotifier.fontFamilyFallback).dark,
    );
  }
}
