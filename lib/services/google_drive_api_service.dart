import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:write_story/notifier/auth_notifier.dart';
import 'package:write_story/services/authentication_service.dart';
import 'package:write_story/services/image_compress_service.dart';
import 'package:write_story/storages/auth_header_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();
  GoogleAuthClient(this._headers);
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleDriveApiService {
  static Future<String?> upload(io.File _image, BuildContext context) async {
    final io.File? image = await ImageCompressService(file: _image).exec();
    AuthHeaderStorage storage = AuthHeaderStorage();

    final auth = AuthenticationService();
    if (auth.user == null) {
      final result = await context.read(authenticationProvider).logAccount();
      if (result == false) {
        return null;
      }
    }

    String? result = await storage.read();

    GoogleAuthClient authenticateClient = GoogleAuthClient(
      storage.getAuthHeader(result!)!,
    );
    drive.DriveApi driveApi = drive.DriveApi(authenticateClient);

    String? folderId;

    drive.FileList? folderList;

    try {
      folderList = await driveApi.files
          .list(q: "mimeType = 'application/vnd.google-apps.folder'");
    } catch (e) {
      final bool success = await auth.signInSilently();
      if (success) {
        result = await storage.read();
      } else {
        final success = await context.read(authenticationProvider).logAccount();
        if (!success) return null;
      }

      authenticateClient = GoogleAuthClient(
        storage.getAuthHeader(result!)!,
      );
      driveApi = drive.DriveApi(authenticateClient);
      try {
        folderList = await driveApi.files
            .list(q: "mimeType = 'application/vnd.google-apps.folder'");
      } catch (e) {
        return null;
      }
    }

    folderList.files?.forEach((e) {
      if (e.name == "Story") folderId = e.id.toString();
    });

    if (folderId == null) {
      drive.File folderToCreate = drive.File();
      folderToCreate.name = "Story";

      final response = await driveApi.files.create(
        folderToCreate..mimeType = "application/vnd.google-apps.folder",
      );
      folderId = response.id;
    }

    drive.File fileToUpload = drive.File();
    fileToUpload.parents = [folderId.toString()];
    fileToUpload.name = basename(image!.path);

    var response2 = await driveApi.files.create(
      fileToUpload,
      uploadMedia: drive.Media(image.openRead(), image.lengthSync()),
    );

    await driveApi.permissions.create(
      drive.Permission.fromJson({
        "role": "reader",
        "type": "anyone",
      }),
      response2.id!,
    );

    await image.delete();
    final link =
        'https://drive.google.com/uc?export=download&id=${response2.id}';
    return link;
  }
}
