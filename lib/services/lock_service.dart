import 'package:storypad/storages/is_unlocked_storage.dart';
import 'package:storypad/storages/lock_screen_storage.dart';

class LockService {
  LockService._internal();
  static final LockService instance = LockService._internal();

  LockScreenStorage storage = LockScreenStorage();
  IsUnlockStorage isUnlockStorage = IsUnlockStorage();

  Map<String, String>? storageLockNumberMap;

  bool? _enable;
  Future<bool> get enable async {
    if (_enable != null) return _enable == true;
    await load();
    return _enable == true;
  }

  Future<void> load() async {
    final Map<String, String>? result = await storage.readMap();
    if (result != null) {
      this.storageLockNumberMap = result;
      _enable = true;
    } else {
      this.storageLockNumberMap = null;
      _enable = false;
    }
    isUnlockStorage.setBool(value: _enable != true);
  }

  Future<void> setLock(Map<String, dynamic> map) async {
    await storage.writeMap(map);
    load();
  }

  Future<void> clearLock() async {
    await storage.remove();
    load();
  }
}
