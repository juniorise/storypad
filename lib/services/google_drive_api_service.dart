import 'dart:io' as io;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:storypad/services/authentication_service.dart';
import 'package:storypad/storages/auth_header_storage.dart';
import 'package:storypad/storages/story_folder_storage.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();
  GoogleAuthClient(this._headers);
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleDriveApiService {
  static Future<void> setAuthHeader() async {
    /// if no user is logged in,
    /// then log in
    final auth = AuthenticationService();
    if (auth.user == null) {
      final success = await auth.signInWithGoogle();
      if (success == false) return null;
    } else {
      final success = await auth.signInSilently();
      if (success == false) {
        await auth.signInWithGoogle();
      }
    }
  }

  static Future<String?> getStoryFolderId() async {
    final StoryFolderStorage storage = StoryFolderStorage();
    final String? id = await storage.read();
    if (id != null) {
      return id;
    } else {
      drive.DriveApi driveApi = await getDriveApi();
      await setFolderId(driveApi);
      return await storage.read();
    }
  }

  static Future<drive.DriveApi> getDriveApi() async {
    await setAuthHeader();

    /// read auth header from secure storage
    AuthHeaderStorage storage = AuthHeaderStorage();
    String? result = await storage.read();
    Map<String, String>? authHeader = storage.getAuthHeader(result!);
    GoogleAuthClient authenticateClient = GoogleAuthClient(authHeader!);
    return drive.DriveApi(authenticateClient);
  }

  static Future<void> setFolderId(drive.DriveApi driveApi, {bool grentPermission = true}) async {
    String? folderId;
    drive.FileList? folderList;

    /// try to get list of folder in google drive
    final mimeType = "mimeType = 'application/vnd.google-apps.folder'";
    folderList = await driveApi.files.list(q: "$mimeType");

    final folderStorage = StoryFolderStorage();

    /// check if folder "Story" is existed or not,
    /// if no create new.
    folderList.files?.forEach((e) {
      if (e.name == "Story") folderId = e.id.toString();
    });

    if (folderId == null) {
      /// set folder permission to publish to display on app
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

    if (grentPermission) {
      try {
        await driveApi.permissions.create(
          drive.Permission.fromJson({"role": "reader", "type": "anyone"}),
          folderId!,
        );
      } catch (e) {}
    }
    await folderStorage.write(folderId ?? "");
  }

  static Future<String?> upload(io.File image) async {
    drive.DriveApi driveApi = await getDriveApi();

    try {
      await setFolderId(driveApi);
    } catch (e) {
      return null;
    }

    final folderStorage = StoryFolderStorage();
    final String? folderId = await folderStorage.read();

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

    /// delete compress image from local storage
    await image.delete();

    /// result
    final link = 'https://drive.google.com/uc?export=download&id=${response2.id}';
    return link;
  }
}
