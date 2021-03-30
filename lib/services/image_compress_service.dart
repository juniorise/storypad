import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path;

class ImageCompressService {
  final File file;
  ImageCompressService({required this.file});

  Future<File?> exec() async {
    return await _getFileImage(this.file);
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<File?> _getFileImage(File file) async {
    // directory
    final dir = await path.getTemporaryDirectory();

    // image path
    final targetPath = dir.absolute.path + "/" + _timestamp() + ".jpg";
    final imgFile = await _compressAndGetFile(file, targetPath);

    return imgFile;
  }

  Future<File?> _compressAndGetFile(File file, String targetPath) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 600,
      minHeight: 600,
      quality: 50,
    );
    return result;
  }
}
