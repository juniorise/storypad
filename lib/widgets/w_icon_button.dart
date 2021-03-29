import 'package:flutter/material.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';

class WIconButton extends StatelessWidget {
  const WIconButton({
    Key? key,
    required this.iconData,
    required this.onPressed,
    this.iconColor,
    this.filledColor,
    this.elevation = 0.0,
    this.size = 48.0,
  })  : assert(elevation >= 0),
        assert(size >= 0),
        super(key: key);

  final double size;
  final IconData iconData;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? filledColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(size / 2),
        elevation: elevation,
        color: Colors.transparent,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filledColor,
          ),
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
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(size),
              onTap: onPressed,
              child: Icon(
                iconData,
                color: iconColor ?? _theme.colorScheme.onSurface,
                size: size / 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
