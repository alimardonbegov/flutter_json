import 'package:pocketbase/pocketbase.dart';
import '../runner.dart';

final pb = PocketBase("https://app.advanture.me");

const login = String.fromEnvironment('LOGIN');
const pass = String.fromEnvironment('PASS');

void main() async {
  // const login = String.fromEnvironment('LOGIN');
  // if (login.isEmpty) {
  //   throw AssertionError('TMDB_KEY is not set');
  // }
  // const pass = String.fromEnvironment('PASS');
  // if (pass.isEmpty) {
  //   throw AssertionError('TMDB_KEY is not set');
  // }

  await pb.admins.authWithPassword(login, pass);
  runner();
}
