import 'package:flutter/material.dart';

class StoryListModel {
  final int id;
  final List<int> childrenId;
  final bool isLeaf;
  final DateTime forDate;

  StoryListModel({
    @required this.id,
    @required this.childrenId,
    @required this.forDate,
    @required this.isLeaf,
  });
}
