import 'package:flutter/material.dart';

abstract class BaseNotifier extends ChangeNotifier {
  bool _loading = false;
  bool get loading => this._loading;
  set loading(bool value) {
    if (value == _loading) return;
    _loading = value;
    notifyListeners();
  }

  bool _mounted = false;
  bool get mounted => _mounted;

  @override
  void dispose() {
    super.dispose();
    _mounted = true;
  }

  @override
  void notifyListeners() {
    if (mounted) return;
    super.notifyListeners();
  }
}
