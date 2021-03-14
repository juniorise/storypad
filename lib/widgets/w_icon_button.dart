import 'package:flutter/material.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';

class WIconButton extends StatelessWidget {
  const WIconButton({
    Key key,
    @required this.iconData,
    @required this.onPressed,
    this.iconColor,
  }) : super(key: key);

  final IconData iconData;
  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return VTOnTapEffect(
      effects: [
        VTOnTapEffectItem(
          effectType: VTOnTapEffectType.scaleDown,
          active: 0.9,
        ),
      ],
      child: Container(
        width: kToolbarHeight,
        child: IconButton(
          highlightColor: _theme.disabledColor,
          onPressed: onPressed,
          icon: Icon(
            iconData,
            color: iconColor ?? _theme.primaryColorDark,
            size: 24,
          ),
        ),
      ),
    );
  }
}
