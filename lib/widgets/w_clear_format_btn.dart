import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/toolbar.dart' as toolbar;
import 'package:write_story/widgets/vt_ontap_effect.dart';

class WClearFormatButton extends StatefulWidget {
  final IconData icon;
  final QuillController controller;

  const WClearFormatButton({
    required this.icon,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  _WClearFormatButtonState createState() => _WClearFormatButtonState();
}

class _WClearFormatButtonState extends State<WClearFormatButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color;
    final fillColor = theme.colorScheme.background;
    return toolbar.QuillIconButton(
        highlightElevation: 0,
        hoverElevation: 0,
        size: toolbar.iconSize * 1.77,
        icon: Icon(widget.icon, size: toolbar.iconSize, color: iconColor),
        fillColor: fillColor,
        onPressed: () {
          onTapVibrate();
          for (Attribute k
              in widget.controller.getSelectionStyle().attributes.values) {
            widget.controller.formatSelection(Attribute.clone(k, null));
          }
        });
  }
}

class WMoveCursurButton extends StatefulWidget {
  final IconData icon;
  final QuillController controller;
  final bool isRight;

  const WMoveCursurButton({
    required this.icon,
    required this.controller,
    this.isRight = false,
    Key? key,
  }) : super(key: key);

  @override
  _WMoveCursurButtonState createState() => _WMoveCursurButtonState();
}

class _WMoveCursurButtonState extends State<WMoveCursurButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color;
    final fillColor = theme.colorScheme.background;
    return toolbar.QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: toolbar.iconSize * 1.77,
      icon: Icon(widget.icon, size: toolbar.iconSize, color: iconColor),
      fillColor: fillColor,
      onPressed: () {
        onTapVibrate();
        moveCursor(1);
      },
    );
  }

  moveCursor(int value) {
    final offsetLeft = widget.controller.selection.baseOffset - value;
    final offsetRight = widget.controller.selection.baseOffset + value;

    widget.controller.updateSelection(
      TextSelection.fromPosition(
        TextPosition(offset: widget.isRight ? offsetRight : offsetLeft),
      ),
      ChangeSource.LOCAL,
    );
  }
}
