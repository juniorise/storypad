import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/app_helper/app_helper.dart';
import 'package:storypad/colors/colors.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/dialog_mixin.dart';
import 'package:storypad/models/member_model.dart';
import 'package:storypad/models/pending_model.dart';
import 'package:storypad/models/story_list_model.dart';
import 'package:storypad/models/story_model.dart';
import 'package:storypad/notifier/group_screen_notifier.dart';
import 'package:storypad/screens/group_info_screen.dart';
import 'package:storypad/screens/story_detail_screen.dart';
import 'package:storypad/services/authentication_service.dart';
import 'package:storypad/services/encrypt_service.dart';
import 'package:storypad/sheets/ask_for_name_sheet.dart';
import 'package:storypad/widgets/w_icon_button.dart';
import 'package:storypad/widgets/w_no_data.dart';
import 'package:storypad/widgets/w_story_tile.dart';

class GroupScreen extends HookWidget with DialogMixin {
  @override
  Widget build(BuildContext context) {
    print("Build GroupScreen");

    GroupScreenNotifier notifier = useProvider(groupScreenProvider);
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
        Navigator.of(context).pop();
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          TextEditingController().clear();
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 1,
            backgroundColor: Theme.of(context).colorScheme.surface,
            textTheme: Theme.of(context).textTheme,
            title: Text(
              notifier.groupModel?.groupName ?? tr("title.group"),
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
            actions: [
              WIconButton(
                iconData: Icons.settings,
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return GroupInfoScreen();
                    }),
                  );
                  Future.delayed(ConfigConstant.fadeDuration).then(
                    (value) async {
                      await notifier.load();
                    },
                  );
                },
              ),
            ],
          ),
          body: ListView(
            children: [
              buildPending(notifier),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ConfigConstant.margin2,
                ),
                child: Column(
                  children: [
                    notifier.storyByIdAsList.length == 0
                        ? Column(
                            children: [
                              WNoData(customText: tr("msg.no_sharing_data")),
                            ],
                          )
                        : Column(
                            children: List.generate(
                              notifier.storyByIdAsList.length,
                              (index) {
                                final story = notifier.storyByIdAsList[index];
                                return buildUserStoryTile(
                                  notifier: notifier,
                                  context: context,
                                  story: story,
                                  imageUrl:
                                      AuthenticationService().user?.photoURL,
                                  onTap: () async {
                                    final date =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (context) {
                                          return StoryDetailScreen(
                                            story: story,
                                          );
                                        },
                                      ),
                                    );

                                    if (date != null) {
                                      await notifier.load();
                                    }
                                  },
                                  readOnly: false,
                                );
                              },
                            ),
                          ),
                    StreamBuilder<List<MemberModel>>(
                      stream: notifier.fetchMembers(),
                      builder: (context, snapshot) {
                        List<MemberModel> members = [];
                        if (snapshot.hasData) {
                          members = snapshot.data ?? [];
                          members.removeWhere(
                            (element) => element.email == notifier.email,
                          );
                        }

                        return Column(
                          children: List.generate(
                            members.length,
                            (index) {
                              List<StoryModel> stories = [];
                              final member = members[index];
                              if (member.db != null &&
                                  member.db?.isNotEmpty == true) {
                                var result =
                                    EncryptService.storyMapDecrypt(member.db!);
                                if (result != null) {
                                  stories = result.entries
                                      .map((e) => e.value)
                                      .toList();
                                }
                              }
                              return Column(
                                children: List.generate(
                                  stories.length,
                                  (_index) {
                                    final story = stories[_index];
                                    return buildUserStoryTile(
                                      context: context,
                                      story: story,
                                      imageUrl: member.photoUrl,
                                      readOnly: true,
                                      notifier: notifier,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            fullscreenDialog: true,
                                            builder: (context) {
                                              return StoryDetailScreen(
                                                story: story,
                                                forceReadOnly: true,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container buildUserStoryTile({
    required BuildContext context,
    required StoryModel story,
    required bool readOnly,
    required void Function() onTap,
    required GroupScreenNotifier notifier,
    String? imageUrl,
  }) {
    final _sizedBox = const SizedBox(width: 8.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDayContainer(
                context: context,
                storyModel: story,
                imageUrl: imageUrl,
              ),
              _sizedBox,
              Expanded(
                child: WStoryTile(
                  readOnly: readOnly,
                  onSaved: (DateTime date) {},
                  onTap: onTap,
                  story: story,
                  onToggleSync: () async {
                    await notifier.load();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPending(GroupScreenNotifier notifier) {
    return StreamBuilder<PendingModel?>(
      stream: notifier.hasPending(),
      builder: (context, snapshot) {
        PendingModel? pendingModel;
        if (snapshot.hasData) {
          final result = snapshot.data;
          if (result?.sendByEmail == null && result?.groupId == null) {
            pendingModel = null;
          } else {
            pendingModel = result;
          }
        }
        return IgnorePointer(
          ignoring: pendingModel == null,
          child: AnimatedOpacity(
            duration: ConfigConstant.fadeDuration,
            opacity: pendingModel == null ? 0 : 1,
            child: AnimatedContainer(
              height: pendingModel == null ? 0 : kToolbarHeight * 2,
              duration: ConfigConstant.fadeDuration,
              child: Wrap(
                children: [
                  Builder(
                    builder: (context) {
                      String? subtitle;
                      String? title = tr("msg.invitation.alert");

                      String groupName = pendingModel?.groupName ?? "";
                      String sendByEmail = pendingModel?.sendByEmail ?? "";

                      if (pendingModel?.sendByEmail != null) {
                        subtitle = tr("msg.invitation.subtitle", namedArgs: {
                          "GROUP_NAME": groupName,
                          "SEND_BY": sendByEmail,
                        });
                      }
                      return ListTile(
                        onTap: () async {},
                        title: Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        subtitle: Text(
                          subtitle ?? "",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        tileColor: Theme.of(context).colorScheme.error,
                      );
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (pendingModel == null) return;
                          await notifier.acceptPending(pendingModel);
                        },
                        child: Text(tr('button.accept')),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (pendingModel == null) return;
                          await notifier.cancelPending(pendingModel);
                        },
                        child: Text(tr('button.cancel')),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTextFormField(BuildContext context) {
    final border = UnderlineInputBorder(
      borderRadius: ConfigConstant.circlarRadius2,
      borderSide: BorderSide(
        color: Colors.transparent,
      ),
    );
    return Material(
      borderRadius: ConfigConstant.circlarRadius2,
      elevation: 0.25,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: tr('input.group.title'),
          border: border,
          enabledBorder: border,
          errorBorder: border,
          disabledBorder: border,
          focusedBorder: border,
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
        ),
      ),
    );
  }

  Widget buildDayContainer({
    required BuildContext context,
    required StoryModel storyModel,
    String? imageUrl,
  }) {
    /// get stand color of the week
    final int dayOfWeek = AppHelper.dayOfWeek(context, storyModel.forDate);
    final Color standColor = colorsByDay[dayOfWeek]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Since អាទិត្យ is biggest text,
        /// we used it for size other widget
        Opacity(
          opacity: 0,
          child: Text(
            "អាទិត្យ",
            style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 0),
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 4.0),
            Stack(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: standColor,
                    image: imageUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(imageUrl),
                          )
                        : null,
                  ),
                  child: imageUrl == null ? Icon(Icons.person, size: 16) : null,
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Column buildDateMonthHeader(
    BuildContext context,
    StoryListModel _storyListModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: ConfigConstant.margin2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: const Divider(endIndent: 8)),
            Material(
              elevation: 0.3,
              borderRadius: BorderRadius.circular(100),
              color: Theme.of(context).colorScheme.surface,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ConfigConstant.margin2,
                  vertical: ConfigConstant.margin0,
                ),
                child: Text(
                  AppHelper.toFullNameOfMonth(context)
                      .format(_storyListModel.forDate),
                ),
              ),
            ),
            Expanded(child: const Divider(indent: 8)),
          ],
        ),
        const SizedBox(height: ConfigConstant.margin1),
      ],
    );
  }
}
