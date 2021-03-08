import 'package:flutter/material.dart';

class StoryListModel {
  final String id;
  final List<String> childrenId;
  final bool isLeaf;
  final DateTime createOn;

  StoryListModel({
    @required this.id,
    @required this.childrenId,
    @required this.createOn,
    @required this.isLeaf,
  });
}
