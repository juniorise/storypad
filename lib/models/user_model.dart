class UserModel {
  final String nickname;
  final DateTime dob;
  final DateTime createOn;
  final DateTime updateOn;

  UserModel({
    this.nickname,
    this.dob,
    this.createOn,
    this.updateOn,
  });

  copyWith({
    String nickname,
    DateTime dob,
    DateTime createOn,
    DateTime updateOn,
  }) {
    return UserModel(
      nickname: nickname ?? this.nickname,
      dob: dob ?? this.nickname,
      createOn: createOn ?? this.createOn,
      updateOn: updateOn ?? this.updateOn,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final DateTime dob = json.containsKey('dob') && json['dob'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json["dob"])
        : null;

    final DateTime createOn = DateTime.fromMillisecondsSinceEpoch(
      json["create_on"],
    );

    final DateTime updateOn =
        json.containsKey('update_on') && json['update_on'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                json["update_on"],
              )
            : null;

    return UserModel(
      nickname: json['nickname'],
      dob: dob,
      createOn: createOn,
      updateOn: updateOn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nickname": this.nickname,
      "dob": this.dob != null ? this.dob.millisecondsSinceEpoch : null,
      "create_on": createOn.millisecondsSinceEpoch,
      "update_on": updateOn != null ? updateOn.millisecondsSinceEpoch : null,
    };
  }
}
