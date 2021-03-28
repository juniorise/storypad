import 'package:flutter/material.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/screens/story_detail_screen.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';

class AddToStoryFAB extends StatelessWidget {
  const AddToStoryFAB({
    Key? key,
    required this.forDate,
    required this.onSaved,
  }) : super(key: key);

  final DateTime forDate;
  final ValueChanged<DateTime>? onSaved;

  Future<void> onPressed(BuildContext context) async {
    final dynamic selected =
        await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return StoryDetailScreen(
            story: StoryModel.empty.copyWith(forDate: forDate),
            insert: true,
          );
        },
      ),
    );
    if (selected != null && selected is DateTime) {
      if (this.onSaved != null) onSaved!(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kToolbarHeight,
      height: kToolbarHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: VTOnTapEffect(
        vibrate: true,
        onTap: () async => await onPressed(context),
        effects: [
          VTOnTapEffectItem(
            effectType: VTOnTapEffectType.scaleDown,
            active: 0.9,
          ),
          VTOnTapEffectItem(
            effectType: VTOnTapEffectType.touchableOpacity,
            active: 0.9,
          )
        ],
        child: FloatingActionButton(
          onPressed: () async => await onPressed(context),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          elevation: 0.0,
          highlightElevation: 0.0,
          focusElevation: 0.0,
          hoverElevation: 0.0,
          disabledElevation: 0.0,
        ),
      ),
    );
  }
}
