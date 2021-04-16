import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/storages/lock_screen_storage.dart';

class LockScreenNotifier extends ChangeNotifier {
  Map<int, int>? _storageLockNumberMap;
  Map<int, int>? _firstStepLockNumberMap;
  Map<int, int>? get firstStepLockNumberMap => this._firstStepLockNumberMap;
  setfirstStepLockNumberMap(Map<int, int> value) {
    _firstStepLockNumberMap = value;
    print("_firstStepLockNumberMap $_firstStepLockNumberMap");
    notifyListeners();
  }

  String? _errorMessage;
  Map<int, int?>? _lockNumberMap;
  double _opacity = 1;

  LockScreenStorage storage = LockScreenStorage();

  fadeOpacity() {
    _opacity = 0;
    notifyListeners();
    Future.delayed(ConfigConstant.fadeDuration).then((value) {
      _opacity = 1;
      notifyListeners();
    });
  }

  load() async {
    final Map<int, int>? result = await storage.readMap();
    if (result != null) {
      this._storageLockNumberMap = result;
      print("result $result");
    } else {
      this._storageLockNumberMap = null;
    }
    notifyListeners();
  }

  setLockNumberMap(Map<int, int?>? lockNumberMap) {
    this._lockNumberMap = lockNumberMap;
    print(this._lockNumberMap);
    notifyListeners();
  }

  bool get isMax {
    int i = 0;
    lockNumberMap.entries.forEach((e) {
      if (e.value == null) {
        i++;
      }
    });
    if (i == 0) {
      return true;
    } else {
      return false;
    }
  }

  String? get errorMessage => this._errorMessage;
  double get opacity => this._opacity;
  Map<int, int>? get storageLockNumberMap => _storageLockNumberMap;
  Map<int, int?> get lockNumberMap {
    return _lockNumberMap ?? {0: null, 1: null, 2: null, 3: null};
  }

  void setErrorMessage(String? message) {
    this._errorMessage = message;
    fadeOpacity();
  }
}

final lockScreenProvider =
    ChangeNotifierProvider.autoDispose<LockScreenNotifier>((ref) {
  return LockScreenNotifier()..load();
});
