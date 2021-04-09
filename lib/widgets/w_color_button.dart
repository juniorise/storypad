import 'package:animated_clipper/animated_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:flutter_quill/utils/color.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/toolbar.dart' as toolbar;
import 'package:write_story/constants/config_constant.dart';
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

  late bool _isToggledColor;
  late bool _isToggledBackground;
  late bool _isWhite;
  late bool _isWhitebackground;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  void _didChangeEditingValue() {
    setState(() {
      _isToggledColor =
          _getIsToggledColor(widget.controller.getSelectionStyle().attributes);
      _isToggledBackground = _getIsToggledBackground(
          widget.controller.getSelectionStyle().attributes);
      _isWhite = _isToggledColor &&
          _selectionStyle.attributes['color']!.value == '#ffffff';
      _isWhitebackground = _isToggledBackground &&
          _selectionStyle.attributes['background']!.value == '#ffffff';
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
    _isWhite = _isToggledColor &&
        _selectionStyle.attributes['color']!.value == '#ffffff';
    _isWhitebackground = _isToggledBackground &&
        _selectionStyle.attributes['background']!.value == '#ffffff';
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
      _isWhite = _isToggledColor &&
          _selectionStyle.attributes['color']!.value == '#ffffff';
      _isWhitebackground = _isToggledBackground &&
          _selectionStyle.attributes['background']!.value == '#ffffff';
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? iconColor = _isToggledColor && !widget.background && !_isWhite
        ? stringToColor(_selectionStyle.attributes['color']!.value)
        : theme.iconTheme.color;

    var iconColorBackground =
        _isToggledBackground && widget.background && !_isWhitebackground
            ? stringToColor(_selectionStyle.attributes['background']!.value)
            : theme.iconTheme.color;

    Color fillColor = _isToggledColor && !widget.background && _isWhite
        ? stringToColor('#ffffff')
        : theme.canvasColor;
    Color fillColorBackground =
        _isToggledBackground && widget.background && _isWhitebackground
            ? stringToColor('#ffffff')
            : theme.canvasColor;

    return toolbar.QuillIconButton(
      key: floatingKey,
      highlightElevation: 0,
      hoverElevation: 0,
      size: toolbar.iconSize * 1.77,
      fillColor: widget.background ? fillColorBackground : fillColor,
      icon: Icon(
        widget.icon,
        size: toolbar.iconSize,
        color: widget.background ? iconColorBackground : iconColor,
      ),
      onPressed: () => _showColorPicker(
        currentColor: widget.background ? iconColorBackground : iconColor,
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
                left: offset.dx / 2 < 10 ? 10 : offset.dx / 2,
                top: offset.dy - (onPickingColorHeight * 2 - 8),
                child: AnimatedClipReveal(
                  revealFirstChild: isFloatingOpen,
                  pathBuilder: isFloatingOpen
                      ? PathBuilders.circleOut
                      : PathBuilders.circleIn,
                  child: AnimatedBuilder(
                    animation: animationController!,
                    builder: (context, snapshot) {
                      bool isDarkMode =
                          Theme.of(context).colorScheme.brightness ==
                              Brightness.dark;
                      final blackWhiteColor =
                          ColorSwatch(isDarkMode ? 0xFFFFFFFF : 0xFF000000, {
                        50: Colors.white,
                        100: Colors.black,
                      });
                      return Transform.translate(
                        offset: Offset(
                          0.0,
                          (1 - (animationController?.value ?? 0)) * 10,
                        ),
                        child: Opacity(
                          opacity: animationController!.value,
                          child: WColorPicker(
                            blackWhite: blackWhiteColor,
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
