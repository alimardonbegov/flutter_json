import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import './google_drive.dart';
import './app/google_api.dart';

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
    await GoogleSignInApi.login();
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
