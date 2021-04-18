import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:write_story/constants/config_constant.dart';

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
            child: const Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('OPEN'),
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
