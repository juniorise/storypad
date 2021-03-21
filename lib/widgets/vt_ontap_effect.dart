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
    required this.effectType,
    required this.active,
  }) : assert(active <= 1 && active >= 0);
}

class VTOnTapEffect extends HookWidget {
  VTOnTapEffect({
    Key? key,
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 150),
    this.effects = const [
      VTOnTapEffectItem(
        effectType: VTOnTapEffectType.touchableOpacity,
        active: 0.5,
      ),
    ],
  }) : super(key: key);

  final Widget child;
  final List<VTOnTapEffectItem> effects;
  final VoidCallback onTap;
  final Duration duration;

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
    final animation =
        Tween<double>(begin: 1, end: _scaleActive).animate(controller);
    final animation2 =
        Tween<double>(begin: 1, end: _opacityActive).animate(controller);

    setActiveValue();
    return GestureDetector(
      onTapDown: (_) {
        controller.forward();
      },
      onTapUp: (_) {
        controller.reverse();
        onTap();
      },
      onTapCancel: () {
        controller.reverse();
      },
      child: AnimatedBuilder(
        child: child,
        animation: controller,
        builder: (context, child) {
          Widget result = child ?? const SizedBox();
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
                opacity: animation2.value,
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
