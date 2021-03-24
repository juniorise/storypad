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
import 'package:write_story/database/w_database.dart';
import 'package:write_story/mixins/story_detail_method_mixin.dart';
import 'package:write_story/models/db_backup_model.dart';
import 'package:write_story/models/user_model.dart';
import 'package:write_story/notifier/auth_notifier.dart';
import 'package:write_story/notifier/home_screen_notifier.dart';
import 'package:write_story/notifier/remote_database_notifier.dart';
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
  }) : super(key: key);
  final bool init;
  final double statusBarHeight;
  final double bottomBarHeight;

  @override
  Widget build(BuildContext buildContext) {
    final context = _scaffoldKey.currentContext ?? buildContext;
    final notifier = useProvider(userModelProvider);

    final nameNotEmpty =
        notifier.nickname != null && notifier.nickname!.isNotEmpty;

    bool canContinue = nameNotEmpty;
    canContinue = nameNotEmpty && notifier.user?.nickname != notifier.nickname;

    final tabController = useTabController(initialLength: init ? 1 : 2);

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
                  onSettingTap: tabController.length == 2
                      ? () => tabController.animateTo(1)
                      : null,
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
                const SizedBox(height: 16.0),
                _continueButton,
              ],
            );

            return DraggableScrollableSheet(
              initialChildSize: initHeight >= 1 ? 1 : initHeight,
              maxChildSize:
                  1 - statusBarHeight / MediaQuery.of(context).size.height,
              minChildSize: 0.2,
              builder: (context, controller) {
                final tab2 = WTab2();

                return Container(
                  height: double.infinity,
                  decoration: buildBoxDecoration(context),
                  child: Stack(
                    children: [
                      VTTabView(
                        controller: tabController,
                        children: [
                          Container(
                            child: tab1,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 32.0,
                            ),
                          ),
                          if (!init)
                            Container(
                              child: tab2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
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

class WTab2 extends HookWidget with StoryDetailMethodMixin {
  WTab2({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = tr("info.email_pass");
    final dbInfo = tr("info.backup");

    var loginInfo = _buildInfo(context, info);
    var databaseInfo = _buildInfo(context, dbInfo);

    final notifier = useProvider(authenticatoinProvider);

    if (notifier.isAccountSignedIn && notifier.user != null) {
      return buildBackup(context, databaseInfo, notifier);
    } else {
      return buildSignInAuth(context, loginInfo, notifier);
    }
  }

  Widget buildSignInAuth(
    BuildContext context,
    Row loginInfo,
    AuthenticatoinNotifier notifier,
  ) {
    final _logButton = _buildContinueButton(
      nameNotEmpty: true,
      onTap: () async {
        if (notifier.email.trim().isNotEmpty &&
            notifier.password.trim().isNotEmpty) {
          bool success = await notifier.logAccount(
            notifier.email.trim(),
            notifier.password.trim(),
          );

          if (success == true) {
            showSnackBar(
              context: context,
              title: tr("msg.login.success"),
            );
          } else {
            showSnackBar(
              context: context,
              title: notifier.service?.errorMessage != null
                  ? notifier.service?.errorMessage as String
                  : tr("msg.login.fail"),
            );
          }
        } else {
          showSnackBar(
            context: context,
            title: tr("validate.email_password"),
          );
        }
      },
      context: context,
      title: tr("button.login"),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _buildHeaderText(
                context: context,
                title: tr("title.setting"),
                subtitle: tr("subtitle.backup_restore"),
                showLangs: false,
                showInfo: true,
              ),
              Column(
                children: [
                  const SizedBox(height: 24.0),
                  _buildTextField(
                    context: context,
                    hintText: tr("hint_text.email"),
                    onChanged: (String value) {
                      notifier.setEmail(value);
                    },
                  ),
                  const SizedBox(height: 12.0),
                  _buildTextField(
                    context: context,
                    hintText: tr("hint_text.password"),
                    onChanged: (String value) {
                      notifier.setPassword(value);
                    },
                    isPassword: true,
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              const SizedBox(height: 16.0),
              _logButton,
              const SizedBox(height: 16.0),
              loginInfo,
              const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBackup(
    BuildContext context,
    Row databaseInfo,
    AuthenticatoinNotifier notifier,
  ) {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple,
            Colors.transparent,
            Colors.transparent,
            Colors.purple
          ],
          stops: [0, 0.05, 0.95, 1], // 10% purple, 80% transparent, 10% purple
        ).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
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
              Consumer(
                builder: (context, watch, child) {
                  final dbNotifier = watch(remoteDatabaseProvider)..load();

                  final WDatabase database = WDatabase.instance;
                  return Column(
                    children: [
                      Divider(),
                      Row(
                        children: [
                          Text(
                            "${notifier.user?.email}",
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          const SizedBox(width: 8.0),
                          VTOnTapEffect(
                            onTap: () async {
                              await notifier.signOut();
                              context.read(remoteDatabaseProvider).reset();
                            },
                            child: Text(
                              tr("button.signout"),
                              style: TextStyle(
                                color: Theme.of(context).errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8.0),
                      VTOnTapEffect(
                        onTap: () async {
                          String backup = await database.generateBackup();
                          final backupModel = DbBackupModel(
                            createOn: Timestamp.now(),
                            db: backup,
                          );
                          await dbNotifier.add(backupModel);
                        },
                        child: Container(
                          height: 48,
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(tr("msg.backup.export"), maxLines: 1),
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
                  );
                },
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ],
      ),
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
                title: tr("msg.save.success"),
              );
            } else {
              showSnackBar(
                context: context,
                title: tr("msg.save.fail"),
              );
            }
          },
          child: Container(
            height: 48,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).scaffoldBackgroundColor,
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
        const SizedBox(height: 8.0),
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
  void Function()? onSettingTap,
}) {
  final _theme = Theme.of(context);
  final _style =
      _theme.textTheme.headline5?.copyWith(color: _theme.primaryColor);

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
        if (showInfo)
          Positioned(
            right: 0,
            child: VTOnTapEffect(
              onTap: () {
                Navigator.of(context).pop();
                showAboutDialog(
                  context: context,
                  applicationName: "Story",
                  applicationVersion: "v1.0.0+1",
                  applicationLegalese: tr("info.app_detail"),
                  children: [
                    const SizedBox(height: 24.0),
                    Text(
                      "Developer & UI Designer:",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Text(
                      "Thea Choem",
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Divider(),
                    Text(
                      "Logo Designer:",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Text(
                      "Menglong Srern",
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Divider(),
                    const SizedBox(height: 4.0),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.caption,
                        children: <TextSpan>[
                          TextSpan(text: tr("info.about_project") + " "),
                          TextSpan(
                            text: 'write_story',
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(color: Colors.blueAccent),
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
                  applicationIcon: Image.asset(
                    "assets/icons/app_icon.png",
                    height: 48,
                  ),
                );
              },
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
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
                  if (onSettingTap != null) const SizedBox(width: 4.0),
                  if (onSettingTap != null)
                    VTOnTapEffect(
                      onTap: onSettingTap,
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.settings,
                          color: Theme.of(context).primaryColor,
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
        size: 16,
        color: Theme.of(context).primaryColorDark.withOpacity(0.5),
      ),
      const SizedBox(width: 8.0),
      Container(
        padding: EdgeInsets.zero,
        width: MediaQuery.of(context).size.width - 16 * 2 - 8 - 24,
        child: Text(
          info,
          style: Theme.of(context).textTheme.caption?.copyWith(
                color: Theme.of(context).primaryColorDark.withOpacity(0.5),
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
  bool isPassword = false,
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
    obscureText: isPassword,
  );
}
