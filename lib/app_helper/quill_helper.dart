import 'dart:convert';
import 'package:flutter_quill/models/documents/attribute.dart' as attribute;
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/block.dart' as block;
import 'package:flutter_quill/models/documents/nodes/node.dart' as node;
import 'dart:io';

class QuillHelper {
  static node.Root? getRoot(String paragraph) {
    try {
      final decode = jsonDecode(paragraph);
      final document = Document.fromJson(decode);
      return document.root;
    } catch (e) {}
  }

  static Future<List<String>> getLocalImages(Document? document) async {
    List<String> files = [];
    document?.root.children.forEach((e) async {
      final list = e.toDelta().toList();
      list.forEach((k) async {
        final data = k.data;
        if (data is Map) {
          String? path = data['image'];
          if (path != null) {
            bool exist = await File(path).exists();
            if (exist) {
              files.add(path);
            }
          }
        }
      });
    });
    return files;
  }

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
    final plainText = root.children.map((node.Node e) {
      final atts = e.style.attributes;
      attribute.Attribute? att = atts['list'] ?? atts['blockquote'] ?? atts['code-block'];

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
    }).join();

    // final index = plainText.contains("\uFFFC");
    int index = countOccurences(plainText, "\uFFFC");
    String result = numberToStyle("$index");

    if (index == 0) {
      return plainText;
    } else {
      return "x" + result + " images\n" + plainText.replaceAll("\uFFFC", "");
    }
  }

  ///font ref: https://coolsymbol.com/cool-fancy-text-generator.html
  ///name: `Small caps Font`
  static String numberToStyle(String number) {
    var _styles = ["𝟶", "𝟷", "𝟸", "𝟹", "𝟺", "𝟻", "𝟼", "𝟽", "𝟾", "𝟿"];
    var _numbers = ['0', "1", "2", "3", "4", "5", "6", "7", "8", "9"];

    for (int i = 0; i < _styles.length; i++) {
      number = number.replaceAll(_numbers[i], _styles[i]);
    }
    return number;
  }

  static int countOccurences(String str, String word) {
    // split the string by spaces in a
    List<String> a = str.split("");
    // search for pattern in a
    int count = 0;
    for (int i = 0; i < a.length; i++) {
      // if match found increase count
      if (word == a[i]) count++;
    }
    return count;
  }
}
