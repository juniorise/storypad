import 'package:flutter/material.dart';

class StoryModel {
  final String id;
  final String title;
  final String parentId;
  final String paragraph;
  final DateTime createOn;
  final DateTime updateOn;
  final bool isFavorite;

  const StoryModel({
    @required this.id,
    @required this.title,
    @required this.paragraph,
    @required this.createOn,
    this.parentId,
    this.updateOn,
    this.isFavorite = false,
  });
}
