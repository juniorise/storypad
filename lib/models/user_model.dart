import 'package:storypad/helpers/app_helper.dart';
import 'package:storypad/models/base_model.dart';

class UserModel extends BaseModel {
  final String nickname;
  final DateTime? dob;
  final DateTime createOn;
  final DateTime? updateOn;

  String get deviceId => "os";

  UserModel({
    required this.nickname,
    required this.createOn,
    this.dob,
    this.updateOn,
  }) : super(id: 1);

  copyWith({
    String? nickname,
    DateTime? dob,
    DateTime? createOn,
    DateTime? updateOn,
  }) {
    return UserModel(
      nickname: nickname ?? this.nickname,
      dob: dob ?? this.dob,
      createOn: createOn ?? this.createOn,
      updateOn: updateOn ?? this.updateOn,
    );
  }

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    final DateTime? dob = AppHelper.dateTimeFromIntMap(json: json, key: 'dob');
    final DateTime? createOn = AppHelper.dateTimeFromIntMap(json: json, key: 'create_on');
    final DateTime? updateOn = AppHelper.dateTimeFromIntMap(json: json, key: 'update_on');

    return UserModel(
      nickname: json['nickname'],
      dob: dob,
      updateOn: updateOn,
      createOn: createOn ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nickname": this.nickname,
      "dob": this.dob?.millisecondsSinceEpoch,
      "create_on": AppHelper.intFromDateTime(dateTime: createOn),
      "update_on": AppHelper.intFromDateTime(dateTime: updateOn),
      "device_id": deviceId,
    };
  }
}
