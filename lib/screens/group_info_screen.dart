import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/app_helper/app_helper.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/mixins/dialog_mixin.dart';
import 'package:write_story/mixins/snakbar_mixin.dart';
import 'package:write_story/models/member_model.dart';
import 'package:write_story/notifier/group_listing_notifier.dart';
import 'package:write_story/notifier/member_info_notifier.dart';
import 'package:write_story/screens/setting_screen.dart';
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.surface,
        textTheme: Theme.of(context).textTheme,
        title: Text(
          "Group info",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
            Tab(text: "Members"),
            Tab(text: "Groups"),
          ],
        ),
        actions: [
          AnimatedBuilder(
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
                        labelText: "Group name",
                        hintText: "eg. Couple",
                      );
                      if (groupName == null) return;
                      await groupListingNotifier.createGroup("$groupName");
                      await membersInfoNotifier.load();
                    } else {
                      if (membersInfoNotifier.group == null) return;
                      final String? email = await showTextDialog(
                        context,
                        labelText: "Email",
                        hintText: "eg. sok@example.com",
                      );

                      if (email == null) return;
                      if (!AppHelper.isEmail(email)) {
                        Future.delayed(ConfigConstant.fadeDuration).then(
                          (value) {
                            showSnackBar(
                              context: context,
                              title: "Email is invalid",
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
    );
  }

  Consumer buildMemberListing({
    required MembersInfoNotifier membersInfoNotifier,
    required GroupListingScreenNotifer groupListingNotifier,
    required BuildContext context,
  }) {
    return Consumer(
      builder: (context, watch, child) {
        return membersInfoNotifier.group == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WNoData(
                      customText: membersInfoNotifier.auth.user == null
                          ? "Log in with a google account to access this feature"
                          : "Create or select a group to view all members.",
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
                        child: Text("Open Setting"),
                      ),
                  ],
                ),
              )
            : StreamBuilder<List<MemberModel>>(
                stream: membersInfoNotifier.fetchMembers(),
                builder: (context, snapshot) {
                  List<MemberModel> members = [];
                  if (snapshot.hasData) {
                    members = snapshot.data ?? [];
                  }
                  return ListView(
                    padding: ConfigConstant.layoutPadding,
                    children: List.generate(
                      members.length,
                      (index) {
                        final member = members[index];
                        final bool hasPhoto = member.photoUrl != null &&
                            member.photoUrl?.isNotEmpty == true;
                        final date = member.joinOn != null
                            ? AppHelper.dateFormat(context).format(
                                member.joinOn!.toDate(),
                              )
                            : null;
                        return Container(
                          margin: const EdgeInsets.only(top: 8.0),
                          child: Stack(
                            children: [
                              WListTile(
                                borderRadius: ConfigConstant.circlarRadius2,
                                iconData: hasPhoto ? null : Icons.person,
                                imageIcon: hasPhoto ? member.photoUrl : null,
                                titleText: member.email ?? "",
                                subtitleText:
                                    date != null ? "Joined on $date" : null,
                                onTap: () {},
                              ),
                              if (member.joinOn == null)
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
                },
              );
      },
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
    return groupListingNotifier.groups.length == 0
        ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WNoData(
                  customText: membersInfoNotifier.auth.user == null
                      ? "Log in with a google account to access this feature"
                      : "You don't have any group yet. Create one and invite your friend!",
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
                    child: Text("Open Setting"),
                  ),
              ],
            ),
          )
        : ListView(
            padding: ConfigConstant.layoutPadding,
            children: List.generate(
              groupListingNotifier.groups.length,
              (index) {
                final group = groupListingNotifier.groups[index];
                bool selected =
                    groupListingNotifier.selectedGroup == group.groupId;
                final title = group.groupName ?? "";
                return Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  child: WListTile(
                    borderRadius: ConfigConstant.circlarRadius2,
                    iconData: selected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    titleText: title,
                    trailing: null,
                    // TODO: add able to delete group
                    // Container(
                    //   width: 48,
                    //   child: WIconButton(
                    //     onPressed: () {
                    //       showSnackBar(
                    //         context: context,
                    //         title: "Are you sure to exit",
                    //         actionLabel: "Yes",
                    //         warning: true,
                    //         onActionPressed: () async {
                    //           await groupListingNotifier
                    //               .exitGroup(group.groupId);
                    //           await groupInfoNotifier.load();
                    //         },
                    //       );
                    //     },
                    //     iconData: Icons.exit_to_app,
                    //     iconColor: Theme.of(context).colorScheme.error,
                    //   ),
                    // ),
                    onTap: () async {
                      if (selected) {
                        await groupListingNotifier.selectedAGroup(null);
                      } else {
                        await groupListingNotifier
                            .selectedAGroup(group.groupId);
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
