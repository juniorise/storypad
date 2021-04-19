import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/database/w_database.dart';
import 'package:write_story/models/group_storage_model.dart';
import 'package:write_story/models/group_sync_model.dart';
import 'package:write_story/notifier/home_screen_notifier.dart';
import 'package:write_story/screens/group_screen.dart';
import 'package:write_story/storages/group_sync_storage.dart';
import 'package:write_story/widgets/w_no_data.dart';

class WGroupSyncDialogNotifier extends ChangeNotifier {
  List<GroupStorageModel>? _groups;
  List<GroupStorageModel> get groups => _groups ?? [];

  GroupsSyncStorage storage = GroupsSyncStorage();
  WDatabase database = WDatabase.instance;

  List<GroupSyncModel>? _groupSync;
  List<GroupSyncModel> get groupSync => this._groupSync ?? [];

  bool get inited => this._inited;
  bool _inited = false;

  set inited(bool value) {
    _inited = value;
    notifyListeners();
  }

  load() async {
    _groups = await storage.readList();
    if (_groups != null) {
      List<GroupSyncModel> tmpGroupSync = [];
      _groups?.forEach((e) async {
        if (e.groupId != null) {
          final result = await database.groupSyncsByGroupId(e.groupId!);
          if (result != null) tmpGroupSync.addAll(result);
        }
      });
      this._groupSync = tmpGroupSync;
    }
    notifyListeners();
    if (!this._inited) {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        inited = true;
      });
    }
  }

  bool isCheck(int storyId, String groupId) {
    final list =
        groupSync.where((e) => e.storyId == storyId && e.groupId == groupId);
    if (list.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> toggleAGroup({required GroupSyncModel group}) async {
    if (isCheck(group.storyId, group.groupId)) {
      await database.removeFromGroupSync(
        groupId: group.groupId,
        storyId: group.storyId,
      );
    } else {
      await database.insertToGroupSync(
        groupId: group.groupId,
        storyId: group.storyId,
        groupName: group.groupName,
      );
    }
    await load();
  }
}

final wGroupSyncDialogProvider =
    ChangeNotifierProvider.autoDispose<WGroupSyncDialogNotifier>(
  (_) {
    return WGroupSyncDialogNotifier()..load();
  },
);

class WGroupSyncDialog extends HookWidget {
  const WGroupSyncDialog({
    Key? key,
    required this.storyId,
  }) : super(key: key);

  final int storyId;
  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(wGroupSyncDialogProvider);
    return AnimatedOpacity(
      opacity: notifier.inited ? 1 : 0,
      duration: ConfigConstant.fadeDuration,
      child: Dialog(
        child: notifier.groups.isNotEmpty
            ? Wrap(
                children: List.generate(
                  notifier.groups.length,
                  (index) {
                    final group = notifier.groups[index];
                    GroupSyncModel? groupSyncModel = GroupSyncModel(
                      groupId: group.groupId!,
                      groupName: group.groupName!,
                      storyId: storyId,
                    );

                    return ListTile(
                      contentPadding: EdgeInsets.only(left: 16.0, right: 8.0),
                      title: Text(
                        group.groupName ?? group.admin ?? group.groupId ?? "",
                      ),
                      onTap: () async {
                        await notifier.toggleAGroup(group: groupSyncModel);
                        await context.read(homeScreenProvider).load();
                      },
                      trailing: Checkbox(
                        onChanged: (bool? value) async {
                          await notifier.toggleAGroup(group: groupSyncModel);
                          await context.read(homeScreenProvider).load();
                        },
                        value: notifier.isCheck(storyId, group.groupId ?? ""),
                      ),
                    );
                  },
                ),
              )
            : Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  Image.asset(
                    'assets/illustrations/thinking-woman.png',
                    width: 200,
                  ),
                  const SizedBox(height: 16.0, width: double.infinity),
                  WNoData(customText: tr('msg.group.no_selected_group')),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return GroupScreen();
                          },
                        ),
                      );
                    },
                    child: Text(tr('button.open_group')),
                  ),
                  const SizedBox(height: 16.0, width: double.infinity),
                ],
              ),
      ),
    );
  }
}
