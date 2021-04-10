import 'package:write_story/widgets/w_color_picker.dart';

List<String> feelingEmojiPath = [
  "beaming-face-with-smiling-eyes.png",
  "confounded-face.png",
  "confused-face.png",
  "crying-face.png",
  "disappointed-face.png",
  "dizzy-face.png",
  "downcast-face-with-sweat.png",
  "drooling-face.png",
  "expressionless-face.png",
  "face-blowing-a-kiss.png",
  "face-savoring-food.png",
  "face-vomiting.png",
  "face-with-head-bandage.png",
  "face-with-medical-mask.png",
  "face-with-monocle.png",
  "face-with-open-mouth.png",
  "face-with-raised-eyebrow.png",
  "face-with-rolling-eyes.png",
  "face-with-symbols-on-mouth.png",
  "face-with-tears-of-joy.png",
  "face-with-tongue.png",
  "face-without-mouth.png",
  "fearful-face.png",
  "flushed-face.png",
  "grimacing-face.png",
  "grinning-face-with-smiling-eyes.png",
  "grinning-face-with-sweat.png",
  "grinning-face.png",
  "grinning-squinting-face.png",
  "loudly-crying-face.png",
  "money-mouth-face.png",
  "nauseated-face.png",
  "nerd-face.png",
  "neutral-face.png",
  "pouting-face.png",
  "sleeping-face.png",
  "slightly-smiling-face.png",
  "smiling-face-with-halo.png",
  "smiling-face-with-heart-eyes.png",
  "smiling-face-with-hearts.png",
  "smiling-face-with-horns.png",
  "smiling-face-with-smiling-eyes.png",
  "smiling-face-with-sunglasses.png",
  "smirking-face.png",
  "squinting-face-with-tongue.png",
  "star-struck.png",
  "tired-face.png",
  "winking-face-with-tongue.png",
  "winking-face.png",
  "zany-face.png",
  "",
];

List<String> feelingEmojiTypeStrings = [
  "beaming",
  "worry", //confounded
  "confused",
  "crying",
  "disappointed",
  "dizzy",
  "downcast",
  "drooling",
  "expressionless", //expressionless
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
  "tears_of_joy",
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
  "something_is_cool", //smiling_sunglasses
  "suggestive_smile", //smirking_face
  "annoy_someone", //squinting_tongue
  "excited", //star_struck
  "tired",
  "crazy", //winking tongue
  "winking",
  "zany",
  "reset",
];

class FeelingEmojiModel {
  final String? type;

  FeelingEmojiModel({
    this.type,
  });

  String? get localPath {
    if (this.type == null) return null;
    for (int i = 0; i < feelingEmojiTypeStrings.length; i++) {
      final e = feelingEmojiTypeStrings[i];
      if (e == this.type) {
        return "assets/emojis/emoji-all/" + feelingEmojiPath[i];
      }
    }
  }

  static Map<int, List<int>> getIndexMap(int rowLength) {
    final result = listToTreeMap(feelingEmojiTypeStrings, rowLength: rowLength);
    return result;
  }
}
