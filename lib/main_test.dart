import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:http/http.dart' as http;

void main() async {
  runner();
}

void runner() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Oh noes! ${details.exception} ${details.stack}');
  };
  runZonedGuarded(
    () => runApp(ModularApp(module: AppModule(), child: AppWidget())),
    (error, stackTrace) => print('Oh noes! $error $stackTrace'),
  ); // старое, проверить
}

class AppWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Smart App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => HomePage()),
      ];
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future onPressed() async {
    final redirectUri = '????';

    final authorizationCode = '???';

    // final tokenEndpoint = oauth2.Oauth2ApitokenEndpoint.toString();

    // final requestBody = {
    //   'code': authorizationCode,
    //   'client_id': clientId,
    //   'client_secret': clientSecret,
    //   'redirect_uri': redirectUri,
    //   'grant_type': 'authorization_code',
    // };

    // final response = await http.post(Uri.parse(tokenEndpoint),
    //     headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: requestBody);

    // if (response.statusCode == 200) {
    //   final jsonResponse = jsonDecode(response.body);
    //   final accessToken = jsonResponse['access_token'];
    //   final expiresIn = jsonResponse['expires_in'];
    //   final tokenType = jsonResponse['token_type'];
    //   final refreshToken = jsonResponse['refresh_token'];

    //   // Use the access token to make requests to the API
    //   // ...
    // } else {
    //   throw Exception('Failed to exchange authorization code for access token.');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text("Json")),
        body: Row(
          children: <Widget>[
            ElevatedButton(onPressed: onPressed, child: Text("Sign in")),
          ],
        ),
      ),
    );
  }
}
