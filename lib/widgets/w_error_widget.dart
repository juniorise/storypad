import 'dart:io';

import 'package:flutter/material.dart';
import 'package:storypad/constants/config_constant.dart';

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
                    "Exit app".toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamilyFallback: Theme.of(context).textTheme.bodyText1?.fontFamilyFallback,
                    ),
                  ),
                  onPressed: () async {
                    exit(1);
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: ConfigConstant.circlarRadius1,
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.error),
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) {
                        if (states.contains(MaterialState.pressed) ||
                            states.contains(MaterialState.focused) ||
                            states.contains(MaterialState.hovered) ||
                            states.contains(MaterialState.selected)) {
                          return Theme.of(context).colorScheme.surface;
                        } else {
                          return Theme.of(context).colorScheme.error.withOpacity(0.05);
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
