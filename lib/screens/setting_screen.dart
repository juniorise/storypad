import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';
import 'package:write_story/app_helper/app_helper.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/database/w_database.dart';
import 'package:write_story/mixins/dialog_mixin.dart';
import 'package:write_story/mixins/snakbar_mixin.dart';
import 'package:write_story/models/db_backup_model.dart';
import 'package:write_story/notifier/auth_notifier.dart';
import 'package:write_story/notifier/home_screen_notifier.dart';
import 'package:write_story/notifier/remote_database_notifier.dart';
import 'package:write_story/notifier/theme_notifier.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_icon_button.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingScreen extends HookWidget with DialogMixin, WSnackBar {
  final double avatarSize = 72;
  final ValueNotifier<double> scrollOffsetNotifier = ValueNotifier<double>(0);
  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    scrollController.addListener(() {
      scrollOffsetNotifier.value = scrollController.offset;
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.5,
        backgroundColor: Theme.of(context).colorScheme.surface,
        textTheme: Theme.of(context).textTheme,
        title: Text(
          "Setting",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: WIconButton(
          iconData: Icons.clear,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        controller: scrollController,
        children: [
          buildRelateToAccount(),
          buildRelateToTheme(),
          buildRelateToLanguage(),
          buildFontStyle(),
          buildRate(),
          buildAboutUs(context),
          buildShareApp(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  ListTile buildFontStyle() {
    return ListTile(
      leading: AspectRatio(
        aspectRatio: 1.5 / 2,
        child: Container(
          height: double.infinity,
          child: Icon(Icons.font_download_sharp),
        ),
      ),
      title: Text("Font Style"),
      subtitle: Text("Quicksand"),
      onTap: () {},
    );
  }

  ListTile buildAboutUs(BuildContext context) {
    return ListTile(
      leading: AspectRatio(
        aspectRatio: 1.5 / 2,
        child: Container(
          height: double.infinity,
          child: Icon(Icons.info),
        ),
      ),
      title: Text("About us"),
      onTap: () {
        final _theme = Theme.of(context);
        final _textTheme = Theme.of(context).textTheme;

        showAboutDialog(
          context: context,
          applicationName: "Story",
          applicationVersion: "v1.0.0+7",
          applicationLegalese: tr("info.app_detail"),
          children: [
            const SizedBox(height: 24.0),
            Text(
              tr("position.thea"),
              style: _textTheme.caption?.copyWith(
                color: _theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            Text(
              tr("name.thea"),
              style: _textTheme.caption!.copyWith(fontWeight: FontWeight.w600),
            ),
            const Divider(),
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
          applicationIcon: ClipRRect(
            borderRadius: ConfigConstant.circlarRadius1,
            child: Image.asset(
              "assets/icons/app_icon.png",
              height: ConfigConstant.iconSize3,
            ),
          ),
        );
      },
    );
  }

  ListTile buildRate() {
    return ListTile(
      leading: AspectRatio(
        aspectRatio: 1.5 / 2,
        child: Container(
          height: double.infinity,
          child: Icon(Icons.rate_review),
        ),
      ),
      title: Text("Rate us"),
      onTap: () async {
        await LaunchReview.launch();
      },
    );
  }

  ListTile buildShareApp() {
    return ListTile(
      leading: AspectRatio(
        aspectRatio: 1.5 / 2,
        child: Container(
          height: double.infinity,
          child: Icon(Icons.share),
        ),
      ),
      title: Text("Share"),
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
        return ListTile(
          leading: AspectRatio(
            aspectRatio: 1.5 / 2,
            child: Container(
              height: double.infinity,
              child: Icon(Icons.language),
            ),
          ),
          title: Text("Language"),
          subtitle: Text(
            context.locale.languageCode == "km" ? "ខ្មែរ" : "English",
          ),
          onTap: () {
            final dialog = Dialog(
              child: Wrap(
                children: [
                  ListTile(
                    leading: AspectRatio(
                      aspectRatio: 1.5 / 2,
                      child: Container(
                        height: double.infinity,
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset("assets/flags/km-flag.png"),
                      ),
                    ),
                    title: Text("ខ្មែរ"),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.setLocale(Locale("km"));
                    },
                  ),
                  ListTile(
                    leading: AspectRatio(
                      aspectRatio: 1.5 / 2,
                      child: Container(
                        height: double.infinity,
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset("assets/flags/en-flag.png"),
                      ),
                    ),
                    title: Text("English"),
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
            ListTile(
              leading: AspectRatio(
                aspectRatio: 1.5 / 2,
                child: Container(
                  height: double.infinity,
                  child: Icon(Icons.nightlight_round),
                ),
              ),
              title: Text("Theme"),
              subtitle: Text(
                notifier.isDarkMode == null
                    ? "System"
                    : notifier.isDarkMode == true
                        ? "Dark"
                        : "Light",
              ),
              onTap: () {
                final dialog = Dialog(
                  child: Wrap(
                    children: [
                      ListTile(
                        title: Text("Dark"),
                        onTap: () {
                          Navigator.of(context).pop();
                          notifier.setDarkMode(true);
                        },
                      ),
                      ListTile(
                        title: Text("Light"),
                        onTap: () {
                          Navigator.of(context).pop();
                          notifier.setDarkMode(false);
                        },
                      ),
                      ListTile(
                        title: Text("System"),
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
            ListTile(
              leading: AspectRatio(
                aspectRatio: 1.5 / 2,
                child: Container(
                  height: double.infinity,
                  child: Icon(Icons.list_alt),
                ),
              ),
              title: Text("Layout"),
              subtitle: Text(notifier.isNormalList ? "Normal" : "Tab"),
              onTap: () {
                final dialog = Dialog(
                  child: Wrap(
                    children: [
                      ListTile(
                        title: Text("Normal"),
                        subtitle: Text(
                          "Display all stories as a list view",
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          notifier.setListLayout(true);
                        },
                      ),
                      ListTile(
                        title: Text("Tab"),
                        subtitle: Text(
                          "Display all stories by divide them by month",
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
        final dbNotifier = reader(remoteDatabaseProvider)..load();
        final WDatabase database = WDatabase.instance;

        final bool imageNotNull = userNotifier.isAccountSignedIn &&
            userNotifier.user!.photoURL != null;
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

          print("$imageUrl");
        }

        return Column(
          children: [
            if (imageNotNull) buildProfile(context, imageUrl!),
            ExpansionTile(
              backgroundColor: Theme.of(context).colorScheme.surface,
              initiallyExpanded: true,
              leading: AspectRatio(
                aspectRatio: 1.5 / 2,
                child: Container(
                  height: double.infinity,
                  child: Icon(Icons.person),
                ),
              ),
              title: Text("Google Account"),
              subtitle: Text(
                userNotifier.isAccountSignedIn
                    ? "${userNotifier.user?.email}"
                    : tr("msg.login.info"),
              ),
              children: [
                if (userNotifier.isAccountSignedIn)
                  ListTile(
                    tileColor: Theme.of(context).colorScheme.surface,
                    leading: AspectRatio(
                      aspectRatio: 1.5 / 2,
                      child: Container(
                        height: double.infinity,
                        child: Icon(Icons.backup),
                      ),
                    ),
                    title: Text("Sync data"),
                    subtitle: Text(tr("msg.backup.export")),
                    onTap: () async {
                      showSnackBar(
                        context: context,
                        title: tr("msg.backup.export.warning"),
                        onActionPressed: () async {
                          String backup = await database.generateBackup();
                          final backupModel = DbBackupModel(
                            createOn: Timestamp.now(),
                            db: backup,
                          );
                          final bool success =
                              await dbNotifier.replace(backupModel);

                          if (success) {
                            showSnackBar(
                              context: context,
                              title: tr("msg.backup.export.success"),
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
                  ),
                if (userNotifier.isAccountSignedIn && dbNotifier.backup != null)
                  ListTile(
                    tileColor: Theme.of(context).colorScheme.surface,
                    leading: AspectRatio(
                      aspectRatio: 1.5 / 2,
                      child: Container(
                        height: double.infinity,
                        child: Icon(Icons.restore),
                      ),
                    ),
                    title: Text("Restore"),
                    subtitle: Text(
                      tr(
                        "msg.backup.import",
                        namedArgs: {
                          "DATE": AppHelper.dateFormat(context).format(
                                  dbNotifier.backup!.createOn.toDate()) +
                              ", " +
                              AppHelper.timeFormat(context)
                                  .format(dbNotifier.backup!.createOn.toDate())
                        },
                      ),
                    ),
                    onTap: () async {
                      final bool success =
                          await database.restoreBackup(dbNotifier.backup!.db);
                      onTapVibrate();
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
                  ),
                ListTile(
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: AspectRatio(
                    aspectRatio: 1.5 / 2,
                    child: Container(
                      height: double.infinity,
                      child: Icon(userNotifier.isAccountSignedIn
                          ? Icons.logout
                          : Icons.login),
                    ),
                  ),
                  title: Text(
                    userNotifier.isAccountSignedIn ? "Sign out" : "Connect",
                  ),
                  onTap: () async {
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
              ],
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
          duration: ConfigConstant.fadeDuration,
          width: width,
          height: width,
          padding: _padding,
          alignment: Alignment.bottomCenter,
          color: Theme.of(context).colorScheme.background,
          child: AnimatedOpacity(
            duration: ConfigConstant.fadeDuration,
            opacity: scrollOffsetNotifier.value < 350 ? 1 : 0,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                AnimatedContainer(
                  duration: ConfigConstant.fadeDuration,
                  curve: Curves.linear,
                  width: _avatarSize,
                  height: _avatarSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      isCollapse ? 0 : _avatarSize,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: ConfigConstant.fadeDuration,
                  width: double.infinity,
                  height: 72,
                  margin: EdgeInsets.only(
                      left: isCollapse ? 0 : this.avatarSize + 16),
                  decoration: BoxDecoration(
                    borderRadius: isCollapse
                        ? BorderRadius.zero
                        : ConfigConstant.circlarRadius2,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(isCollapse ? 1 : 1),
                  ),
                  child: ListTile(
                    title: Text(
                      "Google Drive",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    subtitle: Text(
                      isCollapse
                          ? "Check all images that you've uploaded"
                          : "Check all images",
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
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ListView buildListView() {
    return ListView(
      children: [
        ListTile(
          leading: Container(
            height: double.infinity,
            child: Icon(
              Icons.nightlight_round,
            ),
          ),
          title: Text("Theme"),
          subtitle: Text("System"),
          onTap: () {},
        ),
        ListTile(
          leading: AspectRatio(
            aspectRatio: 1.5 / 2,
            child: Container(
              height: double.infinity,
              child: Icon(
                Icons.nightlight_round,
              ),
            ),
          ),
          title: Text("Theme"),
          subtitle: Text("System"),
          onTap: () {},
        ),
      ],
    );
  }
}
