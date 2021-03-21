import 'package:cloud_firestore/cloud_firestore.dart';

class DbBackupModel {
  final String db;
  final Timestamp createOn;

  DbBackupModel({
    required this.db,
    required this.createOn,
  });

  factory DbBackupModel.fromJson(Map<String, dynamic> json) {
    return DbBackupModel(
      db: json['db'],
      createOn: json['create_on'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "db": this.db,
      "create_on": this.createOn,
    };
  }
}
