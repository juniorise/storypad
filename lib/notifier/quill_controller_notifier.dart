import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuillControllerNotifer with ChangeNotifier {
  final QuillController controller;
  String _draftParagraph = "";

  QuillControllerNotifer(this.controller) {
    /// init data
    final quil = controller.document.toDelta().toJson();
    var json = jsonEncode(quil);
    _draftParagraph = "$json";
    notifyListeners();

    /// set draft data on change
    this.controller.addListener(() {
      final quil = controller.document.toDelta().toJson();
      var json = jsonEncode(quil);
      _draftParagraph = "$json";
      notifyListeners();
    });
  }

  String get draftParagraph => this._draftParagraph;
}

final quillControllerProvider =
    ChangeNotifierProvider.family<QuillControllerNotifer, QuillController>(
  (ref, controller) {
    return QuillControllerNotifer(controller);
  },
);
