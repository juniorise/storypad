import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:write_story/notifier/user_model_notifier.dart';
import 'package:write_story/screens/home_screen.dart';
import 'package:write_story/screens/ask_for_name_sheet.dart';

class WrapperScreens extends HookWidget {
  WrapperScreens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(userModelProvider);
    final controller = useAnimationController();
    final statusBarHeight = MediaQuery.of(context).padding.top;

    final Widget splashScreen = Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: LayoutBuilder(
        builder: (context, constrant) {
          bool tablet = constrant.maxWidth > constrant.maxHeight;

          final lottieHeight =
              tablet ? constrant.maxHeight / 2 : constrant.maxWidth / 2;

          var _margin = EdgeInsets.only(
            top: notifier.alreadyHasUser == false
                ? statusBarHeight
                : constrant.maxHeight / 2.5 - statusBarHeight,
          );

          return AnimatedContainer(
            margin: _margin,
            duration: const Duration(milliseconds: 650),
            width: double.infinity,
            child: LottieBuilder.asset(
              "assets/animations/45130-book.json",
              height: lottieHeight,
              controller: controller,
              onLoaded: (LottieComposition composition) async {
                controller
                  ..duration = composition.duration
                  ..forward();
              },
            ),
          );
        },
      ),
    );

    if (notifier.alreadyHasUser == null) {
      return splashScreen;
    } else {
      Future.delayed(
        const Duration(microseconds: 0),
        () async {
          if (notifier.alreadyHasUser == true &&
              notifier.user?.nickname != null) {
            print("1");
            Navigator.of(context).pushReplacement(
              PageTransition(
                child: HomeScreen(),
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 1000),
              ),
            );
          } else {
            print("2");
            await Future.delayed(Duration(milliseconds: 350))
                .then((value) async {
              if (!notifier.isInit) {
                notifier.setInit();
                showModalBottomSheet(
                  barrierColor: Colors.transparent,
                  isDismissible: false,
                  context: context,
                  enableDrag: false,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return AskForNameSheet(
                      init: true,
                      statusBarHeight: statusBarHeight,
                    );
                  },
                );
              }
            });
          }
        },
      );
      return splashScreen;
    }
  }
}
