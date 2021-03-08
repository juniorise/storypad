import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum VTOnTapEffectType {
  touchableOpacity,
  scaleDown,
}

class VTOnTapEffectItem {
  final VTOnTapEffectType effectType;
  final double active;

  const VTOnTapEffectItem({
    this.effectType = VTOnTapEffectType.scaleDown,
    this.active = 0.98,
  }) : assert(active < 1 && active > 0);
}

class VTOnTapEffect extends HookWidget {
  VTOnTapEffect({
    Key key,
    this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 250),
    this.effects = const [
      VTOnTapEffectItem(),
    ],
  }) : super(key: key);

  final Widget child;
  final List<VTOnTapEffectItem> effects;
  final VoidCallback onTap;
  final Duration duration;
  final ValueNotifier<double> valueNotifier = ValueNotifier(1);

  static double scaleActive = 0.98;
  static double opacityActive = 0.5;

  setActiveValue() {
    effects.forEach(
      (e) {
        switch (e.effectType) {
          case VTOnTapEffectType.scaleDown:
            scaleActive = e.active;
            break;
          case VTOnTapEffectType.touchableOpacity:
            opacityActive = e.active;
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: duration);
    final animation =
        Tween<double>(begin: 1, end: scaleActive).animate(controller);

    setActiveValue();
    return GestureDetector(
      onTapDown: (_) {
        valueNotifier.value = opacityActive;
        controller.forward();
      },
      onTapUp: (_) {
        valueNotifier.value = 1;
        controller.reverse();
        onTap();
      },
      onTapCancel: () {
        valueNotifier.value = 1;
        controller.reverse();
      },
      child: ValueListenableBuilder(
        valueListenable: valueNotifier,
        child: child,
        builder: (context, value, child) {
          Widget result = child;

          for (var effect in effects) {
            final tmp = result;
            if (effect.effectType == VTOnTapEffectType.scaleDown) {
              result = ScaleTransition(
                scale: animation,
                child: tmp,
              );
            }
            if (effect.effectType == VTOnTapEffectType.touchableOpacity) {
              result = AnimatedOpacity(
                duration: this.duration,
                opacity: value,
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
