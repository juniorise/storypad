import 'dart:async';
import 'package:flutter/material.dart';

mixin ScheduleMixin {
  Timer? _timer;

  scheduleAction(VoidCallback callback) {
    if (this._timer != null && this._timer!.isActive) {
      this._timer!.cancel();
    }
    _timer = Timer(const Duration(milliseconds: 350), () async {
      callback();
    });
  }
}
