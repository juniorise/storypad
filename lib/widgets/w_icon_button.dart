import 'package:flutter/material.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';

class WIconButton extends StatelessWidget {
  const WIconButton({
    Key? key,
    this.onPressed,
    this.iconData,
    this.iconColor,
    this.filledColor,
    this.elevation = 0.0,
    this.size = 48.0,
    this.iconImage,
  })  : assert(elevation >= 0),
        assert(size >= 0),
        assert(
          iconData != null && iconImage == null ||
              iconData == null && iconImage != null,
        ),
        super(key: key);

  final double size;
  final IconData? iconData;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? filledColor;
  final double elevation;
  final String? iconImage;

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
              child: iconImage == null
                  ? Icon(
                      iconData,
                      color: iconColor ?? _theme.colorScheme.onSurface,
                      size: size / 2,
                    )
                  : AspectRatio(
                      aspectRatio: 1,
                      child: Center(
                        child: Image.asset(
                          iconImage!,
                          width: size / 2,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
