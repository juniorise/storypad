import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/models/user_model.dart';
import 'package:storypad/notifier/user_model_notifier.dart';
import 'package:storypad/screens/home_screen.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';

final GlobalKey<ScaffoldState> askForNameScaffoldKey =
    GlobalKey<ScaffoldState>();

class AskForNameSheet extends HookWidget {
  const AskForNameSheet({
    Key? key,
    this.init = false,
    required this.statusBarHeight,
    required this.bottomBarHeight,
    this.intTapIndex = 0,
  }) : super(key: key);
  final bool init;
  final double statusBarHeight;
  final double bottomBarHeight;
  final int intTapIndex;

  @override
  Widget build(BuildContext buildContext) {
    final context = askForNameScaffoldKey.currentContext ?? buildContext;
    final notifier = useProvider(userModelProvider);

    final nameNotEmpty =
        notifier.nickname != null && notifier.nickname!.isNotEmpty;

    bool canContinue = nameNotEmpty;
    canContinue = nameNotEmpty && notifier.user?.nickname != notifier.nickname;

    final _continueButton = _buildContinueButton(
      nameNotEmpty: canContinue,
      context: context,
      title: init ? tr("button.continute") : tr("button.update"),
      onTap: () async {
        final success = await notifier.setUser(
          UserModel(
            nickname: notifier.nickname!,
            createOn: DateTime.now(),
          ),
        );

        if (success) {
          Navigator.of(context).pop();
          if (init) {
            Navigator.of(context).pushReplacement(
              PageTransition(
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 1000),
                child: HomeScreen(),
              ),
            );
          }
        }
      },
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        TextEditingController().clear();
      },
      child: Scaffold(
        key: askForNameScaffoldKey,
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: LayoutBuilder(
          builder: (context, constrant) {
            bool tablet = constrant.maxWidth > constrant.maxHeight;
            final lottieHeight =
                tablet ? constrant.maxHeight / 2 : constrant.maxWidth / 2;

            double initHeight = (constrant.maxHeight -
                    lottieHeight -
                    statusBarHeight -
                    kToolbarHeight) /
                constrant.maxHeight;

            final body = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText(
                  context: context,
                  title: tr("title.hello"),
                  subtitle: tr("subtitle.ask_for_name"),
                ),
                const SizedBox(height: 24.0),
                _buildTextField(
                  context: context,
                  hintText: tr("hint_text.nickname"),
                  initialValue:
                      notifier.user != null ? notifier.user?.nickname : null,
                  onChanged: (String value) {
                    notifier.setNickname(value);
                  },
                ),
                const SizedBox(height: 8.0),
                _continueButton,
              ],
            );

            return Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(color: Colors.transparent),
                ),
                DraggableScrollableSheet(
                  initialChildSize: initHeight >= 1 ? 1 : initHeight,
                  maxChildSize:
                      1 - statusBarHeight / MediaQuery.of(context).size.height,
                  minChildSize: initHeight - 0.05 > 0 ? initHeight - 0.1 : 0,
                  builder: (context, controller) {
                    return Container(
                      decoration: buildBoxDecoration(context),
                      child: SingleChildScrollView(
                        child: body,
                        padding: const EdgeInsets.symmetric(
                          horizontal: ConfigConstant.margin2,
                          vertical: ConfigConstant.margin2 * 2,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Positioned buildTabIndicator(TabController tabController) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomBarHeight + 8.0,
      child: AnimatedBuilder(
        animation: tabController.animation!,
        builder: (context, snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              tabController.length,
              (index) {
                double? width = 6.0;
                if (index == 0) {
                  width = lerpDouble(50, 6.0, tabController.animation!.value);
                } else if (index == 1) {
                  width = lerpDouble(6.0, 50, tabController.animation!.value);
                }

                return Container(
                  height: 6.0,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: Theme.of(context).disabledColor,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                );
              },
            ),
          );
        },
      ),
    );
  }

  BoxDecoration buildBoxDecoration(BuildContext context) {
    final _theme = Theme.of(context);
    final borderRadius = ConfigConstant.circlarRadiusTop2;

    final boxShadow = [
      BoxShadow(
        offset: Offset(0.0, -1.0),
        color: _theme.shadowColor.withOpacity(0.15),
        blurRadius: 10.0,
      ),
    ];

    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: boxShadow,
      borderRadius: borderRadius,
    );
  }
}

class WLineLoading extends StatelessWidget {
  const WLineLoading({
    Key? key,
    required this.loading,
  }) : super(key: key);

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: loading ? 1 : 0,
      duration: ConfigConstant.fadeDuration ~/ 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          height: 4,
          child: LinearProgressIndicator(
            backgroundColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildHeaderText({
  required BuildContext context,
  required String title,
  required String subtitle,
}) {
  final _theme = Theme.of(context);
  final _textTheme = _theme.textTheme;
  final _style =
      _theme.textTheme.headline6?.copyWith(color: _theme.colorScheme.primary);

  return Container(
    width: double.infinity,
    child: Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: _style,
              ),
              const SizedBox(height: ConfigConstant.margin0),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: _textTheme.bodyText1?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildContinueButton({
  required bool nameNotEmpty,
  required VoidCallback onTap,
  required BuildContext context,
  required String title,
}) {
  final _theme = Theme.of(context);

  final _effects = [
    VTOnTapEffectItem(
      effectType: VTOnTapEffectType.touchableOpacity,
      active: 0.5,
    ),
  ];

  final _decoration = BoxDecoration(
    borderRadius: ConfigConstant.circlarRadius2,
    color: nameNotEmpty
        ? _theme.colorScheme.primary
        : _theme.colorScheme.background,
  );

  return IgnorePointer(
    ignoring: !nameNotEmpty,
    child: VTOnTapEffect(
      onTap: onTap,
      effects: _effects,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: ConfigConstant.iconSize3,
        decoration: _decoration,
        alignment: Alignment.center,
        child: Text(
          title,
          style: _theme.textTheme.bodyText1?.copyWith(
            color: nameNotEmpty
                ? _theme.colorScheme.onPrimary
                : _theme.disabledColor,
          ),
        ),
      ),
    ),
  );
}

Widget _buildTextField({
  required BuildContext context,
  String hintText = "",
  String? initialValue = "",
  required ValueChanged<String> onChanged,
  bool isPassword = false,
}) {
  final _theme = Theme.of(context);
  final _textTheme = _theme.textTheme;

  final _style = _textTheme.bodyText1?.copyWith(
    color: _textTheme.bodyText1?.color?.withOpacity(0.7),
  );

  final _hintStyle = _textTheme.bodyText1?.copyWith(
    color: _theme.disabledColor,
  );

  final _decoration = InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 2.0),
    fillColor: _theme.colorScheme.background,
    hintText: hintText,
    hintStyle: _hintStyle,
    filled: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: ConfigConstant.circlarRadius2,
    ),
  );

  return TextFormField(
    autocorrect: false,
    cursorColor: Theme.of(context).colorScheme.primary,
    textAlign: TextAlign.center,
    style: _style,
    maxLines: 1,
    initialValue: initialValue,
    decoration: _decoration,
    onChanged: onChanged,
    obscureText: isPassword,
  );
}
