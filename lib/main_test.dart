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
        ChildRoute('/', child: (context, args) => const HomePage()),
      ];
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text("Json")),
        body: Row(
          children: [
            SizedBox(
              height: double.infinity,
              width: 400,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.green,
                ),
                child: Column(
                  children: [const Text("blue")],
                ),
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Container(color: Colors.pink, child: Text("red")),
                    ),
                    const SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.orange),
                        child: Text("orange"),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
