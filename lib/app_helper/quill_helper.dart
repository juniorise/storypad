import 'dart:convert';
import 'package:flutter_quill/models/documents/attribute.dart' as attribute;
import 'package:flutter_quill/models/documents/nodes/block.dart' as block;
import 'package:flutter_quill/models/documents/nodes/node.dart' as node;

class QuillHelper {
  static int getImageLength(String paragraph) {
    int i = 0;
    try {
      final List<dynamic> decode = jsonDecode(paragraph);
      decode.forEach((e) {
        final insert = e['insert'];
        if (insert is Map) {
          insert.entries.forEach((e) {
            if (e.value != null && e.value.isNotEmpty) {
              i++; //e.value is link
            }
          });
        }
      });
    } catch (e) {}
    return i;
  }

  static String toPlainText(node.Root root) {
    return root.children
        .map((node.Node e) {
          final atts = e.style.attributes;
          attribute.Attribute? att =
              atts['list'] ?? atts['blockquote'] ?? atts['code-block'];

          if (e is block.Block) {
            int index = 0;
            String result = "";
            e.children.forEach(
              (entry) {
                if (att?.key == "blockquote") {
                  String text = entry.toPlainText();
                  text = text.replaceFirst(RegExp('\n'), '', text.length - 1);
                  result += "\n︳" + text;
                } else if (att?.key == "code-block") {
                  result += '︳' + entry.toPlainText();
                } else {
                  if (att?.value == "checked") {
                    result += "☒\t" + entry.toPlainText();
                  } else if (att?.value == "unchecked") {
                    result += "☐\t" + entry.toPlainText();
                  } else if (att?.value == "ordered") {
                    index++;
                    result += "$index.\t" + entry.toPlainText();
                  } else if (att?.value == "bullet") {
                    result += "•\t" + entry.toPlainText();
                  }
                }
              },
            );
            return result;
          } else {
            return e.toPlainText();
          }
        })
        .join()
        .replaceAll("\uFFFC", "🄹🄿🄶‌");
  }
}
