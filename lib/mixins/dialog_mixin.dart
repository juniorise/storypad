import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

mixin DialogMixin {
  showWDialog({required BuildContext context, required Widget child}) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return child;
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return child;
        },
      );
    }
  }
}
