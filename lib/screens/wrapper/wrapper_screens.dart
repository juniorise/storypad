import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:storypad/notifier/user_model_notifier.dart';
import 'package:storypad/screens/home/home_screen.dart';
import 'package:storypad/sheets/ask_for_name_sheet.dart';

class WrapperScreens extends HookWidget {
  static const routeName = '/unlocked';

  WrapperScreens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Build WrapperScreens");

    final notifier = useProvider(userModelProvider);
    final controller = useAnimationController();
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomBarHeight = MediaQuery.of(context).padding.bottom;

    if (notifier.alreadyHasUser != null && !notifier.loading) {
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        controller
          ..duration = Duration(milliseconds: 500)
          ..forward();
      });
    }

    final Widget splashScreen = Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constrant) {
          bool tablet = constrant.maxWidth > constrant.maxHeight;

          final lottieHeight = tablet ? constrant.maxHeight / 2 : constrant.maxWidth / 2;

          var _margin = EdgeInsets.only(
            top: notifier.firstTime == false ? statusBarHeight : constrant.maxHeight / 2.5 - statusBarHeight,
          );

          return AnimatedContainer(
            duration: Duration(milliseconds: 350),
            margin: _margin,
            width: double.infinity,
            child: buildLottie(context, lottieHeight, controller),
          );
        },
      ),
    );

    if (notifier.alreadyHasUser == null) {
      return splashScreen;
    } else {
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) {
          print("alreadyHasUser ${notifier.alreadyHasUser}");
          if (notifier.alreadyHasUser == true && notifier.user?.nickname != null) {
            Navigator.of(context).pushReplacement(
              PageTransition(
                child: HomeScreen(),
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 1000),
              ),
            );
          } else {
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
                    bottomBarHeight: bottomBarHeight,
                  );
                },
              ).then((_) async {
                ScaffoldMessenger.of(
                  askForNameScaffoldKey.currentContext ?? context,
                ).removeCurrentSnackBar();
              });
            }
          }
        },
      );
      return splashScreen;
    }
  }

  LottieBuilder buildLottie(
    BuildContext context,
    double lottieHeight,
    AnimationController controller,
  ) {
    return LottieBuilder.asset(
      Theme.of(context).colorScheme.brightness == Brightness.dark
          ? "assets/animations/book_dark.json"
          : "assets/animations/book_light.json",
      height: lottieHeight,
      controller: controller,
      repeat: true,
      onLoaded: (LottieComposition composition) async {},
    );
  }
}
