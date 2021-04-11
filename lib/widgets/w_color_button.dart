import 'package:animated_clipper/animated_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:flutter_quill/utils/color.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/toolbar.dart' as toolbar;
import 'package:write_story/app_helper/measure_size.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_color_picker.dart';

/// Controls color styles.
///
/// When pressed, this button displays overlay toolbar with
/// buttons for each color.
class WColorButton extends StatefulWidget {
  final IconData icon;
  final bool background;
  final QuillController controller;

  const WColorButton({
    required this.icon,
    required this.controller,
    required this.background,
    Key? key,
  }) : super(key: key);

  @override
  _WColorButtonState createState() => _WColorButtonState();
}

class _WColorButtonState extends State<WColorButton>
    with SingleTickerProviderStateMixin {
  GlobalKey floatingKey = LabeledGlobalKey("Floating");
  bool isFloatingOpen = false;
  OverlayEntry? floating;

  AnimationController? animationController;
  Size? _colorPickerSize;

  late bool _isToggledColor;
  late bool _isToggledBackground;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  void _didChangeEditingValue() {
    setState(() {
      _isToggledColor =
          _getIsToggledColor(widget.controller.getSelectionStyle().attributes);
      _isToggledBackground = _getIsToggledBackground(
          widget.controller.getSelectionStyle().attributes);
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: ConfigConstant.fadeDuration,
    );
    _isToggledColor = _getIsToggledColor(_selectionStyle.attributes);
    _isToggledBackground = _getIsToggledBackground(_selectionStyle.attributes);
    widget.controller.addListener(_didChangeEditingValue);
  }

  bool _getIsToggledColor(Map<String, Attribute> attrs) {
    return attrs.containsKey(Attribute.color.key);
  }

  bool _getIsToggledBackground(Map<String, Attribute> attrs) {
    return attrs.containsKey(Attribute.background.key);
  }

  @override
  void didUpdateWidget(covariant WColorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _isToggledColor = _getIsToggledColor(_selectionStyle.attributes);
      _isToggledBackground =
          _getIsToggledBackground(_selectionStyle.attributes);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  Color _textColorForBackground(Color backgroundColor) {
    if (ThemeData.estimateBrightnessForColor(backgroundColor) ==
        Brightness.dark) {
      return Colors.white;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? iconColor = _isToggledColor && !widget.background
        ? stringToColor(_selectionStyle.attributes['color']!.value)
        : theme.iconTheme.color;

    Color? iconColorBackground = _isToggledBackground && widget.background
        ? stringToColor(_selectionStyle.attributes['background']!.value)
        : theme.iconTheme.color;

    bool isDarkMode = theme.colorScheme.brightness == Brightness.dark;
    Color? fillColor = _textColorForBackground(iconColor!);
    Color fillColorBackground = _textColorForBackground(iconColorBackground!);

    Color? displayIconColor;
    Color? displayiconColorBackground;

    if (fillColor == Colors.black) {
      if (isDarkMode) {
        fillColor = Colors.transparent;
        displayIconColor = iconColor;
      } else {
        fillColor = iconColor;
        displayIconColor = theme.iconTheme.color;
      }
    } else if (fillColor == Colors.white) {
      if (!isDarkMode) {
        fillColor = Colors.transparent;
        displayIconColor = iconColor;
      }
    }

    if (fillColorBackground == Colors.black) {
      if (isDarkMode) {
        fillColorBackground = Colors.transparent;
        displayiconColorBackground = iconColorBackground;
      } else {
        fillColorBackground = iconColorBackground;
        displayiconColorBackground = theme.iconTheme.color;
      }
    } else if (fillColorBackground == Colors.white) {
      if (!isDarkMode) {
        fillColorBackground = Colors.transparent;
        displayiconColorBackground = iconColorBackground;
      }
    }

    final void Function()? onPressed = () {
      return _showColorPicker(
        currentColor: widget.background ? iconColorBackground : iconColor,
      );
    };

    return VTOnTapEffect(
      onTap: onPressed != null ? onPressed : () {},
      effects: [
        VTOnTapEffectItem(
          effectType: VTOnTapEffectType.scaleDown,
          active: 0.95,
        ),
        VTOnTapEffectItem(
          effectType: VTOnTapEffectType.touchableOpacity,
          active: 0.5,
        ),
      ],
      child: toolbar.QuillIconButton(
        key: floatingKey,
        highlightElevation: 0,
        hoverElevation: 0,
        size: toolbar.iconSize * 1.77,
        fillColor: widget.background ? fillColorBackground : fillColor,
        icon: Icon(
          widget.icon,
          size: toolbar.iconSize,
          color:
              widget.background ? displayiconColorBackground : displayIconColor,
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _changeColor(Color color) {
    String hex = color.value.toRadixString(16);
    if (hex.startsWith('ff')) {
      hex = hex.substring(2);
    }
    hex = '#$hex';
    widget.controller.formatSelection(
      widget.background ? BackgroundAttribute(hex) : ColorAttribute(hex),
    );
  }

  void _showColorPicker({Color? currentColor}) {
    print(currentColor);
    if (animationController?.isAnimating == false) {
      setState(() {
        if (isFloatingOpen) {
          animationController?.reverse();
          floating?.remove();
        } else {
          floating = createFloating(currentColor: currentColor);
          Overlay.of(context)?.insert(floating!);
          animationController?.forward();
        }
        isFloatingOpen = !isFloatingOpen;
      });
    }
  }

  OverlayEntry? createFloating({Color? currentColor}) {
    if (floatingKey.currentContext == null) return null;
    RenderBox renderBox =
        floatingKey.currentContext?.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    double _width = MediaQuery.of(context).size.width;
    double _tmpColorPickerWidth =
        30.0 * 5 + ConfigConstant.margin1 * 4 + ConfigConstant.margin2 * 2;
    double _colorPickerWidth =
        (this._colorPickerSize?.width ?? _tmpColorPickerWidth) - 36;

    double _left = offset.dx - _colorPickerWidth / 2;
    double? left = _left < 10 ? 10 : _left;
    double? _right = _width - left - _colorPickerWidth;
    double? right = _right < 10 ? 10 : _right;

    if (offset.dx >= _width / 2) {
      left = null;
    } else {
      right = null;
    }

    final blackWhiteSwatch = getBlackWhite(context);
    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (isFloatingOpen) {
              animationController?.reverse().then((value) {
                floating?.remove();
              });
              isFloatingOpen = false;
            }
          },
          child: Stack(
            children: [
              Positioned(
                left: left,
                right: right,
                top: offset.dy - (onPickingColorHeight * 2 - 8),
                child: MeasureSize(
                  onChange: (Size size) {
                    setState(() {
                      this._colorPickerSize = size;
                    });
                  },
                  child: AnimatedBuilder(
                    child: AnimatedClipReveal(
                      revealFirstChild: true,
                      duration: Duration(
                        milliseconds:
                            ConfigConstant.fadeDuration.inMilliseconds - 50,
                      ),
                      pathBuilder: PathBuilders.circleOut,
                      child: WColorPicker(
                        blackWhite: blackWhiteSwatch,
                        currentColor: currentColor,
                        onPickedColor: (Color color) {
                          if (animationController?.isAnimating == false) {
                            _changeColor(color);
                            animationController?.reverse().then((value) {
                              floating?.remove();
                              setState(() {
                                isFloatingOpen = false;
                              });
                            });
                          }
                        },
                      ),
                    ),
                    animation: animationController!,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0.0,
                          (1 - (animationController?.value ?? 0)) * 10,
                        ),
                        child: Opacity(
                          opacity: animationController!.value,
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
