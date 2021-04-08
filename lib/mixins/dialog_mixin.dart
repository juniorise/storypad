import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:write_story/constants/config_constant.dart';

mixin DialogMixin {
  Future<dynamic> showWDialog({
    required BuildContext context,
    required Widget child,
  }) async {
    if (Platform.isIOS) {
      return await showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return ClipRRect(
            borderRadius: ConfigConstant.circlarRadius2,
            child: child,
          );
        },
      );
    } else {
      return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return ClipRRect(
            borderRadius: ConfigConstant.circlarRadius2,
            child: child,
          );
        },
      );
    }
  }
}
