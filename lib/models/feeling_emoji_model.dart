import 'package:write_story/widgets/w_color_picker.dart';

class FeelingEmojiModel {
  final String? type;
  final String? path;

  FeelingEmojiModel({
    this.type,
    this.path,
  });

  String? get localPath {
    if (this.type == null) return null;

    Map<String, FeelingEmojiModel> map = feelingEmojiListMap;
    final _path = map[this.type]?.path;
    if (_path == null) return null;

    return "assets/emoji-64/" + _path;
  }

  static Map<int, List<int>> getIndexMap(int rowLength) {
    final result = listToTreeMap(feelingEmojiList, rowLength: rowLength);
    return result;
  }
}

List<FeelingEmojiModel> get feelingEmojiList {
  return List.generate(
    _feelingEmojiTypeList.length,
    (index) {
      final e = _feelingEmojiTypeList[index];
      return FeelingEmojiModel(
        type: e,
        path: originImage64[index],
      );
    },
  );
}

Map<String, FeelingEmojiModel> get feelingEmojiListMap {
  final Map<String, FeelingEmojiModel> map = {};
  feelingEmojiList.forEach((e) {
    map[e.type ?? ""] = e;
  });
  return map;
}

List<String> originImage64 = [
  "beaming-face-with-smiling-eyes-64x64-1395554.png",
  "confounded-face-64x64-1395561.png",
  "confused-face-64x64-1395584.png",
  "crying-face-64x64-1395579.png",
  "disappointed-face-64x64-1395587.png",
  "dizzy-face-64x64-1395573.png",
  "downcast-face-with-sweat-64x64-1395586.png",
  "drooling-face-64x64-1395566.png",
  "expressionless-face-64x64-1395580.png",
  "face-blowing-a-kiss-64x64-1395556.png",
  "face-savoring-food-64x64-1395567.png",
  "face-vomiting-64x64-1395569.png",
  "face-with-head-bandage-64x64-1395563.png",
  "face-with-medical-mask-64x64-1395570.png",
  "face-with-monocle-64x64-1395562.png",
  "face-with-open-mouth-64x64-1395578.png",
  "face-with-raised-eyebrow-64x64-1395571.png",
  "face-with-rolling-eyes-64x64-1395546.png",
  "face-with-symbols-on-mouth-64x64-1395550.png",
  "face-with-tears-of-joy-64x64-1395560.png",
  "face-with-tongue-64x64-1395588.png",
  "face-without-mouth-64x64-1395577.png",
  "fearful-face-64x64-1395553.png",
  "flushed-face-64x64-1395564.png",
  "grimacing-face-64x64-1395576.png",
  "grinning-face-64x64-1395591.png",
  "grinning-face-with-smiling-eyes-64x64-1395548.png",
  "grinning-face-with-sweat-64x64-1395555.png",
  "grinning-squinting-face-64x64-1395574.png",
  "loudly-crying-face-64x64-1395592.png",
  "money-mouth-face-64x64-1395557.png",
  "nauseated-face-64x64-1395559.png",
  "nerd-face-64x64-1395568.png",
  "neutral-face-64x64-1395585.png",
  "pouting-face-64x64-1395575.png",
  "sleeping-face-64x64-1395590.png",
  "slightly-smiling-face-64x64-1395552.png",
  "smiling-face-with-halo-64x64-1395582.png",
  "smiling-face-with-heart-eyes-64x64-1395589.png",
  "smiling-face-with-hearts-64x64-1395545.png",
  "smiling-face-with-horns-64x64-1395558.png",
  "smiling-face-with-smiling-eyes-64x64-1395594.png",
  "smiling-face-with-sunglasses-64x64-1395549.png",
  "smirking-face-64x64-1395593.png",
  "squinting-face-with-tongue-64x64-1395581.png",
  "star-struck-64x64-1395565.png",
  "tired-face-64x64-1395547.png",
  "winking-face-64x64-1395551.png",
  "winking-face-with-tongue-64x64-1395583.png",
  "zany-face-64x64-1395572.png"
];

List<String> _feelingEmojiTypeList = [
  "beaming",
  "worry",
  "confused",
  "crying",
  "disappointed",
  "dizzy",
  "downcast",
  "drooling",
  "expressionless",
  "blowing", //blowing_a_kiss
  "savoring_food", //savoring_food
  "vomiting",
  "head_bandage",
  "medical_mask",
  "monocle",
  "wow", //open_mouth
  "mistrust", //raised_eyebrow
  "rolling_eyes",
  "serious", //symbols_on_mouth
  "really_funny",
  "cuteness", //tongue
  "loss_for_words", //no_mouth
  "fearful",
  "flushed",
  "nervousness", //grimacing
  "cheerfulness", //grinning_smiling_eyes
  "grinning_sweat",
  "smiling_broadly", //grinning
  "laughter", //grinning_squinting
  "loudly_crying",
  "getting_rich", //money_mouth_face
  "nauseated",
  "nerd",
  "neutral",
  "pouting",
  "sleeping",
  "slightly_smiling",
  "smiling_halo",
  "in_love", //smiling_heart_eyes
  "lovely", //smiling_hearts
  "devil", //smiling_horns
  "positive_feelings", //smiling_smiling_eyes
  "something_cool", //smiling_sunglasses
  "suggestive_smile", //smirking_face
  "annoy_someone", //squinting_tongue
  "excited", //star_struck
  "tired",
  "crazy", //winking tongue
  "winking",
  "zany",
];
