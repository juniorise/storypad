import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:write_your_story/screens/story_detail_screen.dart';
import 'package:write_your_story/widgets/vt_ontap_effect.dart';

class AddToStoryFAB extends StatelessWidget {
  const AddToStoryFAB({
    Key key,
    @required this.forDate,
  }) : super(key: key);

  final DateTime forDate;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 500),
      openElevation: 0.0,
      closedElevation: 0.5,
      closedColor: Theme.of(context).backgroundColor,
      openColor: Theme.of(context).backgroundColor,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kToolbarHeight),
      ),
      openShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      openBuilder: (context, callback) {
        return StoryDetailScreen(
          callback: callback,
          futureId: forDate.millisecondsSinceEpoch,
        );
      },
      closedBuilder: (context, callback) {
        return VTOnTapEffect(
          onTap: callback,
          effects: [
            VTOnTapEffectItem(effectType: VTOnTapEffectType.scaleDown),
            VTOnTapEffectItem(
              effectType: VTOnTapEffectType.touchableOpacity,
              active: 0.1,
            )
          ],
          child: FloatingActionButton(
            onPressed: callback,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
            elevation: 0.0,
            highlightElevation: 0.0,
            focusElevation: 0.0,
            hoverElevation: 0.0,
            disabledElevation: 0.0,
          ),
        );
      },
    );
  }
}
