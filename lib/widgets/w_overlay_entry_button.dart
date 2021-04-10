import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/app_helper/measure_size.dart';
import 'package:write_story/constants/config_constant.dart';

enum WOverlayFloatingType {
  topToBottom,
  bottomToTop,
}

typedef WOverlayBuilder = Widget Function(
  BuildContext context,
  VoidCallback callback,
);

typedef WOverlayBuilder2 = Widget Function(
  BuildContext context,
  GlobalKey buttonKey,
  VoidCallback callback,
);

class WOverlayEntryButton extends HookWidget {
  final Key? key;
  final Duration duration;
  static GlobalKey floatingKey = LabeledGlobalKey("Floating");
  final WOverlayFloatingType type;
  final WOverlayBuilder floatingBuilder;
  final WOverlayBuilder2 childBuilder;

  WOverlayEntryButton({
    this.key,
    required this.floatingBuilder,
    required this.childBuilder,
    this.type = WOverlayFloatingType.topToBottom,
    this.duration = ConfigConstant.fadeDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(wOverlayEntryButtonProvider);
    final controller = useAnimationController(duration: this.duration);
    return childBuilder(
      context,
      floatingKey,
      () => {
        open(notifier, context, controller),
      },
    );
  }

  void open(
    WOverlayEntryButtonNotifier notifier,
    BuildContext context,
    AnimationController controller,
  ) {
    notifier.floating = createFloating(
      context: context,
      controller: controller,
      notifier: notifier,
    );
    Overlay.of(context)?.insert(notifier.floating!);
    controller.forward();
    notifier.setIsFloatingOpen(true);
  }

  void close(
    AnimationController controller,
    WOverlayEntryButtonNotifier notifier,
  ) {
    if (controller.isAnimating == false) {
      controller.reverse().then((value) {
        notifier.floating?.remove();
      });
      notifier.setIsFloatingOpen(false);
    }
  }

  OverlayEntry? createFloating({
    required BuildContext context,
    required AnimationController controller,
    required WOverlayEntryButtonNotifier notifier,
  }) {
    if (floatingKey.currentContext == null) return null;
    RenderBox renderBox =
        floatingKey.currentContext?.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    double _width = MediaQuery.of(context).size.width;
    double _colorPickerWidth = (notifier.floatingChildSize.width) - 36;

    double _left = offset.dx - _colorPickerWidth / 2;
    double? left = _left < 10 ? 10 : _left;
    double? _right = _width - left - _colorPickerWidth;
    double? right = _right < 10 ? 10 : _right;

    double _top = offset.dy - (notifier.floatingChildSize.height * 2 - 8);
    double top = _top;
    if (_top < kToolbarHeight) {
      top = kToolbarHeight + 48;
    }

    if (offset.dx >= _width / 2) {
      left = null;
    } else {
      right = null;
    }

    if (notifier.floatingChildSize.width == 0) {
      left = null;
      right = 16;
    }

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (notifier.isFloatingOpen) {
              controller.reverse().then((value) {
                notifier.floating?.remove();
              });
              notifier.setIsFloatingOpen(false);
            }
          },
          child: Stack(
            children: [
              Positioned(
                left: left,
                right: right,
                top: top,
                child: MeasureSize(
                  onChange: (Size size) {
                    notifier.setFloatingChildSize(size);
                  },
                  child: AnimatedBuilder(
                    child: this.floatingBuilder(context, () {
                      close(controller, notifier);
                    }),
                    animation: controller,
                    builder: (context, child) {
                      double dy = 0;
                      switch (this.type) {
                        case WOverlayFloatingType.bottomToTop:
                          dy = (1 - controller.value) * 10;
                          break;
                        case WOverlayFloatingType.topToBottom:
                          dy = controller.value * 10;
                          break;
                        default:
                      }
                      return Transform.translate(
                        offset: Offset(0.0, dy),
                        child: Opacity(
                          opacity: controller.value,
                          child: child,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WOverlayEntryButtonNotifier extends ChangeNotifier {
  OverlayEntry? floating;
  bool _isFloatingOpen = false;
  Size? _floatingChildSize;

  setIsFloatingOpen(bool value) {
    this._isFloatingOpen = value;
    notifyListeners();
  }

  setFloatingChildSize(Size size) {
    this._floatingChildSize = size;
    notifyListeners();
  }

  bool get isFloatingOpen => this._isFloatingOpen;
  Size get floatingChildSize => this._floatingChildSize ?? const Size(0, 0);
}

final wOverlayEntryButtonProvider =
    ChangeNotifierProvider<WOverlayEntryButtonNotifier>((_) {
  return WOverlayEntryButtonNotifier();
});
