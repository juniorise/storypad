import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/toolbar.dart' as toolbar;
import 'package:image_picker/image_picker.dart';

class WQuillToolbar extends StatefulWidget implements PreferredSizeWidget {
  final List<Widget> children;

  const WQuillToolbar({Key key, @required this.children}) : super(key: key);

  factory WQuillToolbar.basic(
      {Key key,
      @required QuillController controller,
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
      bool showHistory = true,
      bool showHorizontalRule = false,
      toolbar.OnImagePickCallback onImagePickCallback}) {
    toolbar.iconSize = toolbarIconSize;
    return WQuillToolbar(key: key, children: [
      Visibility(
        visible: showHistory,
        child: toolbar.HistoryButton(
          icon: Icons.undo_outlined,
          controller: controller,
          undo: true,
        ),
      ),
      Visibility(
        visible: showHistory,
        child: toolbar.HistoryButton(
          icon: Icons.redo_outlined,
          controller: controller,
          undo: false,
        ),
      ),
      SizedBox(width: 0.6),
      Visibility(
        visible: showBoldButton,
        child: toolbar.ToggleStyleButton(
          attribute: Attribute.bold,
          icon: Icons.format_bold,
          controller: controller,
        ),
      ),
      SizedBox(width: 0.6),
      Visibility(
        visible: showItalicButton,
        child: toolbar.ToggleStyleButton(
          attribute: Attribute.italic,
          icon: Icons.format_italic,
          controller: controller,
        ),
      ),
      SizedBox(width: 0.6),
      Visibility(
        visible: showUnderLineButton,
        child: toolbar.ToggleStyleButton(
          attribute: Attribute.underline,
          icon: Icons.format_underline,
          controller: controller,
        ),
      ),
      SizedBox(width: 0.6),
      Visibility(
        visible: showStrikeThrough,
        child: toolbar.ToggleStyleButton(
          attribute: Attribute.strikeThrough,
          icon: Icons.format_strikethrough,
          controller: controller,
        ),
      ),
      SizedBox(width: 0.6),
      Visibility(
        visible: showColorButton,
        child: toolbar.ColorButton(
          icon: Icons.color_lens,
          controller: controller,
          background: false,
        ),
      ),
      SizedBox(width: 0.6),
      Visibility(
        visible: showBackgroundColorButton,
        child: toolbar.ColorButton(
          icon: Icons.format_color_fill,
          controller: controller,
          background: true,
        ),
      ),
      SizedBox(width: 0.6),
      Visibility(
        visible: showClearFormat,
        child: toolbar.ClearFormatButton(
          icon: Icons.format_clear,
          controller: controller,
        ),
      ),
      SizedBox(width: 0.6),
      Visibility(
        visible: onImagePickCallback != null,
        child: toolbar.ImageButton(
          icon: Icons.image,
          controller: controller,
          imageSource: ImageSource.gallery,
          onImagePickCallback: onImagePickCallback,
        ),
      ),
      SizedBox(width: 0.6),
      Visibility(
        visible: onImagePickCallback != null,
        child: toolbar.ImageButton(
          icon: Icons.photo_camera,
          controller: controller,
          imageSource: ImageSource.camera,
          onImagePickCallback: onImagePickCallback,
        ),
      ),
      Visibility(
          visible: showHeaderStyle,
          child: VerticalDivider(
              indent: 16, endIndent: 16, color: Colors.grey.shade400)),
      Visibility(
          visible: showHeaderStyle,
          child: toolbar.SelectHeaderStyleButton(controller: controller)),
      VerticalDivider(indent: 16, endIndent: 16, color: Colors.grey.shade400),
      Visibility(
        visible: showListNumbers,
        child: toolbar.ToggleStyleButton(
          attribute: Attribute.ol,
          controller: controller,
          icon: Icons.format_list_numbered,
        ),
      ),
      Visibility(
        visible: showListBullets,
        child: toolbar.ToggleStyleButton(
          attribute: Attribute.ul,
          controller: controller,
          icon: Icons.format_list_bulleted,
        ),
      ),
      Visibility(
        visible: showListCheck,
        child: toolbar.ToggleCheckListButton(
          attribute: Attribute.unchecked,
          controller: controller,
          icon: Icons.check_box,
        ),
      ),
      Visibility(
        visible: showCodeBlock,
        child: toolbar.ToggleStyleButton(
          attribute: Attribute.codeBlock,
          controller: controller,
          icon: Icons.code,
        ),
      ),
      Visibility(
          visible: !showListNumbers &&
              !showListBullets &&
              !showListCheck &&
              !showCodeBlock,
          child: VerticalDivider(
              indent: 16, endIndent: 16, color: Colors.grey.shade400)),
      Visibility(
        visible: showQuote,
        child: toolbar.ToggleStyleButton(
          attribute: Attribute.blockQuote,
          controller: controller,
          icon: Icons.format_quote,
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
          visible: showQuote,
          child: VerticalDivider(
              indent: 16, endIndent: 16, color: Colors.grey.shade400)),
      Visibility(
          visible: showLink,
          child: toolbar.LinkStyleButton(controller: controller)),
      Visibility(
        visible: showHorizontalRule,
        child: toolbar.InsertEmbedButton(
          controller: controller,
          icon: Icons.horizontal_rule,
        ),
      ),
    ]);
  }

  @override
  _WQuillToolbarState createState() => _WQuillToolbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _WQuillToolbarState extends State<WQuillToolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tightFor(height: widget.preferredSize.height),
      color: Theme.of(context).canvasColor,
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
