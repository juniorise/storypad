import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String? email;
  final String? photoUrl;
  final Timestamp? joinOn;
  final bool? isAdmin;
  final String? db;
  final Timestamp? inviteOn;

  MemberModel({
    this.email,
    this.photoUrl,
    this.joinOn,
    this.isAdmin,
    this.db,
    this.inviteOn,
  });

  MemberModel copyWith({
    String? email,
    String? photoUrl,
    Timestamp? joinOn,
    bool? isAdmin,
    String? db,
    Timestamp? inviteOn,
  }) {
    return MemberModel(
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      joinOn: joinOn ?? this.joinOn,
      isAdmin: isAdmin ?? this.isAdmin,
      db: db ?? this.db,
      inviteOn: inviteOn ?? this.inviteOn,
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
    };
  }
}
