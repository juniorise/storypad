import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String? email;
  final String? photoUrl;
  final Timestamp? joinOn;
  final bool? isAdmin;
  final String? db;
  final Timestamp? inviteOn;
  final String? invitedBy;
  final String? nickname;

  MemberModel({
    this.email,
    this.photoUrl,
    this.joinOn,
    this.isAdmin,
    this.db,
    this.inviteOn,
    this.invitedBy,
    this.nickname,
  });

  String? get username {
    if (this.email == null) return null;
    final username = this.email?.split("@").first.split(".").first;
    String _username = "";
    for (int i = 0; i < username!.length - 2; i++) {
      _username += username[i];
    }
    return _username;
  }

  MemberModel copyWith({
    String? email,
    String? photoUrl,
    Timestamp? joinOn,
    bool? isAdmin,
    String? db,
    Timestamp? inviteOn,
    String? invitedBy,
    String? nickname,
  }) {
    return MemberModel(
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      joinOn: joinOn ?? this.joinOn,
      isAdmin: isAdmin ?? this.isAdmin,
      db: db ?? this.db,
      inviteOn: inviteOn ?? this.inviteOn,
      invitedBy: invitedBy ?? this.invitedBy,
      nickname: nickname ?? this.nickname,
    );
  }

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      email: json['email'],
      photoUrl: json['photo_url'],
      joinOn: json['join_on'],
      isAdmin: json['is_admin'],
      db: json['db'],
      inviteOn: json['invite_on'],
      invitedBy: json['invited_by'],
      nickname: json['nickname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": this.email,
      "photo_url": this.photoUrl,
      "join_on": this.joinOn,
      "is_admin": this.isAdmin,
      "db": this.db,
      "invite_on": this.inviteOn,
      'invited_by': this.invitedBy,
      'nickname': this.nickname,
    };
  }
}
