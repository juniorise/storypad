import 'package:flutter/material.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:write_story/widgets/w_icon_button.dart';

class WHistoryButton extends StatefulWidget {
  final IconData icon;
  final bool undo;
  final QuillController controller;

  WHistoryButton(
      {Key? key,
      required this.icon,
      required this.controller,
      required this.undo})
      : super(key: key);

  @override
  _WHistoryButtonState createState() => _WHistoryButtonState();
}

class _WHistoryButtonState extends State<WHistoryButton> {
  Color? _iconColor;
  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    _setIconColor();

    widget.controller.changes.listen((event) async {
      _setIconColor();
    });
    return WIconButton(
      iconData: widget.icon,
      onPressed: _changeHistory,
      iconColor: _iconColor,
    );
  }

  void _setIconColor() {
    if (!mounted) return;

    if (widget.undo) {
      setState(() {
        _iconColor = widget.controller.hasUndo
            ? theme.iconTheme.color
            : theme.disabledColor;
      });
    } else {
      setState(() {
        _iconColor = widget.controller.hasRedo
            ? theme.iconTheme.color
            : theme.disabledColor;
      });
    }
  }

  void _changeHistory() {
    if (widget.undo) {
      if (widget.controller.hasUndo) {
        widget.controller.undo();
      }
    } else {
      if (widget.controller.hasRedo) {
        widget.controller.redo();
      }
    }

    _setIconColor();
  }
}
