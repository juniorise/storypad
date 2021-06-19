import 'package:storypad/helpers/app_helper.dart';
import 'package:storypad/models/base_model.dart';

class StoryModel extends BaseModel {
  final String title;
  final String? paragraph;
  final DateTime createOn;
  final DateTime? updateOn;
  final DateTime forDate;
  final bool isFavorite;
  final String? feeling;

  StoryModel({
    required this.title,
    required this.paragraph,
    required this.createOn,
    required this.forDate,
    this.feeling,
    this.updateOn,
    this.isFavorite = false,
    required int id,
  }) : super(id: id);

  static StoryModel get empty {
    return StoryModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: "",
      paragraph: "",
      createOn: DateTime.now(),
      forDate: DateTime.now(),
      feeling: null,
    );
  }

  StoryModel copyWith({
    int? id,
    String? title,
    String? paragraph,
    DateTime? createOn,
    DateTime? updateOn,
    DateTime? forDate,
    bool? isFavorite,
    String? feeling,
  }) {
    return StoryModel(
      id: id ?? this.id,
      title: title != null ? title : this.title,
      paragraph: paragraph != null ? paragraph : this.paragraph,
      createOn: createOn ?? this.createOn,
      forDate: forDate ?? this.forDate,
      updateOn: updateOn ?? this.updateOn,
      isFavorite: isFavorite ?? this.isFavorite,
      feeling: feeling ?? this.feeling,
    );
  }

  factory StoryModel.fromJson(Map<dynamic, dynamic> json) {
    final DateTime? createOn = AppHelper.dateTimeFromIntMap(key: 'create_on', json: json);
    final DateTime? forDate = AppHelper.dateTimeFromIntMap(key: 'for_date', json: json);
    final DateTime? updateOn = AppHelper.dateTimeFromIntMap(key: 'update_on', json: json);
    final bool isFavorite = AppHelper.boolFromIntMap(key: 'is_favorite', json: json);

    return StoryModel(
      id: json["id"],
      title: json["title"],
      feeling: json["feeling"],
      paragraph: json["paragraph"],
      isFavorite: isFavorite,
      updateOn: updateOn,
      createOn: createOn ?? DateTime.now(),
      forDate: forDate ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "feeling": feeling,
      "paragraph": paragraph,
      "is_favorite": isFavorite ? 1 : 0,
      "create_on": AppHelper.intFromDateTime(dateTime: createOn),
      "for_date": AppHelper.intFromDateTime(dateTime: forDate),
      "update_on": AppHelper.intFromDateTime(dateTime: updateOn),
    };
  }
}
