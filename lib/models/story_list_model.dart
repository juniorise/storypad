import 'package:flutter/material.dart';

class StoryListModel {
  final int id;
  final List<int> childrenId;
  final bool isLeaf;
  final DateTime createOn;

  StoryListModel({
    @required this.id,
    @required this.childrenId,
    @required this.createOn,
    @required this.isLeaf,
  });
}
