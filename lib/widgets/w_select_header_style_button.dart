import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:storypad/widgets/w_tap_effect.dart';
import 'package:storypad/widgets/w_quil_toolbar.dart';

class WSelectHeaderStyleButton extends StatefulWidget {
  const WSelectHeaderStyleButton({required this.controller, Key? key}) : super(key: key);

  final QuillController controller;

  @override
  _WSelectHeaderStyleButtonState createState() => _WSelectHeaderStyleButtonState();
}

class _WSelectHeaderStyleButtonState extends State<WSelectHeaderStyleButton> {
  Attribute? _value;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  void _didChangeEditingValue() {
    setState(() {
      _value = _selectionStyle.attributes[Attribute.header.key] ?? Attribute.header;
    });
  }

  void _selectAttribute(value) {
    widget.controller.formatSelection(value);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _value = _selectionStyle.attributes[Attribute.header.key] ?? Attribute.header;
    });
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  void didUpdateWidget(covariant WSelectHeaderStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _value = _selectionStyle.attributes[Attribute.header.key] ?? Attribute.header;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _selectHeadingStyleButtonBuilder(
      context,
      _value,
      _selectAttribute,
      WTOOLBARICONSIZE,
    );
  }

  Widget _selectHeadingStyleButtonBuilder(
    BuildContext context,
    Attribute? value,
    ValueChanged<Attribute?> onSelected,
    double iconSize,
  ) {
    final _valueToText = <Attribute, String>{
      Attribute.h1: 'H1',
      Attribute.h2: 'H2',
      Attribute.h3: 'H3',
    };

    final _valueAttribute = <Attribute>[Attribute.h1, Attribute.h2, Attribute.h3];
    final _valueString = <String>['H1', 'H2', 'H3'];

    final theme = Theme.of(context);
    final style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: iconSize * 0.7,
    );

    final _attributes = widget.controller.getSelectionStyle().attributes;
    final bool hasCodeBlock = _attributes.containsKey("code-block");
    final bool hasList = _attributes.containsKey("list");
    final bool disable = hasCodeBlock || hasList;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: !kIsWeb ? 1.0 : 5.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: iconSize * 1.77,
              height: iconSize * 1.77,
            ),
            child: WTapEffect(
              onTap: disable ? null : () {},
              effects: [
                WTapEffectType.scaleDown,
                WTapEffectType.touchableOpacity,
              ],
              child: RawMaterialButton(
                hoverElevation: 0,
                highlightElevation: 0,
                elevation: 0,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                fillColor:
                    _valueToText[value] == _valueString[index] && !disable ? theme.dividerColor : theme.canvasColor,
                onPressed: disable
                    ? null
                    : () {
                        if (_valueToText[value] == _valueString[index]) {
                          onSelected(Attribute.header);
                        } else {
                          onSelected(_valueAttribute[index]);
                        }
                      },
                child: Text(
                  _valueString[index],
                  style: style.copyWith(
                    color: disable ? theme.disabledColor : theme.iconTheme.color,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
