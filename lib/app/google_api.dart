import 'package:google_sign_in/google_sign_in.dart';
import '../private/google.dart';

class GoogleSignInApi {
  static final String _clientId = googleId;

  static final _googleSignIn = GoogleSignIn(clientId: _clientId);
  static Future login() => _googleSignIn.signIn();
}
