class GroupStorageModel {
  final String? groupName;
  final String? groupId;
  final String? admin;

  GroupStorageModel({
    this.groupName,
    this.groupId,
    this.admin,
  });

  factory GroupStorageModel.fromJson(Map<String, dynamic> json) {
    return GroupStorageModel(
      groupName: json['group_name'],
      groupId: json['group_id'],
      admin: json.containsKey('admin') ? json['admin'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "group_name": this.groupName,
      "group_id": this.groupId,
      "admin": this.admin,
    };
  }
}
