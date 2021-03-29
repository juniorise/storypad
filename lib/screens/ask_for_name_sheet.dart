import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:write_story/app_helper/app_helper.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/database/w_database.dart';
import 'package:write_story/mixins/story_detail_method_mixin.dart';
import 'package:write_story/models/db_backup_model.dart';
import 'package:write_story/models/user_model.dart';
import 'package:write_story/notifier/auth_notifier.dart';
import 'package:write_story/notifier/home_screen_notifier.dart';
import 'package:write_story/notifier/remote_database_notifier.dart';
import 'package:write_story/notifier/theme_notifier.dart';
import 'package:write_story/notifier/user_model_notifier.dart';
import 'package:write_story/screens/home_screen.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/vt_tab_view.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    final context = _scaffoldKey.currentContext ?? buildContext;
    final notifier = useProvider(userModelProvider);

    final nameNotEmpty =
        notifier.nickname != null && notifier.nickname!.isNotEmpty;

    bool canContinue = nameNotEmpty;
    canContinue = nameNotEmpty && notifier.user?.nickname != notifier.nickname;

    final tabController = useTabController(
      initialLength: init ? 1 : 2,
      initialIndex: intTapIndex,
    );

    tabController.addListener(() {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    });

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
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: LayoutBuilder(
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

            final tab2 = WTab2();

            return DraggableScrollableSheet(
              initialChildSize: initHeight >= 1 ? 1 : initHeight,
              maxChildSize:
                  1 - statusBarHeight / MediaQuery.of(context).size.height,
              minChildSize: 0.2,
              builder: (context, controller) {
                return Container(
                  height: double.infinity,
                  decoration: buildBoxDecoration(context),
                  child: Stack(
                    children: [
                      VTTabView(
                        controller: tabController,
                        children: [
                          SingleChildScrollView(
                            child: tab1,
                            controller: init ? null : controller,
                            padding: const EdgeInsets.symmetric(
                              horizontal: ConfigConstant.margin2,
                              vertical: ConfigConstant.margin2 * 2,
                            ),
                          ),
                          if (!init)
                            SingleChildScrollView(
                              controller: controller,
                              child: tab2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: ConfigConstant.margin2,
                              ),
                            )
                        ],
                      ),
                      if (tabController.length == 2)
                        buildTabIndicator(tabController),
                    ],
                  ),
                );
              },
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
      bottom: bottomBarHeight,
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
                  width = lerpDouble(
                    50,
                    6.0,
                    tabController.animation!.value,
                  );
                }

                if (index == 1) {
                  width = lerpDouble(
                    6.0,
                    50,
                    tabController.animation!.value,
                  );
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

class WTab2 extends HookWidget with StoryDetailMethodMixin {
  WTab2({
    Key? key,
  }) : super(key: key);

  final ValueNotifier<bool> isSwitchNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(authenticatoinProvider);
    final themeNotifier = useProvider(themeProvider);

    return buildBackup(context, notifier, themeNotifier);
  }

  Widget buildBackup(
    BuildContext context,
    AuthenticatoinNotifier notifier,
    ThemeNotifier themeNotifier,
  ) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: notifier.loading ? 1 : 0,
          duration: ConfigConstant.fadeDuration ~/ 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Container(
              height: 4,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ConfigConstant.margin2 * 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText(
                  context: context,
                  title: tr("title.setting"),
                  subtitle: tr("subtitle.backup_restore"),
                  showLangs: false,
                  showInfo: true,
                ),
                const SizedBox(height: 24.0),
                Consumer(
                  builder: (context, watch, child) {
                    RemoteDatabaseNotifier dbNotifier;
                    dbNotifier = watch(remoteDatabaseProvider)..load();

                    final WDatabase database = WDatabase.instance;
                    return Column(
                      children: [
                        Material(
                          borderRadius: ConfigConstant.circlarRadius2,
                          color: Theme.of(context).colorScheme.secondary,
                          child: SwitchListTile(
                            value: themeNotifier.isDarkMode,
                            selected: true,
                            shape: RoundedRectangleBorder(),
                            activeColor:
                                Theme.of(context).colorScheme.onSecondary,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: ConfigConstant.margin2,
                            ),
                            title: Text(tr("button.dark_mode")),
                            onChanged: (bool value) {
                              themeNotifier.toggleTheme();
                            },
                          ),
                        ),
                        const SizedBox(height: ConfigConstant.margin1),
                        Material(
                          elevation: 0.5,
                          borderRadius: ConfigConstant.circlarRadius2,
                          color: Theme.of(context).colorScheme.primary,
                          child: ValueListenableBuilder(
                              valueListenable: isSwitchNotifier,
                              builder: (context, bool value, child) {
                                return SwitchListTile(
                                  value: notifier.isAccountSignedIn ||
                                      isSwitchNotifier.value,
                                  selected: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: ConfigConstant.circlarRadius2,
                                  ),
                                  activeColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: ConfigConstant.margin2,
                                  ),
                                  title: Text(tr("button.login")),
                                  subtitle: Text(
                                    notifier.isAccountSignedIn
                                        ? "${notifier.user?.email}"
                                        : tr("msg.login.info"),
                                  ),
                                  onChanged: (bool value) async {
                                    onTapVibrate();
                                    isSwitchNotifier.value = value;
                                    if (value == true) {
                                      bool success =
                                          await notifier.logAccount();
                                      if (success == true) {
                                        showSnackBar(
                                          context: context,
                                          title: tr("msg.login.success"),
                                        );
                                      } else {
                                        showSnackBar(
                                          context: context,
                                          title: notifier
                                                      .service?.errorMessage !=
                                                  null
                                              ? notifier.service?.errorMessage
                                                  as String
                                              : tr("msg.login.fail"),
                                        );
                                      }
                                    } else {
                                      await notifier.signOut();
                                      context
                                          .read(remoteDatabaseProvider)
                                          .reset();
                                    }
                                    isSwitchNotifier.value =
                                        notifier.isAccountSignedIn;
                                  },
                                );
                              }),
                        ),
                        if (notifier.isAccountSignedIn)
                          Column(
                            children: [
                              const SizedBox(height: ConfigConstant.margin2),
                              VTOnTapEffect(
                                onTap: () async {
                                  showSnackBar(
                                    context: context,
                                    title: tr("msg.backup.export.warning"),
                                    onActionPressed: () async {
                                      String backup =
                                          await database.generateBackup();
                                      final backupModel = DbBackupModel(
                                        createOn: Timestamp.now(),
                                        db: backup,
                                      );
                                      final bool success =
                                          await dbNotifier.replace(backupModel);

                                      if (success) {
                                        showSnackBar(
                                          context: context,
                                          title:
                                              tr("msg.backup.export.success"),
                                        );
                                      } else {
                                        showSnackBar(
                                          context: context,
                                          title: tr("msg.backup.export.fail"),
                                        );
                                      }
                                    },
                                  );
                                },
                                child: Container(
                                  height: 48,
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    borderRadius: ConfigConstant.circlarRadius2,
                                  ),
                                  child: Text(tr("msg.backup.export"),
                                      maxLines: 1),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              if (dbNotifier.backup != null &&
                                  dbNotifier.backup is DbBackupModel)
                                buildBackItem(
                                  database,
                                  dbNotifier.backup!,
                                  context,
                                ),
                            ],
                          )
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildBackItem(
    WDatabase database,
    DbBackupModel item,
    BuildContext context,
  ) {
    return Column(
      children: [
        VTOnTapEffect(
          onTap: () async {
            final bool success = await database.restoreBackup(item.db);
            if (success) {
              await context.read(homeScreenProvider).load();
              showSnackBar(
                context: context,
                title: tr("msg.backup.import.success"),
              );
            } else {
              showSnackBar(
                context: context,
                title: tr("msg.backup.import.fail"),
              );
            }
          },
          child: Container(
            height: ConfigConstant.iconSize3,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: ConfigConstant.circlarRadius2,
            ),
            child: Text(
              tr(
                "msg.backup.import",
                namedArgs: {
                  "DATE": AppHelper.dateFormat(context)
                          .format(item.createOn.toDate()) +
                      ", " +
                      AppHelper.timeFormat(context)
                          .format(item.createOn.toDate())
                },
              ),
              maxLines: 1,
            ),
          ),
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
  bool showInfo = false,
}) {
  final _theme = Theme.of(context);
  final _textTheme = _theme.textTheme;
  final _style =
      _theme.textTheme.headline5?.copyWith(color: _theme.colorScheme.primary);

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
              style: _textTheme.bodyText1,
            ),
          ],
        ),
        if (showInfo)
          Positioned(
            right: 0,
            child: VTOnTapEffect(
              onTap: () async {
                Navigator.of(context).pop();
                await Future.delayed(Duration(milliseconds: 100)).then((value) {
                  showAboutDialog(
                    context: context,
                    applicationName: "Story",
                    applicationVersion: "v1.0.0+6",
                    applicationLegalese: tr("info.app_detail"),
                    children: [
                      const SizedBox(height: 24.0),
                      Text(
                        tr("position.thea"),
                        style: _textTheme.caption,
                      ),
                      Text(
                        tr("name.thea"),
                        style: _textTheme.caption!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Divider(),
                      Text(
                        tr("position.menglong"),
                        style: _textTheme.caption,
                      ),
                      Text(
                        tr("name.menglong"),
                        style: _textTheme.caption!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Divider(),
                      const SizedBox(height: ConfigConstant.margin0),
                      RichText(
                        text: TextSpan(
                          style: _textTheme.caption,
                          children: <TextSpan>[
                            TextSpan(text: tr("info.about_project") + " "),
                            TextSpan(
                              text: tr("button.source_code"),
                              style: _textTheme.caption!.copyWith(
                                color: _theme.colorScheme.primary,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launch(
                                    "https://github.com/theacheng/write_story",
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                    applicationIcon: ClipRRect(
                      borderRadius: ConfigConstant.circlarRadius1,
                      child: Image.asset(
                        "assets/icons/app_icon.png",
                        height: ConfigConstant.iconSize3,
                      ),
                    ),
                  );
                });
              },
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        if (showLangs)
          Positioned(
            right: 0,
            child: Container(
              height: 38.0,
              child: Row(
                children: [
                  VTOnTapEffect(
                    vibrate: true,
                    onTap: () {
                      onTapVibrate();
                      context.setLocale(Locale("km"));
                    },
                    child: Image.asset("assets/flags/km-flag.png"),
                  ),
                  const SizedBox(width: 4.0),
                  VTOnTapEffect(
                    vibrate: true,
                    onTap: () {
                      onTapVibrate();
                      context.setLocale(Locale("en"));
                    },
                    child: Image.asset("assets/flags/en-flag.png"),
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
                ? _theme.colorScheme.onSecondary
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

  final _style = _textTheme.subtitle1?.copyWith(
    color: _textTheme.bodyText1?.color?.withOpacity(0.7),
  );

  final _hintStyle = _textTheme.subtitle1?.copyWith(
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
