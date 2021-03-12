import 'package:flutter/material.dart';
import 'dart:convert';

class StoryModel {
  final int id;
  final String title;
  final String paragraph;
  final DateTime createOn;
  final DateTime updateOn;
  final bool isFavorite;

  const StoryModel({
    @required this.id,
    @required this.title,
    @required this.paragraph,
    @required this.createOn,
    this.updateOn,
    this.isFavorite = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final DateTime createOn = DateTime.fromMillisecondsSinceEpoch(
      json["create_on"],
    );

    final DateTime updateOn = json.containsKey('update_on')
        ? DateTime.fromMillisecondsSinceEpoch(
            json["update_on"],
          )
        : null;

    bool isFavorite = false;
    if (json.containsKey("is_favorite")) {
      isFavorite = json["is_favorite"] == 0 ? false : true;
    }

    return StoryModel(
      id: json["id"],
      title: json["title"],
      paragraph: json["paragraph"],
      updateOn: updateOn,
      createOn: createOn,
      isFavorite: isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "paragraph": paragraph,
      "is_favorite": isFavorite,
      "create_on": createOn.millisecondsSinceEpoch,
      "update_on": updateOn != null ? updateOn.millisecondsSinceEpoch : null,
    };
  }
}

List<StoryModel> storyModelFromJson(String str) {
  return List<StoryModel>.from(
    json.decode(str).map((x) => StoryModel.fromJson(x)),
  );
}

String storyModelToJson(List<StoryModel> data) {
  return json.encode(
    List<dynamic>.from(
      data.map(
        (x) => x.toJson(),
      ),
    ),
  );
}
