abstract class BaseModel {
  int id;
  BaseModel({required this.id});
  Map<String, dynamic> toJson();
}
