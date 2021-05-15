import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';

class WListTile extends StatelessWidget {
  const WListTile({
    Key? key,
    required this.titleText,
    this.onTap,
    this.iconData,
    this.subtitleText,
    this.tileColor,
    this.forgroundColor,
    this.subtitleMaxLines,
    this.titleMaxLines,
    this.titleFontFamily,
    this.trailing,
    this.borderRadius,
    this.imageIcon,
    this.contentPadding,
    this.titleStyle,
  }) : super(key: key);

  final Color? tileColor;
  final IconData? iconData;
  final String? imageIcon;
  final String titleText;
  final String? subtitleText;
  final Color? forgroundColor;
  final void Function()? onTap;
  final int? subtitleMaxLines;
  final int? titleMaxLines;
  final String? titleFontFamily;
  final Widget? trailing;
  final BorderRadius? borderRadius;
  final EdgeInsets? contentPadding;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: VTOnTapEffect(
        onTap: onTap,
        child: ListTile(
          trailing: trailing,
          contentPadding: contentPadding,
          tileColor: tileColor ?? Theme.of(context).colorScheme.surface,
          leading: AspectRatio(
            aspectRatio: 1.5 / 2,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: imageIcon != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(imageIcon!),
                      )
                    : null,
              ),
              child: iconData != null
                  ? Icon(
                      iconData,
                      color: forgroundColor,
                    )
                  : null,
            ),
          ),
          shape: borderRadius != null
              ? RoundedRectangleBorder(borderRadius: borderRadius!)
              : null,
          title: Text(
            titleText,
            maxLines: titleMaxLines,
            overflow: TextOverflow.ellipsis,
            style: titleStyle ??
                TextStyle(color: forgroundColor, fontFamily: titleFontFamily),
          ),
          subtitle: subtitleText != null
              ? Text(
                  subtitleText!,
                  maxLines: subtitleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: forgroundColor ??
                        Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.5),
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
