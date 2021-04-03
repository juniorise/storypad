import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/toolbar.dart' as toolbar;
import 'package:image_picker/image_picker.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';

class WQuillToolbar extends StatefulWidget implements PreferredSizeWidget {
  final List<Widget> children;

  const WQuillToolbar({Key? key, required this.children}) : super(key: key);

  factory WQuillToolbar.basic({
    Key? key,
    required QuillController controller,
    double toolbarIconSize = 18.0,
    bool showBoldButton = true,
    bool showItalicButton = true,
    bool showUnderLineButton = true,
    bool showStrikeThrough = true,
    bool showColorButton = true,
    bool showBackgroundColorButton = true,
    bool showClearFormat = true,
    bool showHeaderStyle = true,
    bool showListNumbers = true,
    bool showListBullets = true,
    bool showListCheck = true,
    bool showCodeBlock = true,
    bool showQuote = true,
    bool showIndent = true,
    bool showLink = true,
    bool showHorizontalRule = false,
    toolbar.OnImagePickCallback? onImagePickCallback,
  }) {
    final spaceBetween = const SizedBox(width: 4.0);
    final spaceBetween2 = const SizedBox(width: 8.0);

    toolbar.iconSize = toolbarIconSize;
    return WQuillToolbar(
      key: key,
      children: [
        spaceBetween2,
        Visibility(
          visible: showBoldButton,
          child: toolbar.ToggleStyleButton(
            attribute: Attribute.bold,
            icon: Icons.format_bold,
            controller: controller,
            childBuilder: defaultToggleStyleButtonBuilder,
          ),
        ),
        spaceBetween,
        Visibility(
          visible: showItalicButton,
          child: toolbar.ToggleStyleButton(
            attribute: Attribute.italic,
            icon: Icons.format_italic,
            controller: controller,
            childBuilder: defaultToggleStyleButtonBuilder,
          ),
        ),
        spaceBetween,
        Visibility(
          visible: showUnderLineButton,
          child: toolbar.ToggleStyleButton(
            attribute: Attribute.underline,
            icon: Icons.format_underline,
            controller: controller,
            childBuilder: defaultToggleStyleButtonBuilder,
          ),
        ),
        spaceBetween,
        Visibility(
          visible: showStrikeThrough,
          child: toolbar.ToggleStyleButton(
            attribute: Attribute.strikeThrough,
            icon: Icons.format_strikethrough,
            controller: controller,
            childBuilder: defaultToggleStyleButtonBuilder,
          ),
        ),
        spaceBetween,
        Visibility(
          visible: showColorButton,
          child: toolbar.ColorButton(
            icon: Icons.color_lens,
            controller: controller,
            background: false,
          ),
        ),
        spaceBetween,
        Visibility(
          visible: showBackgroundColorButton,
          child: toolbar.ColorButton(
            icon: Icons.format_color_fill,
            controller: controller,
            background: true,
          ),
        ),
        Visibility(
          visible: showClearFormat,
          child: VerticalDivider(
            indent: 16,
            endIndent: 16,
            color: Colors.grey.shade400,
          ),
        ),
        Visibility(
          visible: showClearFormat,
          child: Center(
            child: WClearFormatButton(
              icon: Icons.format_clear,
              controller: controller,
            ),
          ),
        ),
        Visibility(
          visible: showHeaderStyle,
          child: VerticalDivider(
            indent: 16,
            endIndent: 16,
            color: Colors.grey.shade400,
          ),
        ),
        Visibility(
          visible: showHeaderStyle,
          child: toolbar.SelectHeaderStyleButton(controller: controller),
        ),
        VerticalDivider(
          indent: 16,
          endIndent: 16,
          color: Colors.grey.shade400,
        ),
        Visibility(
          visible: showListNumbers,
          child: toolbar.ToggleStyleButton(
            attribute: Attribute.ol,
            controller: controller,
            icon: Icons.format_list_numbered,
            childBuilder: (
              BuildContext context,
              Attribute attribute,
              IconData icon,
              bool? isToggled,
              VoidCallback? onPressed,
            ) {
              final _attributes = controller.getSelectionStyle().attributes;
              final bool hasBlockList = _attributes.containsKey("blockquote");
              final _onPressed = hasBlockList ? null : onPressed;
              return defaultToggleStyleButtonBuilder(
                context,
                attribute,
                icon,
                isToggled,
                _onPressed,
              );
            },
          ),
        ),
        Visibility(
          visible: showListBullets,
          child: toolbar.ToggleStyleButton(
            attribute: Attribute.ul,
            controller: controller,
            icon: Icons.format_list_bulleted,
            childBuilder: (
              BuildContext context,
              Attribute attribute,
              IconData icon,
              bool? isToggled,
              VoidCallback? onPressed,
            ) {
              final _attributes = controller.getSelectionStyle().attributes;
              final bool hasBlockList = _attributes.containsKey("blockquote");
              final _onPressed = hasBlockList ? null : onPressed;
              return defaultToggleStyleButtonBuilder(
                context,
                attribute,
                icon,
                isToggled,
                _onPressed,
              );
            },
          ),
        ),
        Visibility(
          visible: showListCheck,
          child: toolbar.ToggleCheckListButton(
            attribute: Attribute.unchecked,
            controller: controller,
            icon: Icons.check_box,
            childBuilder: (
              BuildContext context,
              Attribute attribute,
              IconData icon,
              bool? isToggled,
              VoidCallback? onPressed,
            ) {
              final _attributes = controller.getSelectionStyle().attributes;
              final bool hasBlockList = _attributes.containsKey("blockquote");
              final _onPressed = hasBlockList ? null : onPressed;
              return defaultToggleStyleButtonBuilder(
                context,
                attribute,
                icon,
                isToggled,
                _onPressed,
              );
            },
          ),
        ),
        VerticalDivider(
          indent: 16,
          endIndent: 16,
          color: Colors.grey.shade400,
        ),
        Visibility(
          visible: showCodeBlock,
          child: toolbar.ToggleStyleButton(
            attribute: Attribute.codeBlock,
            controller: controller,
            icon: Icons.code,
            childBuilder: (
              BuildContext context,
              Attribute attribute,
              IconData icon,
              bool? isToggled,
              VoidCallback? onPressed,
            ) {
              // print(controller.getSelectionStyle());
              final _attributes = controller.getSelectionStyle().attributes;
              final bool hasBlockQuote = _attributes.containsKey("blockquote");
              final bool hasBlockList = _attributes.containsKey("list");
              final _onPressed =
                  hasBlockQuote || hasBlockList ? null : onPressed;
              return defaultToggleStyleButtonBuilder(
                context,
                attribute,
                icon,
                isToggled,
                _onPressed,
              );
            },
          ),
        ),
        Visibility(
          visible: showQuote,
          child: toolbar.ToggleStyleButton(
            attribute: Attribute.blockQuote,
            controller: controller,
            icon: Icons.format_quote,
            childBuilder: (
              BuildContext context,
              Attribute attribute,
              IconData icon,
              bool? isToggled,
              VoidCallback? onPressed,
            ) {
              final _attributes = controller.getSelectionStyle().attributes;
              final bool hasBlockList = _attributes.containsKey("list");
              final _onPressed = hasBlockList ? null : onPressed;
              return defaultToggleStyleButtonBuilder(
                context,
                attribute,
                icon,
                isToggled,
                _onPressed,
              );
            },
          ),
        ),
        Visibility(
          visible: showIndent,
          child: toolbar.IndentButton(
            icon: Icons.format_indent_increase,
            controller: controller,
            isIncrease: true,
          ),
        ),
        Visibility(
          visible: showIndent,
          child: toolbar.IndentButton(
            icon: Icons.format_indent_decrease,
            controller: controller,
            isIncrease: false,
          ),
        ),
        Visibility(
          visible: showLink,
          child: toolbar.LinkStyleButton(controller: controller),
        ),
        Visibility(
          visible: showHorizontalRule,
          child: toolbar.InsertEmbedButton(
            controller: controller,
            icon: Icons.horizontal_rule,
          ),
        ),
        VerticalDivider(
          indent: 16,
          endIndent: 16,
          color: Colors.grey.shade400,
        ),
        Visibility(
          visible: onImagePickCallback != null,
          child: toolbar.ImageButton(
            icon: Icons.image,
            controller: controller,
            imageSource: ImageSource.gallery,
            onImagePickCallback: onImagePickCallback,
          ),
        ),
        spaceBetween,
        Visibility(
          visible: onImagePickCallback != null,
          child: toolbar.ImageButton(
            icon: Icons.photo_camera,
            controller: controller,
            imageSource: ImageSource.camera,
            onImagePickCallback: onImagePickCallback,
          ),
        ),
        spaceBetween2,
      ],
    );
  }

  static Widget defaultToggleStyleButtonBuilder(
    BuildContext context,
    Attribute attribute,
    IconData icon,
    bool? isToggled,
    VoidCallback? onPressed,
  ) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null;
    final iconColor = isEnabled ? theme.iconTheme.color : theme.disabledColor;
    final fillColor =
        isToggled == true ? theme.dividerColor : Colors.transparent;

    return VTOnTapEffect(
      onTap: onPressed != null ? onPressed : () {},
      effects: [
        VTOnTapEffectItem(
          effectType: VTOnTapEffectType.scaleDown,
          active: 0.95,
        ),
        VTOnTapEffectItem(
          effectType: VTOnTapEffectType.touchableOpacity,
          active: 0.5,
        ),
      ],
      child: toolbar.QuillIconButton(
        highlightElevation: 1,
        hoverElevation: 0,
        size: 44,
        icon: Icon(icon, size: 24, color: iconColor),
        fillColor: fillColor,
        onPressed: onPressed,
      ),
    );
  }

  @override
  _WQuillToolbarState createState() => _WQuillToolbarState();

  @override
  Size get preferredSize => Size.fromHeight(44 + 8.0);
}

class _WQuillToolbarState extends State<WQuillToolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tightFor(height: widget.preferredSize.height),
      color: Theme.of(context).colorScheme.background,
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.children,
            ),
          ),
        ],
      ),
    );
  }
}

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
