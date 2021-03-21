import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:write_story/models/user_model.dart';
import 'package:write_story/notifier/user_model_notifier.dart';
import 'package:write_story/screens/home_screen.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/vt_tab_view.dart';

class AskForNameSheet extends HookWidget {
  const AskForNameSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(userModelProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    final nameNotEmpty =
        notifier.nickname != null && notifier.nickname!.isNotEmpty;

    bool canContinue = nameNotEmpty;
    canContinue = nameNotEmpty && notifier.user?.nickname != notifier.nickname;

    final tabController = useTabController(initialLength: 2);
    final _continueButton = _buildContinueButton(
      nameNotEmpty: canContinue,
      context: context,
      title: tr("common.continute_msg"),
      onTap: () async {
        final success = await notifier.setUser(
          UserModel(
            nickname: notifier.nickname!,
            createOn: DateTime.now(),
          ),
        );

        if (success) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            PageTransition(
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 1000),
              child: HomeScreen(),
            ),
          );
        }
      },
    );

    return LayoutBuilder(
      builder: (context, constrant) {
        bool tablet = constrant.maxWidth > constrant.maxHeight;
        final lottieHeight =
            tablet ? constrant.maxHeight / 2 : constrant.maxWidth / 2;

        final initHeight = (constrant.maxHeight -
                lottieHeight -
                statusBarHeight -
                kToolbarHeight) /
            constrant.maxHeight;

        final tab1 = Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText(
                  context: context,
                  title: tr("ask_for_name_sheet.hello_msg"),
                  subtitle: tr("ask_for_name_sheet.msg"),
                ),
                const SizedBox(height: 24.0),
                _buildTextField(
                  context: context,
                  hintText: tr("ask_for_name_sheet.hint_text"),
                  initialValue:
                      notifier.user != null ? notifier.user?.nickname : null,
                  onChanged: (String value) {
                    notifier.setNickname(value);
                  },
                ),
              ],
            ),
            _continueButton,
          ],
        );

        final tab2 = WTab2();
        return DraggableScrollableSheet(
          initialChildSize: initHeight,
          maxChildSize: 1,
          minChildSize: 0.2,
          builder: (context, controller) {
            return Container(
              height: double.infinity,
              decoration: buildBoxDecoration(context),
              child: VTTabView(
                controller: tabController,
                children: [
                  Container(
                    child: tab1,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 32.0,
                    ),
                  ),
                  Container(
                    child: tab2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 32.0,
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  BoxDecoration buildBoxDecoration(BuildContext context) {
    final _theme = Theme.of(context);
    const borderRadius = const BorderRadius.vertical(
      top: const Radius.circular(10),
    );

    final boxShadow = [
      BoxShadow(
        offset: Offset(0.0, -1.0),
        color: _theme.shadowColor.withOpacity(0.15),
        blurRadius: 10.0,
      ),
    ];

    return BoxDecoration(
      color: Colors.white,
      boxShadow: boxShadow,
      borderRadius: borderRadius,
    );
  }
}

class WTab2 extends StatelessWidget {
  const WTab2({
    Key? key,
    this.isSignin = false,
  }) : super(key: key);

  final bool isSignin;

  @override
  Widget build(BuildContext context) {
    final info =
        "Email and password are used to identify your database. Please try not to forget it.";
    final dbInfo =
        "For your privacy, backup data will be encrypted before upload to our database.";

    var loginInfo = _buildInfo(context, info);
    var databaseInfo = _buildInfo(context, dbInfo);

    if (!isSignin)
      return buildSignInAuth(context, loginInfo);
    else
      return buildBackup(context, databaseInfo);
  }

  Column buildSignInAuth(BuildContext context, Row loginInfo) {
    final _logButton = _buildContinueButton(
      nameNotEmpty: true,
      onTap: () {},
      context: context,
      title: "Log into your account",
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderText(
              context: context,
              title: "Setting",
              subtitle: "Backup or restore your data from cloud.",
              showLangs: false,
            ),
            Column(
              children: [
                const SizedBox(height: 24.0),
                _buildTextField(
                  context: context,
                  hintText: "Your email",
                  onChanged: (String value) {},
                ),
                const SizedBox(height: 12.0),
                _buildTextField(
                  context: context,
                  hintText: "Your password",
                  onChanged: (String value) {},
                ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            loginInfo,
            const SizedBox(height: 16.0),
            _logButton,
          ],
        ),
      ],
    );
  }

  Column buildBackup(BuildContext context, Row databaseInfo) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderText(
              context: context,
              title: "Setting",
              subtitle: "Backup or restore your data from cloud.",
              showLangs: false,
            ),
            const SizedBox(height: 8.0),
            VTOnTapEffect(
              onTap: () {},
              child: Container(
                height: 48,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                alignment: Alignment.centerLeft,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Text(
                  "Restore last backup - 12 May 2020",
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            VTOnTapEffect(
              onTap: () {},
              child: Container(
                height: 48,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                alignment: Alignment.centerLeft,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Text(
                  "Backup current database",
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Text("Signed in: theacheng.g6@gmail.com"),
                SizedBox(width: 8.0),
                VTOnTapEffect(
                  onTap: () {},
                  child: Text(
                    "Sign out",
                    style: TextStyle(
                      color: Theme.of(context).errorColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            databaseInfo,
            const SizedBox(height: 16.0),
          ],
        ),
      ],
    );
  }
}

Widget _buildHeaderText({
  required BuildContext context,
  required String title,
  required String subtitle,
  bool showLangs = true,
}) {
  final _theme = Theme.of(context);
  final _style =
      _theme.textTheme.headline4?.copyWith(color: _theme.primaryColor);

  return Container(
    width: double.infinity,
    child: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: _style,
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: _theme.textTheme.bodyText1,
            ),
          ],
        ),
        if (showLangs)
          Positioned(
            right: 0,
            child: Container(
              height: 38.0,
              child: Row(
                children: [
                  VTOnTapEffect(
                    onTap: () {
                      context.setLocale(Locale("km"));
                    },
                    child: Image.asset("assets/flags/km-flag.png"),
                  ),
                  const SizedBox(width: 4.0),
                  VTOnTapEffect(
                    onTap: () {
                      context.setLocale(Locale("en"));
                    },
                    child: Image.asset("assets/flags/en-flag.png"),
                  ),
                  const SizedBox(width: 4.0),
                  VTOnTapEffect(
                    onTap: () {
                      context.setLocale(Locale("en"));
                    },
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.save,
                        color: Theme.of(context).backgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
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
      borderRadius: BorderRadius.circular(10),
      color:
          nameNotEmpty ? _theme.primaryColor : _theme.scaffoldBackgroundColor);

  return IgnorePointer(
    ignoring: !nameNotEmpty,
    child: VTOnTapEffect(
      onTap: onTap,
      effects: _effects,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        decoration: _decoration,
        alignment: Alignment.center,
        child: Text(
          title,
          style: _theme.textTheme.bodyText1?.copyWith(
            color: nameNotEmpty ? Colors.white : _theme.disabledColor,
          ),
        ),
      ),
    ),
  );
}

Row _buildInfo(BuildContext context, String info) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.info,
        size: Theme.of(context).textTheme.bodyText2?.height,
        color: Theme.of(context).primaryColorDark.withOpacity(0.75),
      ),
      const SizedBox(width: 8.0),
      Container(
        padding: EdgeInsets.zero,
        width: MediaQuery.of(context).size.width - 16 * 2 - 8 - 24,
        child: Text(
          info,
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: Theme.of(context).primaryColorDark.withOpacity(0.75),
              ),
        ),
      ),
    ],
  );
}

Widget _buildTextField({
  required BuildContext context,
  String hintText = "",
  String? initialValue = "",
  required ValueChanged<String> onChanged,
}) {
  final _theme = Theme.of(context);
  final _textTheme = _theme.textTheme;

  final _style = _textTheme.subtitle1?.copyWith(
    color: _textTheme.bodyText1?.color?.withOpacity(0.7),
  );

  final _hintStyle = _textTheme.subtitle1?.copyWith(
    color: _theme.primaryColorDark.withOpacity(0.3),
  );

  final _decoration = InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 2.0),
    fillColor: _theme.scaffoldBackgroundColor,
    hintText: hintText,
    hintStyle: _hintStyle,
    filled: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(10),
    ),
  );

  return TextFormField(
    autocorrect: false,
    cursorColor: Theme.of(context).primaryColor,
    textAlign: TextAlign.center,
    style: _style,
    maxLines: 1,
    initialValue: initialValue,
    decoration: _decoration,
    onChanged: onChanged,
  );
}
