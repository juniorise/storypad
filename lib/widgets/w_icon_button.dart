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
    return Center(
      child: Container(
        height: 48,
        width: 48,
        child: VTOnTapEffect(
          onTap: onPressed,
          effects: [
            VTOnTapEffectItem(
              effectType: VTOnTapEffectType.scaleDown,
              active: 0.9,
            ),
          ],
          child: InkWell(
            highlightColor:
                Theme.of(context).primaryColorDark.withOpacity(0.05),
            borderRadius: BorderRadius.circular(48),
            onTap: onPressed,
            child: Icon(
              iconData,
              color: iconColor ?? _theme.primaryColorDark,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
