import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/configs/theme_config.dart';
import 'package:write_story/notifier/font_manager_notifier.dart';
import 'package:write_story/notifier/theme_notifier.dart';
import 'package:write_story/screens/wrapper_screens.dart';

class App extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final fontNotifier = useProvider(fontManagerProvider);
    final notifier = useProvider(themeProvider);

    return MaterialApp(
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: WrapperScreens(),
      themeMode: notifier.themeMode,
      theme: ThemeConfig(fontNotifier.fontFamilyFallback).light,
      darkTheme: ThemeConfig(fontNotifier.fontFamilyFallback).dark,
    );
  }
}
