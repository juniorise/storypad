import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/app_helper/app_helper.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/database/w_database.dart';
import 'package:write_story/mixins/dialog_mixin.dart';
import 'package:write_story/mixins/snakbar_mixin.dart';
import 'package:write_story/models/member_model.dart';
import 'package:write_story/notifier/group_listing_notifier.dart';
import 'package:write_story/notifier/member_info_notifier.dart';
import 'package:write_story/screens/setting_screen.dart';
import 'package:write_story/sheets/ask_for_name_sheet.dart';
import 'package:write_story/widgets/vt_tab_view.dart';
import 'package:write_story/widgets/w_icon_button.dart';
import 'package:write_story/widgets/w_no_data.dart';

class GroupInfoScreen extends HookWidget with DialogMixin, WSnackBar {
  const GroupInfoScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    MembersInfoNotifier membersInfoNotifier = useProvider(membersInfoProvider);
    GroupListingScreenNotifer groupListingNotifier =
        useProvider(groupListingProvider);

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
            tr('title.group_info'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          flexibleSpace: Consumer(
            builder: (context, reader, child) {
              return SafeArea(
                child: WLineLoading(
                  loading: membersInfoNotifier.loading ||
                      groupListingNotifier.loading,
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
          bottom: TabBar(
            controller: tabController,
            labelColor: Theme.of(context).colorScheme.onSurface,
            labelStyle: Theme.of(context).textTheme.bodyText2,
            tabs: [
              Tab(text: tr('title.group.members')),
              Tab(text: tr('title.group.groups')),
            ],
          ),
          actions: [
            buildActionButton(
              tabController,
              membersInfoNotifier,
              groupListingNotifier,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await membersInfoNotifier.load();
            await groupListingNotifier.load();
          },
          child: VTTabView(
            controller: tabController,
            children: [
              buildMemberListing(
                membersInfoNotifier: membersInfoNotifier,
                groupListingNotifier: groupListingNotifier,
                context: context,
              ),
              buildGroupListing(
                membersInfoNotifier: membersInfoNotifier,
                groupListingNotifier: groupListingNotifier,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedBuilder buildActionButton(
    TabController tabController,
    MembersInfoNotifier membersInfoNotifier,
    GroupListingScreenNotifer groupListingNotifier,
  ) {
    return AnimatedBuilder(
      animation: tabController.animation!,
      builder: (context, child) {
        final controller = tabController;
        final double offset = controller.animation?.value ?? 0;
        double opacity = 1;

        if (offset <= 0.5) {
          opacity = lerpDouble(1, -1, offset)!;
          if (membersInfoNotifier.group == null) opacity = 0;
        } else {
          opacity = lerpDouble(-1, 1, offset)!;
          if (membersInfoNotifier.auth.user == null) opacity = 0;
        }

        if (opacity < 0) opacity = 0;
        if (opacity > 1) opacity = 1;
        return Opacity(
          opacity: opacity,
          child: WIconButton(
            iconData: offset <= 0.5 ? Icons.person_add : Icons.group_add,
            onPressed: () async {
              if (opacity == 0) return;
              if (offset > 0.5) {
                final String? groupName = await showTextDialog(
                  context,
                  labelText: tr('input.group.title'),
                  hintText: tr('input.group.hint'),
                );
                if (groupName == null) return;
                await groupListingNotifier.createGroup("$groupName");
                await membersInfoNotifier.load();
              } else {
                if (membersInfoNotifier.group == null) return;
                final String? email = await showTextDialog(
                  context,
                  labelText: tr('input.email.title'),
                  hintText: tr('input.email.hint'),
                );

                if (email == null) return;
                if (!AppHelper.isEmail(email)) {
                  Future.delayed(ConfigConstant.fadeDuration).then(
                    (value) {
                      showSnackBar(
                        context: context,
                        title: tr('msg.email.invalid'),
                      );
                    },
                  );
                  return;
                }
                await membersInfoNotifier.addUserToGroup(email);
                await membersInfoNotifier.load();
              }
            },
          ),
        );
      },
    );
  }

  Consumer buildMemberListing({
    required MembersInfoNotifier membersInfoNotifier,
    required GroupListingScreenNotifer groupListingNotifier,
    required BuildContext context,
  }) {
    return Consumer(
      builder: (context, watch, child) {
        if (membersInfoNotifier.group?.groupId != null) {
          return StreamBuilder<List<MemberModel>>(
            stream: membersInfoNotifier.fetchMembers(),
            builder: (context, snapshot) {
              List<MemberModel> members = [];
              if (snapshot.hasData) members = snapshot.data ?? [];
              if (members.length == 0) {
                return buildMemberNoData(membersInfoNotifier, context, true);
              } else {
                return ListView(
                  padding: ConfigConstant.layoutPadding,
                  children: List.generate(
                    members.length,
                    (index) {
                      final member = members[index];
                      final bool hasPhoto = member.photoUrl != null &&
                          member.photoUrl?.isNotEmpty == true;

                      String? dateText;
                      DateTime? date;
                      if (member.joinOn != null) {
                        date = member.joinOn?.toDate();
                        dateText = member.joinOn != null
                            ? AppHelper.dateFormat(context).format(date!)
                            : null;
                      }

                      final subtitleText = dateText != null
                          ? tr('msg.joined_on', namedArgs: {"DATE": "$date"})
                          : null;
                      return Container(
                        margin: const EdgeInsets.only(top: 8.0),
                        child: Stack(
                          children: [
                            WListTile(
                              borderRadius: ConfigConstant.circlarRadius2,
                              iconData: hasPhoto ? null : Icons.person,
                              imageIcon: hasPhoto ? member.photoUrl : null,
                              titleText: member.invitedBy ==
                                      membersInfoNotifier.auth.user?.email
                                  ? member.email ?? ""
                                  : member.nickname ?? "",
                              subtitleText: subtitleText,
                              onTap: () {},
                            ),
                            if (member.joinOn == null &&
                                member.invitedBy ==
                                    membersInfoNotifier.auth.user?.email)
                              buildPendingButton(
                                context,
                                member,
                                membersInfoNotifier,
                              )
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          );
        } else {
          return buildMemberNoData(membersInfoNotifier, context, false);
        }
      },
    );
  }

  Center buildMemberNoData(
    MembersInfoNotifier membersInfoNotifier,
    BuildContext context,
    bool hasGroup,
  ) {
    String? errorText;
    if (membersInfoNotifier.auth.user == null) {
      errorText = tr('msg.group.no_auth');
    } else if (hasGroup) {
      errorText = tr("msg.group.member_empty");
    } else {
      errorText = tr('msg.group.no_member');
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WNoData(
            customText: errorText,
          ),
          if (membersInfoNotifier.auth.user == null)
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return SettingScreen();
                    },
                  ),
                );
              },
              child: Text(tr('button.open_setting')),
            ),
        ],
      ),
    );
  }

  Widget buildPendingButton(
    BuildContext context,
    MemberModel member,
    MembersInfoNotifier groupInfoNotifier,
  ) {
    return Positioned(
      right: 0.0,
      top: 0,
      bottom: 0,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.0).copyWith(right: 0),
            child: const Icon(Icons.sync, size: 20.0),
          ),
          Container(
            width: 48.0,
            child: WIconButton(
              iconData: Icons.delete,
              iconColor: Theme.of(context).colorScheme.error,
              onPressed: () async {
                if (member.email == null) return;
                if (groupInfoNotifier.group?.groupId == null) return;
                final service = groupInfoNotifier.service;
                await service.removePendingUserFromGroup(
                  email: member.email!,
                  groupId: groupInfoNotifier.group!.groupId!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGroupListing({
    required MembersInfoNotifier membersInfoNotifier,
    required GroupListingScreenNotifer groupListingNotifier,
    required BuildContext context,
  }) {
    if (groupListingNotifier.groups.length == 0) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WNoData(
              customText: membersInfoNotifier.auth.user == null
                  ? tr('msg.group.no_auth')
                  : tr('msg.group.no_group'),
            ),
            if (membersInfoNotifier.auth.user == null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SettingScreen();
                      },
                    ),
                  );
                },
                child: Text(tr('button.open_setting')),
              ),
          ],
        ),
      );
    } else {
      return ListView(
        padding: ConfigConstant.layoutPadding,
        children: List.generate(
          groupListingNotifier.groups.length,
          (index) {
            final group = groupListingNotifier.groups[index];
            bool selected = groupListingNotifier.selectedGroup == group.groupId;
            final title = group.groupName ?? "";
            return Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: WListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                borderRadius: ConfigConstant.circlarRadius2,
                iconData:
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                titleText: title,
                trailing: Container(
                  width: 48,
                  child: WIconButton(
                    onPressed: () {
                      showSnackBar(
                        context: context,
                        title: tr('msg.exit.warning'),
                        actionLabel: tr('button.yes'),
                        warning: true,
                        onActionPressed: () async {
                          await groupListingNotifier.exitGroup(group.groupId);
                          await WDatabase.instance.clearAllSync(
                            where: "group_id = '${group.groupId}'",
                          );
                          await groupListingNotifier.load();
                        },
                      );
                    },
                    iconData: Icons.close,
                    iconColor: Theme.of(context).colorScheme.error,
                  ),
                ),
                onTap: () async {
                  if (selected) {
                    await groupListingNotifier.selectedAGroup(null);
                  } else {
                    await groupListingNotifier.selectedAGroup(group.groupId);
                  }
                  await membersInfoNotifier.load();
                },
              ),
            );
          },
        ),
      );
    }
  }
}
