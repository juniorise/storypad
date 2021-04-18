class PendingModel {
  final String? sendToEmail;
  final String? groupId;
  final String? sendByEmail;
  final String? groupName;

  PendingModel({
    this.sendToEmail,
    this.groupId,
    this.sendByEmail,
    this.groupName,
  });

  factory PendingModel.fromJson(Map<String, dynamic> json) {
    return PendingModel(
      sendByEmail: json['send_by_email'],
      sendToEmail: json['send_to_email'],
      groupName: json['group_name'],
      groupId: json['group_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "send_by_email": this.sendByEmail,
      "send_to_email": this.sendToEmail,
      "group_name": this.groupName,
      "group_id": this.groupId,
    };
  }
}
