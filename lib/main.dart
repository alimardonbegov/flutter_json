import 'package:pocketbase/pocketbase.dart';
import '../runner.dart';

final pb = PocketBase("http://127.0.0.1:8090");

void main() async {
  
  await pb.admins.authWithPassword('alimardon007@gmail.com', '5544332211');
  runner();
}
