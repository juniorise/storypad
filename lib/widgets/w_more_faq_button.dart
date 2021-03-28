import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';

class WMoreFaqButton extends StatelessWidget {
  const WMoreFaqButton({
    Key? key,
    required this.onAddStoryPressed,
    required this.onSettingPressed,
    required this.faqNotifier,
  }) : super(key: key);

  final void Function() onSettingPressed;
  final void Function() onAddStoryPressed;
  final ValueNotifier<bool> faqNotifier;

  @override
  Widget build(BuildContext context) {
    return VTOnTapEffect(
      onTap: () {},
      effects: [
        VTOnTapEffectItem(
          effectType: VTOnTapEffectType.touchableOpacity,
          active: 0.5,
        ),
      ],
      child: ValueListenableBuilder(
        valueListenable: faqNotifier,
        builder: (context, value, reader) {
          return SpeedDial(
            icon: Icons.more_horiz,
            activeIcon: Icons.more_horiz,
            buttonSize: kToolbarHeight,
            closeManually: true,
            renderOverlay: false,
            curve: Curves.bounceIn,
            overlayOpacity: 0.0,
            openCloseDial: faqNotifier,
            // tooltip: 'Speed Dial',
            // heroTag: 'speed-dial-hero-tag',
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).backgroundColor,
            elevation: 0.0,
            shape: CircleBorder(),
            onClose: () {
              onTapVibrate();
              faqNotifier.value = false;
            },
            onOpen: () {
              onTapVibrate();
              faqNotifier.value = true;
            },
            children: [
              SpeedDialChild(
                child: Icon(Icons.settings),
                backgroundColor: Theme.of(context).primaryColorDark,
                foregroundColor: Theme.of(context).backgroundColor,
                label: tr("title.setting"),
                elevation: 0.0,
                labelStyle: Theme.of(context).textTheme.bodyText1,
                onTap: () {
                  onSettingPressed();
                },
                onLongPress: () {
                  onTapVibrate();
                  onSettingPressed();
                },
              ),
              SpeedDialChild(
                child: Icon(Icons.add),
                backgroundColor: Theme.of(context).primaryColorDark,
                foregroundColor: Theme.of(context).backgroundColor,
                elevation: 0.0,
                label: tr("button.add_story"),
                labelStyle: Theme.of(context).textTheme.bodyText1,
                onTap: () {
                  onAddStoryPressed();
                },
                onLongPress: () {
                  onTapVibrate();
                  onAddStoryPressed();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
