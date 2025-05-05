import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class GoogleDriveService {
  final _scopes = [drive.DriveApi.driveFileScope];

  Future<String> uploadPdfToGoogleDrive(File pdfFile) async {
    // Load the service account JSON file from assets
    final credentialsJson = await rootBundle.loadString('assets/service_account.json');
    final credentials = ServiceAccountCredentials.fromJson(json.decode(credentialsJson));

    // Authenticate and create a Drive API client
    final authClient = await clientViaServiceAccount(
      credentials,
      _scopes,
    );

    final driveApi = drive.DriveApi(authClient);

    // Create a new file on Google Drive
    final driveFile = drive.File();
    driveFile.name = 'message_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final media = drive.Media(pdfFile.openRead(), pdfFile.lengthSync());
    final uploadedFile = await driveApi.files.create(
      driveFile,
      uploadMedia: media,
    );

    // Make the file public
    await driveApi.permissions.create(
      drive.Permission()
        ..type = 'anyone'
        ..role = 'reader',
      uploadedFile.id!,
    );

    // Return the public URL
    return 'https://drive.google.com/uc?id=${uploadedFile.id}&export=download';
  }
}