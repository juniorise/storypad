import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/configs/theme_config.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/notifier/font_manager_notifier.dart';
import 'package:storypad/notifier/lock_state_notifier.dart';
import 'package:storypad/notifier/theme_notifier.dart';
import 'package:storypad/screens/lock_screen.dart';
import 'package:storypad/screens/wrapper_screens.dart';

class App extends HookWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    print("Build App");

    final fontNotifier = useProvider(fontManagerProvider);
    final notifier = useProvider(themeProvider);
    final lockScreenNotifier = useProvider(lockStateNotifier);

    return MaterialApp(
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: lockScreenNotifier.enable == true
          ? LockScreenWrapper(LockFlowType.UNLOCK)
          : WrapperScreens(),
      theme: !notifier.isDarkMode
          ? ThemeConfig(fontNotifier.fontFamilyFallback).light
          : ThemeConfig(fontNotifier.fontFamilyFallback).dark,
      builder: (BuildContext context, Widget? widget) {
        Widget error = Text('...rendering error...');
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          final text = WErrorWidget(errorDetails: errorDetails);
          error = text;
          return error;
        };
        if (widget is Scaffold || widget is Navigator)
          error = MaterialApp(home: Scaffold(body: Center(child: error)));
        return widget ?? WErrorWidget(errorDetails: null);
      },
    );
  }
}

class WErrorWidget extends StatelessWidget {
  const WErrorWidget({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  final FlutterErrorDetails? errorDetails;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/illustrations/error-cloud.png",
                  height: 100,
                ),
                const SizedBox(height: 16),
                if (errorDetails != null)
                  Text(
                    errorDetails!.summary.toDescription().toString(),
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                Text(
                  "Try restart the app or clear app cache and data",
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  child: Text(
                    "Clear Cache & Restart".toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamilyFallback: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.fontFamilyFallback,
                    ),
                  ),
                  onPressed: () async {
                    await DefaultCacheManager().emptyCache();
                    exit(1);
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: ConfigConstant.circlarRadius1,
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.error),
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) {
                        if (states.contains(MaterialState.pressed) ||
                            states.contains(MaterialState.focused) ||
                            states.contains(MaterialState.hovered) ||
                            states.contains(MaterialState.selected)) {
                          return Theme.of(context).colorScheme.surface;
                        } else {
                          return Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.05);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
