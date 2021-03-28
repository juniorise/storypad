import 'dart:async';
import 'package:flutter/material.dart';
import 'package:write_story/constants/config_constant.dart';

mixin ScheduleMixin {
  Timer? _timer;

  scheduleAction(VoidCallback callback) {
    if (this._timer != null && this._timer!.isActive) {
      this._timer!.cancel();
    }
    _timer = Timer(ConfigConstant.duration, () async {
      callback();
    });
  }
}
