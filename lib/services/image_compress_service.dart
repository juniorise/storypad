import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path;

class ImageCompressService {
  final File file;
  final String? name;
  final bool compress;
  ImageCompressService({
    required this.file,
    this.name,
    this.compress = true,
  });

  Future<File?> exec() async {
    return await _getFileImage(this.file);
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<File?> _getFileImage(File file) async {
    // directory
    final dir = await path.getTemporaryDirectory();

    // image path
    final targetPath =
        dir.absolute.path + "/" + (this.name ?? _timestamp()) + ".jpg";

    if (this.compress) {
      return await _compressAndGetFile(file, targetPath);
    } else {
      return await file.copy(targetPath);
    }
  }

  Future<File?> _compressAndGetFile(File file, String targetPath) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 600,
      minHeight: 600,
      quality: 50,
    );

    final length = await result?.length();

    final image = await result?.copy(result.parent.path + "/" + "$length.jpg");
    await result?.delete();
    return image;
  }
}
