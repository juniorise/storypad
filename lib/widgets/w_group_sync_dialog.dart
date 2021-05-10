import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/database/w_database.dart';
import 'package:storypad/models/group_storage_model.dart';
import 'package:storypad/models/group_sync_model.dart';
import 'package:storypad/notifier/home_screen_notifier.dart';
import 'package:storypad/screens/group_screen.dart';
import 'package:storypad/storages/group_sync_storage.dart';
import 'package:storypad/widgets/w_no_data.dart';

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

  bool get loading => this._loading;
  bool _loading = false;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  load() async {
    _groups = await storage.readList();
    if (_groups != null) {
      List<GroupSyncModel>? tmpGroupSync = [];
      for (int i = 0; i < (_groups?.length ?? 0); i++) {
        GroupStorageModel? e = _groups?[i];
        if (e == null) return;
        final result = await database.groupSyncsByGroupId(e.groupId!);
        if (result != null) {
          result.forEach((e) => tmpGroupSync.add(e));
        }
      }
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
    final list = groupSync.where((e) {
      return e.storyId == storyId && e.groupId == groupId;
    });
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
    return WillPopScope(
      onWillPop: () async {
        await context.read(homeScreenProvider).load();
        Navigator.of(context).pop();
        return false;
      },
      child: AnimatedOpacity(
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
                          if (notifier.loading == true) return;
                          notifier.loading = true;
                          await notifier.toggleAGroup(group: groupSyncModel);
                          notifier.loading = false;
                        },
                        trailing: Checkbox(
                          onChanged: (bool? value) async {
                            if (notifier.loading == true) return;
                            notifier.loading = true;
                            await notifier.toggleAGroup(group: groupSyncModel);
                            notifier.loading = false;
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
      ),
    );
  }
}
