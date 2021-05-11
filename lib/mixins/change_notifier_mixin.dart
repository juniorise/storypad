import 'package:flutter/material.dart';

mixin ChangeNotifierMixin on ChangeNotifier {
  /// example if loading or request occur in notifier,
  /// then we pop to screen, this notifier
  /// will auto dispose but loading still load.
  ///
  /// after loading, if we want to call notifyListeners
  /// to update the state, it will generate errors
  /// since it is already disposed
  ///
  /// we use disposed variable to check whether
  /// it is disposed or not
  ///
  /// orignal word is: `mounted`
  bool _disposed = false;
  bool get disposed => _disposed;

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }

  @override
  void notifyListeners() {
    if (disposed) return;
    super.notifyListeners();
  }
}
