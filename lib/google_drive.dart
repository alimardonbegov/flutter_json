import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';

//! google auth 1 example
// ! desktop auth
// const CLIENT_ID = '659101320657-i4nsqieq0uri9rt5cj15csu79361i6q3.apps.googleusercontent.com';
// const CLIENT_SECRET = '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';

// ! web auth
const CLIENT_ID = '659101320657-bjbq62rfcjop0tdf547gunlo4tsadi3l.apps.googleusercontent.com';
const CLIENT_SECRET = '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';

const SCOPES = [drive.DriveApi.driveScope];

Future<void> googleAuth1() async {
  Future<void> prompt(String url) async {
    print('Please go to the following URL and grant access:');
    print('  => $url');
    print('');

    // Wait for the user to grant access
    final completer = Completer<void>();
    print("1");
    stdin.readLineSync();
    print("2");
    completer.complete();
    print("3");
    return completer.future;
  }

  Future<void> uploadFileOAuth(String filePath) async {
    final client = await auth.clientViaUserConsent(
      auth.ClientId(CLIENT_ID, CLIENT_SECRET),
      SCOPES,
      prompt,
    );

    final file = File(filePath);
    final driveFile = drive.File();
    driveFile.name = 'My File';
    final media = drive.Media(file.openRead(), file.lengthSync());
    final driveApi = drive.DriveApi(client);
  }

  uploadFileOAuth("/Users/alimardon/Desktop/customers/flutter_json/assets/templates/tpl.docx");
}

//! google auth 2 example

Future<void> googleAuth2() async {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: CLIENT_ID,
    scopes: SCOPES,
  );

  try {
    await _googleSignIn.signIn();
    print("signed id");
  } catch (error) {
    print(error);
  }
}
