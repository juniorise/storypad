import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';

class WMoreFaqButton extends StatelessWidget {
  const WMoreFaqButton({
    Key? key,
    required this.onAddStoryPressed,
    required this.onSettingPressed,
    required this.onGroupPressed,
    required this.faqNotifier,
  }) : super(key: key);

  final void Function() onSettingPressed;
  final void Function() onGroupPressed;
  final void Function() onAddStoryPressed;
  final ValueNotifier<bool> faqNotifier;

  @override
  Widget build(BuildContext context) {
    final buttonBackgroundColor = Theme.of(context).colorScheme.primary;
    final buttonForegroundColor = Theme.of(context).colorScheme.background;
    final labelBackgroundColor = Theme.of(context).colorScheme.surface;

    final labelStyle = Theme.of(context)
        .textTheme
        .bodyText1
        ?.copyWith(color: Theme.of(context).colorScheme.onSurface);

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
            icon: Icons.create,
            activeIcon: Icons.clear,
            buttonSize: kToolbarHeight,
            activeBackgroundColor: labelBackgroundColor,
            activeForegroundColor: buttonBackgroundColor,
            closeManually: true,
            renderOverlay: false,
            animationSpeed: 150,
            useRotationAnimation: false,
            curve: Curves.bounceIn,
            overlayOpacity: 0.0,
            openCloseDial: faqNotifier,
            // tooltip: 'Speed Dial',
            // heroTag: 'speed-dial-hero-tag',
            backgroundColor: buttonBackgroundColor,
            foregroundColor: buttonForegroundColor,
            elevation: faqNotifier.value ? 6.0 : 0,
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
                labelBackgroundColor: Theme.of(context).colorScheme.surface,
                backgroundColor: buttonBackgroundColor,
                foregroundColor: buttonForegroundColor,
                label: tr("title.setting"),
                elevation: 0.0,
                labelStyle: labelStyle,
                onTap: () {
                  onSettingPressed();
                },
                onLongPress: () {
                  onTapVibrate();
                  onSettingPressed();
                },
              ),
              SpeedDialChild(
                child: Icon(Icons.group),
                labelBackgroundColor: Theme.of(context).colorScheme.surface,
                backgroundColor: buttonBackgroundColor,
                foregroundColor: buttonForegroundColor,
                label: tr("title.group"),
                elevation: 0.0,
                labelStyle: labelStyle,
                onTap: () {
                  onGroupPressed();
                },
                onLongPress: () {
                  onTapVibrate();
                  onGroupPressed();
                },
              ),
              SpeedDialChild(
                child: Icon(Icons.add),
                labelBackgroundColor: Theme.of(context).colorScheme.surface,
                backgroundColor: buttonBackgroundColor,
                foregroundColor: buttonForegroundColor,
                elevation: 0.0,
                label: tr("button.add_story"),
                labelStyle: labelStyle,
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
