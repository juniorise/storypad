import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';

class ToolbarNotifier extends ChangeNotifier with ChangeNotifierMixin {
  final FocusNode focusNode;
  ToolbarNotifier(this.focusNode) {
    focusNode.addListener(() {});
  }
}

final toolbarProvider = ChangeNotifierProvider.family
    .autoDispose<ToolbarNotifier, FocusNode>((ref, focusNode) {
  return ToolbarNotifier(focusNode);
});
