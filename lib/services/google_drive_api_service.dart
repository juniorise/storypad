import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:write_story/notifier/auth_notifier.dart';
import 'package:write_story/services/authentication_service.dart';
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
  static Future<String?> upload(io.File image, BuildContext context) async {
    /// if no user is logged in,
    /// then log in
    final auth = AuthenticationService();
    if (auth.user == null) {
      final success = await context.read(authenticationProvider).logAccount();
      if (success == false) return null;
    } else {
      final success = await auth.signInSilently();
      if (success == false) {
        await context.read(authenticationProvider).logAccount();
      }
    }

    /// read auth header from secure storage
    AuthHeaderStorage storage = AuthHeaderStorage();
    String? result = await storage.read();
    Map<String, String>? authHeader = storage.getAuthHeader(result!);
    GoogleAuthClient authenticateClient = GoogleAuthClient(authHeader!);

    drive.DriveApi driveApi = drive.DriveApi(authenticateClient);
    String? folderId;
    drive.FileList? folderList;

    /// try to get list of folder in google drive
    final mimeType = "mimeType = 'application/vnd.google-apps.folder'";
    folderList = await driveApi.files.list(q: "$mimeType");

    /// check if folder "Story" is existed or not,
    /// if no create new.
    folderList.files?.forEach((e) {
      if (e.name == "Story") folderId = e.id.toString();
    });

    if (folderId == null) {
      drive.File folderToCreate = drive.File();
      folderToCreate.name = "Story";
      drive.File response;
      try {
        response = await driveApi.files.create(
          folderToCreate..mimeType = "application/vnd.google-apps.folder",
        );
      } catch (e) {
        return null;
      }
      folderId = response.id;
    }

    var q = "mimeType='image/jpeg'";
    final fileList = await driveApi.files.list(q: q);
    final imagePath = basename(image.absolute.path);

    for (var e in fileList.files ?? []) {
      if ("${e.name}" == "$imagePath") {
        final link = 'https://drive.google.com/uc?export=download&id=${e.id}';
        return link;
      }
    }

    /// config file before upload
    drive.File fileToUpload = drive.File();
    fileToUpload.parents = [folderId.toString()];
    fileToUpload.name = basename(image.path);

    /// try create file
    drive.File response2;
    try {
      response2 = await driveApi.files.create(
        fileToUpload,
        uploadMedia: drive.Media(image.openRead(), image.lengthSync()),
      );
    } catch (e) {
      return null;
    }

    if (response2.id == null) return null;

    /// set image permission publish to display on app
    try {
      await driveApi.permissions.create(
        drive.Permission.fromJson({
          "role": "reader",
          "type": "anyone",
        }),
        response2.id!,
      );
    } catch (e) {
      return null;
    }

    /// delete compress image from local storage
    await image.delete();

    /// result
    final link =
        'https://drive.google.com/uc?export=download&id=${response2.id}';
    return link;
  }
}
