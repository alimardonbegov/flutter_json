import 'package:flutter_js/private/private_pb.dart';
import 'package:pocketbase/pocketbase.dart';
import '../runner.dart';

final pb = PocketBase("https://app.advanture.me");

void main() async {
  await pb.admins.authWithPassword(login, pass);
  runner();
}
