import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/app.dart';
import 'package:storypad/notifier/lock_notifier.dart';
import 'package:storypad/screens/lock/lock_screen.dart';
import 'package:storypad/services/local_storages/preferences/is_unlocked_storage.dart';
import 'package:storypad/services/views/lock_service.dart';

class LockStateNotifier extends ChangeNotifier with WidgetsBindingObserver {
  Timer? _backgroundLockLatencyTimer;
  Duration backgroundLockLatency = Duration(seconds: 5);
  bool get enable => this._enable == true;
  bool? _enable;

  LockStateNotifier() {
    WidgetsBinding.instance?.addObserver(this);
  }

  Future<void> load() async {
    _enable = await LockService.instance.enable;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    this._backgroundLockLatencyTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final storage = IsUnlockStorage();
    if (state == AppLifecycleState.paused && this.enable == true) {
      this._backgroundLockLatencyTimer = Timer(
        this.backgroundLockLatency,
        () {
          storage.getBool().then((isUnlock) {
            if (isUnlock == true) {
              storage.setBool(value: false);
              App.navigatorKey.currentState?.push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) {
                    return LockScreenWrapper(
                      LockFlowType.UNLOCK,
                      lockDetail: LockDetail(fromLaunch: false),
                    );
                  },
                ),
              );
            }
          });
        },
      );
    }
    if (state == AppLifecycleState.resumed) {
      this._backgroundLockLatencyTimer?.cancel();
    }
    super.didChangeAppLifecycleState(state);
  }
}

final lockStateNotifier = ChangeNotifierProvider<LockStateNotifier>((ref) {
  return LockStateNotifier()..load();
});
