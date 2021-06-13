import 'package:cloud_firestore/cloud_firestore.dart';

class DbBackupModel {
  final String? db;
  final Timestamp? createOn;
  final String? name;

  DbBackupModel({
    required this.db,
    this.createOn,
    this.name,
  });

  factory DbBackupModel.fromJson(Map<String, dynamic> json) {
    return DbBackupModel(
      db: json['db'],
      createOn: json['create_on'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "db": this.db,
      "create_on": this.createOn,
      "name": this.name,
    };
  }
}
