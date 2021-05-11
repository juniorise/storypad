import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';

class CheckForUpdateNotifier extends ChangeNotifier with ChangeNotifierMixin {
  CheckForUpdateNotifier();
  bool get isUpdateAvailable =>
      this.immediateUpdateAllowed || this.flexibleUpdateAllowed;

  bool immediateUpdateAllowed = false;
  bool flexibleUpdateAllowed = false;

  load() async {
    if (Platform.isAndroid) {
      try {
        AppUpdateInfo? update = await InAppUpdate.checkForUpdate();
        immediateUpdateAllowed = update.immediateUpdateAllowed;
        flexibleUpdateAllowed = update.flexibleUpdateAllowed;
      } catch (e) {
        immediateUpdateAllowed = false;
        flexibleUpdateAllowed = false;
      }
      notifyListeners();
    }
  }
}

final checkForUpdateProvider =
    ChangeNotifierProvider<CheckForUpdateNotifier>((ref) {
  return CheckForUpdateNotifier()..load();
});
