import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum WTapEffectType {
  touchableOpacity,
  scaleDown,
}

class WTapEffect extends HookWidget {
  WTapEffect({
    Key? key,
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 100),
    this.vibrate = false,
    this.behavior,
    this.effects = const [
      WTapEffectType.touchableOpacity,
    ],
  }) : super(key: key);

  final Widget child;
  final List<WTapEffectType> effects;
  final void Function()? onTap;
  final Duration duration;
  final bool vibrate;
  final HitTestBehavior? behavior;

  final double scaleActive = 0.98;
  final double opacityActive = 0.2;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: duration);

    final animation = Tween<double>(begin: 1, end: scaleActive).animate(controller);
    final animation2 = Tween<double>(begin: 1, end: opacityActive).animate(controller);

    void onTapCancel() => controller.reverse();
    void onTapDown() => controller.forward();
    void onTapUp() => controller.reverse().then((value) => onTap!());

    if (onTap != null) {
      return GestureDetector(
        behavior: behavior,
        onTapDown: (detail) => onTapDown(),
        onTapUp: (detail) => onTapUp(),
        onTapCancel: () => onTapCancel(),
        child: buildChild(controller, animation, animation2),
      );
    } else {
      return buildChild(controller, animation, animation2);
    }
  }

  AnimatedBuilder buildChild(
    AnimationController controller,
    Animation<double> animation,
    Animation<double> animation2,
  ) {
    return AnimatedBuilder(
      child: child,
      animation: controller,
      builder: (context, child) {
        Widget result = child ?? const SizedBox();
        for (var effect in effects) {
          switch (effect) {
            case WTapEffectType.scaleDown:
              result = ScaleTransition(scale: animation, child: result);
              break;
            case WTapEffectType.touchableOpacity:
              result = Opacity(opacity: animation2.value, child: result);
              break;
          }
        }
        return result;
      },
    );
  }
}
