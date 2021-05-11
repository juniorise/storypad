import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storypad/constants/config_constant.dart';

mixin DialogMixin {
  Future<String> showTextDialog(
    BuildContext context, {
    String? labelText,
    String? hintText,
  }) async {
    String text = "";
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                autofocus: true,
                onChanged: (String value) {
                  text = value;
                },
                decoration: InputDecoration(
                  labelText: labelText,
                  hintText: hintText,
                ),
              ),
            )
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(tr('button.cancel')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(tr('button.save')),
            onPressed: () {
              Navigator.of(context).pop(text);
            },
          )
        ],
      ),
    );
  }

  Future<dynamic> showWDialog({
    required BuildContext context,
    required Widget child,
  }) async {
    if (Platform.isIOS || Platform.isAndroid) {
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
