import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/notifier/theme_notifier.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';
import 'package:storypad/widgets/w_icon_button.dart';

class MoreVertButton extends StatelessWidget {
  const MoreVertButton({
    Key? key,
    required this.story,
    required this.insert,
    required this.readOnly,
    required this.forceReadOnly,
    required this.onDelete,
    required this.onSave,
    required this.onShowInfo,
    required this.onShare,
    required this.onReadOnlyTap,
  }) : super(key: key);

  final StoryModel story;
  final bool insert;
  final bool readOnly;
  final bool forceReadOnly;
  final void Function() onDelete;
  final void Function() onSave;
  final void Function() onShowInfo;
  final void Function() onShare;
  final void Function() onReadOnlyTap;

  @override
  Widget build(BuildContext context) {
    return WIconButton(
      iconData: Icons.more_vert,
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) {
    final _theme = Theme.of(context);

    bool showDelete = true;
    bool showSave = true;
    bool showInfo = true;
    bool showShare = true;
    bool showDarkMode = true;
    bool showReadOnly = true;

    showDelete = !insert;
    showInfo = !insert;

    if (forceReadOnly) {
      showSave = false;
      showDelete = false;
      showReadOnly = false;
    }

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(8.0, 0.0, 0.0, 0.0),
      items: [
        if (showDelete)
          PopupMenuItem(
            child: VTOnTapEffect(
              onTap: onDelete,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ConfigConstant.margin1,
                ),
                leading: Icon(
                  Icons.delete,
                  color: _theme.colorScheme.error,
                ),
                title: Text(tr("button.delete")),
              ),
            ),
          ),
        if (showSave)
          PopupMenuItem(
            child: VTOnTapEffect(
              onTap: onSave,
              child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ConfigConstant.margin1,
                  ),
                  leading: const Icon(Icons.save),
                  title: Text(tr("button.save"))),
            ),
          ),
        if (showInfo)
          PopupMenuItem(
            child: VTOnTapEffect(
              onTap: onShowInfo,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ConfigConstant.margin1,
                ),
                leading: Icon(Icons.info),
                title: Text(
                  tr("button.info"),
                ),
              ),
            ),
          ),
        if (showShare)
          PopupMenuItem(
            child: VTOnTapEffect(
              onTap: onShare,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ConfigConstant.margin1,
                ),
                leading: Icon(Icons.share),
                title: Text(tr("button.share")),
              ),
            ),
          ),
        if (showDarkMode)
          PopupMenuItem(
            child: Consumer(
              builder: (context, watch, child) {
                final notifier = watch(themeProvider);
                return VTOnTapEffect(
                  onTap: () {
                    Navigator.of(context).pop();
                    Future.delayed(ConfigConstant.duration).then(
                      (value) {
                        onTapVibrate();
                        notifier.toggleTheme();
                      },
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: ConfigConstant.margin1,
                    ),
                    leading: const Icon(Icons.nights_stay),
                    title: Text(tr("button.dark_mode")),
                    trailing: Container(
                      child: Switch(
                        value: notifier.isDarkMode == true,
                        onChanged: (bool value) {
                          Navigator.of(context).pop();
                          Future.delayed(ConfigConstant.duration).then(
                            (value) {
                              onTapVibrate();
                              notifier.toggleTheme();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        if (showReadOnly)
          PopupMenuItem(
            child: VTOnTapEffect(
              onTap: onReadOnlyTap,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ConfigConstant.margin1,
                ),
                leading: Icon(!readOnly
                    ? Icons.chrome_reader_mode_outlined
                    : Icons.chrome_reader_mode),
                title: Text(tr("button.read_only")),
                trailing: Switch(
                  value: readOnly,
                  onChanged: (bool value) {
                    onReadOnlyTap();
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
