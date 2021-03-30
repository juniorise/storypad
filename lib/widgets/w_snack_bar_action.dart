// A button for a [SnackBar], known as an "action".
import 'package:flutter/material.dart';
import 'package:write_story/configs/theme_config.dart';
import 'package:write_story/constants/config_constant.dart';

///
/// Snack bar actions are always enabled. If you want to disable a snack bar
/// action, simply don't include it in the snack bar.
///
/// Snack bar actions can only be pressed once. Subsequent presses are ignored.
///
/// See also:
///
///  * [SnackBar]
///  * <https://material.io/design/components/snackbars.html>
class WSnackBarAction extends SnackBarAction {
  /// Creates an action for a [SnackBar].
  ///
  /// The [label] and [onPressed] arguments must be non-null.
  const WSnackBarAction({
    Key? key,
    required this.label,
    required this.onPressed,
    this.warning = false,
  }) : super(
          key: key,
          onPressed: onPressed,
          textColor: null,
          disabledTextColor: null,
          label: label,
        );

  /// applied error color to action if warning is true
  final bool warning;

  /// The button label.
  final String label;

  /// The callback to be called when the button is pressed. Must not be null.
  ///
  /// This callback will be called at most once each time this action is
  /// displayed in a [SnackBar].
  final VoidCallback onPressed;

  @override
  State<WSnackBarAction> createState() => _WSnackBarActionState();
}

class _WSnackBarActionState extends State<WSnackBarAction> {
  bool _haveTriggeredAction = false;

  void _handlePressed() {
    if (_haveTriggeredAction) return;
    setState(() {
      _haveTriggeredAction = true;
    });
    widget.onPressed();
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar(reason: SnackBarClosedReason.action);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    return TextButton(
      onPressed: _haveTriggeredAction ? null : _handlePressed,
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: ConfigConstant.circlarRadius1,
          ),
        ),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.pressed) ||
                states.contains(MaterialState.focused) ||
                states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.selected)) {
              final normalColor = isDarkMode
                  ? ThemeConfig.darkScheme.onSecondary
                  : ThemeConfig.lightScheme.onSecondary;
              final warningColor = isDarkMode
                  ? ThemeConfig.darkScheme.onError
                  : ThemeConfig.lightScheme.onError;
              return widget.warning ? warningColor : normalColor;
            } else {
              return isDarkMode
                  ? ThemeConfig.darkScheme.secondary
                  : ThemeConfig.lightScheme.secondary;
            }
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.pressed) ||
                states.contains(MaterialState.focused) ||
                states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.selected)) {
              final normalColor = isDarkMode
                  ? ThemeConfig.darkScheme.secondary
                  : ThemeConfig.lightScheme.secondary;
              final warningColor = isDarkMode
                  ? ThemeConfig.darkScheme.error
                  : ThemeConfig.lightScheme.error;
              return widget.warning ? warningColor : normalColor;
            } else {
              return Colors.transparent;
            }
          },
        ),
      ),
      child: Text(widget.label),
    );
  }
}
