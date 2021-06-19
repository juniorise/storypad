import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/configs/theme_config.dart';
import 'package:storypad/notifier/font_manager_notifier.dart';
import 'package:storypad/notifier/lock_state_notifier.dart';
import 'package:storypad/notifier/theme_notifier.dart';
import 'package:storypad/screens/lock/lock_screen.dart';
import 'package:storypad/screens/wrapper/wrapper_screens.dart';

class App extends HookWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    print("Build App");

    final lockNotifier = useProvider(lockStateNotifier);
    final fontNotifier = useProvider(fontManagerProvider);
    final notifier = useProvider(themeProvider);

    return MaterialApp(
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: lockNotifier.enable ? LockScreenWrapper(LockFlowType.UNLOCK) : WrapperScreens(),
      theme: ThemeConfig(fontNotifier.fontFamilyFallback).get(isDarkMode: notifier.isDarkMode),
    );
  }
}
