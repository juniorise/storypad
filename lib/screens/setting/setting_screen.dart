import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_version/get_version.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';
import 'package:storypad/screens/home/local_widgets/backup_button.dart';
import 'package:storypad/screens/sponser/sponser_screen.dart';
import 'package:storypad/services/local_storages/preferences//auto_save_bool_storage.dart';
import 'package:storypad/widgets/w_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/dialog_mixin.dart';
import 'package:storypad/mixins/w_snakbar_mixin.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/notifier/auth_notifier.dart';
import 'package:storypad/notifier/check_for_update_notifier.dart';
import 'package:storypad/notifier/lock_notifier.dart';
import 'package:storypad/notifier/remote_database_notifier.dart';
import 'package:storypad/notifier/theme_notifier.dart';
import 'package:storypad/screens/font_manager/font_manager_screen.dart';
import 'package:storypad/screens/lock/lock_screen.dart';
import 'package:storypad/screens/lock_setting/lock_setting_screen.dart';
import 'package:storypad/screens/story_detail/story_detail_screen.dart';
import 'package:storypad/sheets/ask_for_name_sheet.dart';
import 'package:storypad/services/apis/google_drive_api.dart';
import 'package:storypad/widgets/w_tap_effect.dart';
import 'package:storypad/widgets/w_about_dialog.dart';
import 'package:storypad/widgets/w_icon_button.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingScreen extends HookWidget with DialogMixin, WSnackBarMixin {
  final double avatarSize = 72;
  final bool locked;
  SettingScreen({this.locked = false});

  final ValueNotifier<double> scrollOffsetNotifier = ValueNotifier<double>(0);
  final ValueNotifier<bool> vibrationNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> autoSaveNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    print("Build SettingScreen");
    final scrollController = useScrollController();

    AutoSaveBoolStorage().getBool().then((value) {
      autoSaveNotifier.value = value == true;
    });

    scrollController.addListener(() {
      scrollOffsetNotifier.value = scrollController.offset;
    });

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: buildAppBar(context),
        body: Stack(
          children: [
            ListView(
              controller: scrollController,
              children: [
                buildUpdateSpacer(),
                buildRelateToAccount(),
                const SizedBox(height: 8.0),
                buildRelateToTheme(),
                buildRelateToLanguage(),
                buildFontStyle(context),
                const SizedBox(height: 8.0),
                WListTile(
                  iconData: Icons.lock,
                  titleText: tr("title.lock"),
                  onTap: () async {
                    if (locked) {
                      showSnackBar(context: context, title: tr("msg.locked"));
                      return;
                    }
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return LockSettingScreen();
                      }),
                    );
                    final notifier = context.read(lockProvider(LockFlowType.UNLOCK));
                    Future.delayed(ConfigConstant.duration).then((value) async {
                      await notifier.load();
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                ValueListenableBuilder(
                  valueListenable: autoSaveNotifier,
                  builder: (context, value, child) {
                    return WListTile(
                      iconData: Icons.save_sharp,
                      titleText: tr("title.auto_save"),
                      subtitleText: tr('subtitle.save_on_pause'),
                      trailing: Switch(
                        onChanged: (bool value) async {
                          await AutoSaveBoolStorage().setBool(value: !autoSaveNotifier.value);
                          autoSaveNotifier.value = !autoSaveNotifier.value;
                        },
                        value: autoSaveNotifier.value,
                      ),
                      onTap: () async {
                        await AutoSaveBoolStorage().setBool(value: !autoSaveNotifier.value);
                        autoSaveNotifier.value = !autoSaveNotifier.value;
                      },
                    );
                  },
                ),
                const SizedBox(height: 8.0),
                WListTile(
                  iconData: Icons.wallet_membership,
                  titleText: "Support us",
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) {
                            return SponserScreen();
                          }),
                    );
                  },
                ),
                const SizedBox(height: 8.0),
                buildRate(),
                buildShareApp(),
                WListTile(
                  iconData: Icons.policy,
                  titleText: "Policy",
                  onTap: () {
                    launch("https://theacheng.github.io/storypad/");
                  },
                ),
                buildAboutUs(context),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WIconButton(
                      iconData: CommunityMaterialIcons.facebook,
                      filledColor: Theme.of(context).colorScheme.surface,
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      onPressed: () {
                        launch("https://facebook.com/tc.writestory");
                      },
                    ),
                    const SizedBox(width: 12.0),
                    WIconButton(
                      iconData: CommunityMaterialIcons.instagram,
                      filledColor: Theme.of(context).colorScheme.surface,
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      onPressed: () {
                        launch("https://www.instagram.com/tc.writestory/");
                      },
                    ),
                    const SizedBox(width: 12.0),
                    WIconButton(
                      iconData: CommunityMaterialIcons.google_play,
                      filledColor: Theme.of(context).colorScheme.surface,
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      onPressed: () {
                        launch(
                          "https://play.google.com/store/apps/details?id=com.tc.writestory",
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
            buildUpdateStatus(context),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 1,
      backgroundColor: Theme.of(context).colorScheme.surface,
      textTheme: Theme.of(context).textTheme,
      title: Text(
        tr("title.setting"),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      flexibleSpace: Consumer(
        builder: (context, reader, child) {
          final userNotifier = reader(authenticationProvider);
          return SafeArea(
            child: WLineLoading(
              loading: userNotifier.loading,
            ),
          );
        },
      ),
      leading: WIconButton(
        iconData: Icons.arrow_back,
        onPressed: () {
          ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget buildUpdateSpacer() {
    return Consumer(builder: (context, watch, child) {
      final updateNotifier = watch(checkForUpdateProvider);
      return ValueListenableBuilder(
        valueListenable: scrollOffsetNotifier,
        builder: (context, value, child) {
          final bool isCollapse = scrollOffsetNotifier.value < 200;
          return AnimatedContainer(
            duration: ConfigConstant.fadeDuration ~/ 3,
            height: updateNotifier.isUpdateAvailable && isCollapse ? kToolbarHeight : 0,
          );
        },
      );
    });
  }

  Widget buildUpdateStatus(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final notifier = watch(checkForUpdateProvider);
      return IgnorePointer(
        ignoring: !notifier.isUpdateAvailable,
        child: AnimatedOpacity(
          duration: ConfigConstant.fadeDuration,
          opacity: notifier.isUpdateAvailable == true ? 1 : 0,
          child: ValueListenableBuilder(
            valueListenable: scrollOffsetNotifier,
            child: Wrap(
              children: [
                Material(
                  elevation: 1.0,
                  child: WListTile(
                    iconData: Icons.system_update_alt_rounded,
                    titleText: tr("title.update_available"),
                    subtitleText: tr("subtitle.click_to_update"),
                    tileColor: Theme.of(context).colorScheme.error,
                    forgroundColor: Theme.of(context).colorScheme.onError,
                    onTap: () {
                      final dialog = Dialog(
                        child: Wrap(
                          children: [
                            if (notifier.flexibleUpdateAllowed)
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(ConfigConstant.radius1),
                                  ),
                                ),
                                title: Text(
                                  tr("button.update.flexible"),
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  InAppUpdate.startFlexibleUpdate();
                                },
                              ),
                            if (notifier.flexibleUpdateAllowed) const Divider(height: 0),
                            if (notifier.immediateUpdateAllowed)
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(ConfigConstant.radius1),
                                  ),
                                ),
                                title: Text(
                                  tr("button.update.immediate"),
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  InAppUpdate.performImmediateUpdate();
                                },
                              ),
                          ],
                        ),
                      );
                      showWDialog(context: context, child: dialog);
                    },
                  ),
                ),
              ],
            ),
            builder: (context, value, child) {
              final bool isCollapse = scrollOffsetNotifier.value < 200;

              return AnimatedContainer(
                duration: ConfigConstant.fadeDuration,
                transform: Matrix4.identity()..translate(0.0, !isCollapse ? -100.0 : 0.0),
                child: child,
              );
            },
          ),
        ),
      );
    });
  }

  Widget buildFontStyle(BuildContext context) {
    return WListTile(
      iconData: Icons.font_download_sharp,
      titleText: tr("title.font_style"),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return FontManagerScreen();
          }),
        );
      },
    );
  }

  Widget buildAboutUs(BuildContext context) {
    return WListTile(
      iconData: Icons.info,
      titleText: tr("button.about"),
      onTap: () async {
        final _theme = Theme.of(context);
        final _textTheme = Theme.of(context).textTheme;
        final _version = await GetVersion.projectVersion;
        final _code = await GetVersion.projectCode;

        showWAboutDialog(
          context: context,
          applicationName: "StoryPad",
          applicationVersion: "v$_version+$_code",
          children: [
            const SizedBox(height: 24.0),
            WTapEffect(
              onTap: () {
                launch("http://www.theachoem.com");
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    child: Text(
                      tr("position.thea"),
                      style: _textTheme.caption?.copyWith(
                        color: _theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      tr("name.thea"),
                      style: _textTheme.caption!.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            WTapEffect(
              onTap: () {
                launch("https://facebook.com/100004853777908");
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr("position.menglong"),
                    style: _textTheme.caption?.copyWith(
                      color: _theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    tr("name.menglong"),
                    style: _textTheme.caption!.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Divider(),
            WTapEffect(
              onTap: () async {
                final Uri params = Uri(
                  scheme: 'mailto',
                  path: 'theacheng.g6@gmail.com',
                );
                var url = params.toString();
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  print('Could not launch $url');
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contact",
                    style: _textTheme.caption?.copyWith(
                      color: _theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    "Email: theacheng.g6@gmail.com",
                    style: _textTheme.caption!.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Phnom Penh, Cambodia",
                    style: _textTheme.caption,
                  ),
                ],
              ),
            ),
          ],
          applicationIcon: GestureDetector(
            onTap: () {
              StoryDetailScreen(
                story: StoryModel.empty,
              ).showImageViewerSheet(
                context,
                Image.asset('assets/icons/app_icon.png'),
                MediaQuery.of(context).padding,
                null,
              );
            },
            child: ClipRRect(
              borderRadius: ConfigConstant.circlarRadius1,
              child: Image.asset(
                "assets/icons/ic_launcher_round.png",
                height: ConfigConstant.iconSize3,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildRate() {
    return WListTile(
      iconData: Icons.rate_review,
      titleText: tr("button.rate"),
      onTap: () async {
        await LaunchReview.launch();
      },
    );
  }

  Widget buildShareApp() {
    return WListTile(
      iconData: Icons.share,
      titleText: tr("button.share"),
      onTap: () async {
        await Share.share(
          "StoryPad - Write Your Story, Note, Diary. Download now on Play Store: https://play.google.com/store/apps/details?id=com.tc.writestory",
        );
      },
    );
  }

  Consumer buildRelateToLanguage() {
    return Consumer(
      builder: (context, reader, child) {
        return WListTile(
          iconData: Icons.language,
          titleText: tr("button.language"),
          subtitleText: context.locale.languageCode == "km" ? "ខ្មែរ" : "English",
          onTap: () {
            final dialog = Dialog(
              child: Wrap(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(ConfigConstant.radius1),
                      ),
                    ),
                    title: Text("ខ្មែរ", textAlign: TextAlign.center),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.setLocale(Locale("km"));
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(ConfigConstant.radius1),
                      ),
                    ),
                    title: Text("English", textAlign: TextAlign.center),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.setLocale(Locale("en"));
                    },
                  ),
                ],
              ),
            );
            showWDialog(context: context, child: dialog);
          },
        );
      },
    );
  }

  Consumer buildRelateToTheme() {
    return Consumer(
      builder: (context, reader, child) {
        final notifier = reader(themeProvider);
        return Column(
          children: [
            WListTile(
              iconData: Icons.nightlight_round,
              titleText: tr("button.theme"),
              subtitleText: notifier.isDarkModeSystem == null
                  ? tr("button.theme.system")
                  : notifier.isDarkModeSystem == true
                      ? tr("button.theme.dark")
                      : tr("button.theme.light"),
              onTap: () {
                final dialog = Dialog(
                  child: Wrap(
                    children: [
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(ConfigConstant.radius1),
                          ),
                        ),
                        title: Text(
                          tr("button.theme.dark"),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          notifier.setDarkMode(true);
                        },
                      ),
                      const Divider(height: 0),
                      ListTile(
                        title: Text(
                          tr("button.theme.light"),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          notifier.setDarkMode(false);
                        },
                      ),
                      const Divider(height: 0),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(ConfigConstant.radius1),
                          ),
                        ),
                        title: Text(
                          tr("button.theme.system"),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          notifier.setDarkMode(null);
                        },
                      ),
                    ],
                  ),
                );
                showWDialog(context: context, child: dialog);
              },
            ),
            WListTile(
              iconData: Icons.list_alt,
              titleText: tr("button.layout"),
              subtitleText: notifier.isNormalList ? tr("button.layout.normal") : tr("button.layout.tab"),
              onTap: () {
                final dialog = Dialog(
                  child: Wrap(
                    children: [
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(ConfigConstant.radius1),
                          ),
                        ),
                        title: Text(tr("button.layout.normal")),
                        subtitle: Text(
                          tr("button.layout.normal.info"),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          notifier.setListLayout(true);
                        },
                      ),
                      const Divider(height: 0),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(ConfigConstant.radius1),
                          ),
                        ),
                        title: Text(tr("button.layout.tab")),
                        subtitle: Text(
                          tr("button.layout.tab.info"),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          notifier.setListLayout(false);
                        },
                      ),
                    ],
                  ),
                );
                showWDialog(context: context, child: dialog);
              },
            ),
          ],
        );
      },
    );
  }

  Consumer buildRelateToAccount() {
    return Consumer(
      builder: (context, reader, child) {
        final userNotifier = reader(authenticationProvider);
        final dbNotifier = reader(remoteDatabaseProvider);

        final bool imageNotNull = userNotifier.isAccountSignedIn && userNotifier.user!.photoURL != null;
        // Variable holding the original String portion of the url that will be replaced
        String originalPieceOfUrl = "s96-c";

        // Variable holding the new String portion of the url that does the replacing, to improve image quality
        String newPieceOfUrlToAdd = "s0";

        String? imageUrl;
        if (imageNotNull) {
          imageUrl = "${userNotifier.user!.photoURL}".replaceAll(
            "$originalPieceOfUrl",
            "$newPieceOfUrlToAdd",
          );
        }

        return Column(
          children: [
            if (imageNotNull) buildProfile(context, imageUrl!),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                backgroundColor: Theme.of(context).colorScheme.surface,
                collapsedBackgroundColor: Theme.of(context).colorScheme.surface,
                initiallyExpanded: true,
                leading: AspectRatio(
                  aspectRatio: 1.5 / 2,
                  child: Container(
                    height: double.infinity,
                    child: Icon(Icons.person),
                  ),
                ),
                title: Text(tr("title.google_acc")),
                subtitle: Text(
                  userNotifier.isAccountSignedIn ? "${userNotifier.user?.email}" : tr("msg.login.info"),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ),
                children: [
                  if (userNotifier.isAccountSignedIn && dbNotifier.backup != null)
                    WTapEffect(
                      onTap: () {},
                      child: WListTile(
                        tileColor: Theme.of(context).colorScheme.surface,
                        iconData: locked ? Icons.lock : Icons.restore,
                        titleText: tr("button.backup.import"),
                        subtitleText: dbNotifier.backup?.name ??
                            tr("msg.backup.import", namedArgs: {
                              "DATE": dbNotifier.lastImportDate(context),
                            }),
                        onTap: () async {
                          if (locked) {
                            showSnackBar(
                              context: context,
                              title: tr("msg.locked"),
                            );
                            return;
                          }
                          dbNotifier.restoreFromCloud(
                            context: context,
                            showSnackbar: true,
                          );
                        },
                      ),
                    ),
                  if (userNotifier.isAccountSignedIn)
                    ListTile(
                      leading: const SizedBox(),
                      title: BackupButton(
                        left: 0.0,
                        isSignedIn: userNotifier.isAccountSignedIn,
                      ),
                    ),
                  WTapEffect(
                    onTap: () {},
                    child: WListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      iconData: locked
                          ? Icons.lock
                          : userNotifier.isAccountSignedIn
                              ? Icons.logout
                              : Icons.login,
                      titleText: userNotifier.isAccountSignedIn ? tr("button.signout") : tr("button.connect"),
                      onTap: () async {
                        if (locked) {
                          showSnackBar(
                            context: context,
                            title: tr("msg.locked"),
                          );
                          return;
                        }

                        if (userNotifier.isAccountSignedIn) {
                          await userNotifier.signOut();
                          context.read(remoteDatabaseProvider).reset();
                        } else {
                          bool success = await userNotifier.logAccount();
                          if (success == true) {
                            showSnackBar(
                              context: context,
                              title: tr("msg.login.success"),
                            );
                            context.read(remoteDatabaseProvider).load();
                          } else {
                            showSnackBar(
                              context: context,
                              title: userNotifier.service?.errorMessage != null
                                  ? userNotifier.service?.errorMessage as String
                                  : tr("msg.login.fail"),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildProfile(BuildContext context, String imageUrl) {
    final width = MediaQuery.of(context).size.width;

    return ValueListenableBuilder(
      valueListenable: scrollOffsetNotifier,
      builder: (context, value, child) {
        final bool isCollapse = scrollOffsetNotifier.value < 200;
        final _avatarSize = isCollapse ? width : this.avatarSize;
        final _padding = isCollapse ? EdgeInsets.zero : EdgeInsets.all(16);

        return AnimatedContainer(
          duration: ConfigConstant.duration,
          curve: Curves.easeOutQuart,
          width: width,
          height: width,
          padding: _padding,
          alignment: Alignment.bottomCenter,
          color: Theme.of(context).colorScheme.background,
          child: AnimatedOpacity(
            duration: ConfigConstant.fadeDuration,
            curve: Curves.decelerate,
            opacity: scrollOffsetNotifier.value < 350 ? 1 : 0,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                AnimatedContainer(
                  duration: ConfigConstant.duration,
                  curve: Curves.easeOutQuart,
                  width: _avatarSize,
                  height: _avatarSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      isCollapse ? 0 : _avatarSize,
                    ),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: ConfigConstant.duration,
                  width: double.infinity,
                  curve: Curves.easeOutQuart,
                  height: 72,
                  margin: EdgeInsets.only(left: isCollapse ? 0 : this.avatarSize + 16),
                  decoration: BoxDecoration(
                    borderRadius: isCollapse ? BorderRadius.zero : ConfigConstant.circlarRadius2,
                    color: Theme.of(context).colorScheme.primary.withOpacity(isCollapse ? 1 : 1),
                  ),
                  child: ListTile(
                    title: Text(
                      "Google Drive",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    subtitle: Text(
                      isCollapse ? tr("msg.drive.info.long") : tr("msg.drive.info.short"),
                      maxLines: 1,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    trailing: Container(
                      width: 24,
                      child: WIconButton(
                        iconData: Icons.arrow_right,
                        onPressed: () {},
                        iconColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    onTap: () async {
                      if (locked) {
                        showSnackBar(context: context, title: tr("msg.locked"));
                        return;
                      }

                      final String? id = await GoogleDriveApi.getStoryFolderId();
                      if (id != null) {
                        launch(
                          "https://drive.google.com/drive/folders/$id?usp=sharing",
                        );
                      } else {
                        showSnackBar(
                          context: context,
                          title: tr("msg.drive.folder.fail"),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
