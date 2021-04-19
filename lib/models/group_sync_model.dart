class GroupSyncModel {
  final int storyId;
  final String groupId;
  final String groupName;

  GroupSyncModel({
    required this.storyId,
    required this.groupId,
    required this.groupName,
  });

  factory GroupSyncModel.fromJson(Map<String, dynamic> json) {
    return GroupSyncModel(
      groupId: json['group_id'],
      storyId: json['story_id'],
      groupName: json['group_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "group_id": groupId,
      "story_id": storyId,
      "group_name": groupName,
    };
  }
}
