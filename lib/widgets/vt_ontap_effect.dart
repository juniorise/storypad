import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vibration/vibration.dart';
import 'package:storypad/storages/vibrate_toggle_storage.dart';

Future<void> onTapVibrate() async {
  final bool value = await VibrateToggleStorage().getBool() == true;
  if (value) await Vibration.vibrate(repeat: 0, duration: 50);
}

enum VTOnTapEffectType {
  touchableOpacity,
  scaleDown,
}

class VTOnTapEffectItem {
  final VTOnTapEffectType effectType;
  final double active;

  const VTOnTapEffectItem({
    required this.effectType,
    required this.active,
  }) : assert(active <= 1 && active >= 0);
}

class VTOnTapEffect extends HookWidget {
  VTOnTapEffect({
    Key? key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 150),
    this.vibrate = false,
    this.effects = const [
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.touchableOpacity,
        active: 0.5,
      ),
    ],
  }) : super(key: key);

  final Widget child;
  final List<VTOnTapEffectItem> effects;
  final VoidCallback? onTap;
  final Duration duration;
  final bool vibrate;

  static double _scaleActive = 0.98;
  static double _opacityActive = 0.5;

  setActiveValue() {
    effects.forEach(
      (e) {
        switch (e.effectType) {
          case VTOnTapEffectType.scaleDown:
            _scaleActive = e.active;
            break;
          case VTOnTapEffectType.touchableOpacity:
            _opacityActive = e.active;
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: duration);
    setActiveValue();

    return GestureDetector(
      onTapDown: onTap != null ? (_) => controller.forward() : null,
      onTapUp: onTap != null
          ? (_) {
              controller.reverse();
              onTap!();
            }
          : null,
      onTapCancel: onTap != null ? () => controller.reverse() : null,
      onLongPress: onTap != null && vibrate
          ? () async {
              if (await Vibration.hasVibrator() == true) {
                onTapVibrate().then((value) {
                  controller.reverse();
                  if (onTap != null) onTap!();
                });
              } else {
                controller.reverse();
                if (onTap != null) onTap!();
              }
            }
          : null,
      child: AnimatedBuilder(
        child: child,
        animation: controller,
        builder: (context, child) {
          Widget result = child ?? const SizedBox();
          for (var effect in effects) {
            final tmp = result;
            if (effect.effectType == VTOnTapEffectType.scaleDown) {
              result = Transform.scale(
                scale: lerpDouble(1, _scaleActive, controller.value) ?? 0,
                child: tmp,
              );
            }
            if (effect.effectType == VTOnTapEffectType.touchableOpacity) {
              result = AnimatedOpacity(
                duration: this.duration,
                opacity: lerpDouble(1, _opacityActive, controller.value) ?? 0,
                child: tmp,
              );
            }
          }
          return result;
        },
      ),
    );
  }
}
