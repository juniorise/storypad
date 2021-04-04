import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_snack_bar_action.dart' as w;

mixin WSnackBar {
  SnackBar buildSnackBar({
    required String title,
    required BuildContext context,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool warning = false,
    bool floating = false,
  }) {
    final style = Theme.of(context)
        .textTheme
        .bodyText1!
        .copyWith(color: Theme.of(context).colorScheme.onSecondary);

    final actions = onActionPressed != null
        ? w.WSnackBarAction(
            label: actionLabel ?? tr("button.okay"),
            warning: warning,
            onPressed: () async {
              onActionPressed();
            },
          )
        : null;

    return SnackBar(
      content: Text(title, style: style),
      action: actions,
      behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  Future<void> showSnackBar({
    required BuildContext context,
    required String title,
    String? actionLabel,
    VoidCallback? onActionPressed,
    VoidCallback? onClose,
    bool warning = false,
    bool floating = false,
  }) async {
    ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
    Future.delayed(Duration(microseconds: 0)).then((value) {
      final SnackBar snack = buildSnackBar(
        title: title,
        context: context,
        actionLabel: actionLabel ?? tr("button.okay"),
        onActionPressed: onActionPressed,
        warning: warning,
        floating: floating,
      );

      onTapVibrate();
      ScaffoldMessenger.of(context).showSnackBar(snack).closed.then(
        (value) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (onClose != null) onClose();
        },
      );
    });
  }
}
