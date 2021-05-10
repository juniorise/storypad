import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/snakbar_mixin.dart';
import 'package:storypad/models/font_model.dart';
import 'package:storypad/notifier/font_manager_notifier.dart';
import 'package:storypad/screens/setting_screen.dart';
import 'package:storypad/sheets/ask_for_name_sheet.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';
import 'package:storypad/widgets/w_icon_button.dart';

class FontManagerScreen extends HookWidget with WSnackBar {
  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(fontManagerProvider);
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          backgroundColor: Theme.of(context).colorScheme.surface,
          textTheme: Theme.of(context).textTheme,
          title: Text(
            tr("title.font_style"),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          flexibleSpace: Consumer(
            builder: (context, reader, child) {
              return SafeArea(
                child: WLineLoading(
                  loading: notifier.loading,
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
        ),
        body: ListView(
          children: FontModel.avaiableFontsMap.entries.map((e) {
            return Column(
              children: [
                buildHeader(context, e.key.toLanguageTag().toUpperCase()),
                Column(
                  children: List.generate(
                    e.value.length,
                    (index) {
                      final font = e.value[index];
                      final _theme = Theme.of(context);
                      final String? _font =
                          _theme.textTheme.bodyText1?.fontFamilyFallback?[0];
                      return Theme(
                        data: _theme.copyWith(
                          textTheme: _theme.textTheme
                              .apply(fontFamily: font.familyName),
                        ),
                        child: WListTile(
                          iconData: notifier.fontFamilyFallback
                                  .contains(font.familyName)
                              ? Icons.font_download
                              : Icons.font_download_outlined,
                          titleText: font.familyName,
                          titleFontFamily: "$_font",
                          subtitleText: FontModel.localeExamples[font.locale],
                          subtitleMaxLines: 1,
                          onTap: () async {
                            onTapVibrate();
                            ScaffoldMessenger.maybeOf(context)!
                                .removeCurrentSnackBar();
                            if (!notifier.fontFamilyFallback
                                .contains(font.familyName)) {
                              await notifier
                                  .replaceFontInMap(
                                font.familyName,
                                font.locale,
                              )
                                  .then(
                                (success) {
                                  Future.delayed(ConfigConstant.fadeDuration)
                                      .then(
                                    (value) {
                                      showSnackBar(
                                        context: context,
                                        title: success
                                            ? tr("msg.update.success")
                                            : tr(
                                                "msg.update.fail",
                                              ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: ConfigConstant.margin1),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Column buildHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: ConfigConstant.margin2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: const Divider(endIndent: 8, indent: 16.0)),
            Material(
              elevation: 0.3,
              borderRadius: BorderRadius.circular(100),
              color: Theme.of(context).colorScheme.surface,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ConfigConstant.margin2,
                  vertical: ConfigConstant.margin0,
                ),
                child: Text(title),
              ),
            ),
            Expanded(child: const Divider(indent: 8, endIndent: 16.0)),
          ],
        ),
        const SizedBox(height: ConfigConstant.margin1),
      ],
    );
  }
}
