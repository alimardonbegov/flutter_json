import 'package:flutter_js/private/pb_auth.json';
import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://app.advanture.me');

  const login = String.fromEnvironment('LOGIN');
  const pass = String.fromEnvironment('PASS');
  final authData = await pb.admins.authWithPassword(login, pass);

  Future<void> createRecord(int number) async {
    final body = <String, dynamic>{
      "username": "${number.toString()}a",
      "email": "$number@gmail.com",
      "emailVisibility": true,
      "password": "12345678",
      "passwordConfirm": "12345678",
      "json": {
        "CLIENT_FIO_UC": "",
        "father_name": "",
        "country": "",
        "city": "",
        "CLIENT_PASSPORT": "9988 776655",
        "phone number": "+999 999 999 99 99 ",
        "gender": "",
        "date of birth": "66 00 ",
        "address": "",
        "Telegram username": "",
        "WhatsApp number": "",
        "email": "@gmail.com",
        "Viber number": ""
      }
    };
    final record = await pb.collection('users').create(body: body);
    print("$number done");
  }

  for (int i = 333; i < 340; i++) {
    createRecord(i);
  }
}
