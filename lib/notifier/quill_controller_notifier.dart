import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/helpers/quill_helper.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';

class QuillControllerNotifer extends ChangeNotifier with ChangeNotifierMixin {
  final QuillController controller;
  String _draftParagraph = "";

  QuillControllerNotifer(this.controller) {
    /// init data
    final quil = controller.document.toDelta().toJson();
    loadLocalImages();

    var json = jsonEncode(quil);
    _draftParagraph = "$json";

    /// set draft data on change
    this.controller.addListener(() {
      final quil = controller.document.toDelta().toJson();
      var json = jsonEncode(quil);
      _draftParagraph = "$json";
    });
  }

  List<String>? files;

  loadLocalImages() async {
    files = await QuillHelper.getLocalImages(this.controller.document);
    notifyListeners();
  }

  String get draftParagraph => this._draftParagraph;
}

final quillControllerProvider = ChangeNotifierProvider.family<QuillControllerNotifer, QuillController>(
  (ref, controller) {
    return QuillControllerNotifer(controller);
  },
);
