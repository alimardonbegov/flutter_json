import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
// import 'package:flutter_modular/flutter_modular.dart';
import 'package:pocketbase/pocketbase.dart';
import './app/data_source.dart';
import './main.dart';
import './customers/screen.dart';

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
    // Modular.setInitialRoute('/page1');

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
  List<Bind> get binds => [
        Bind.factory<PocketBase>((i) => pb),
        Bind.singleton((i) => PocketBaseDataSource(i(), "assets/configs/config_user.json")),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => HomePage(), children: [
          ChildRoute('/page1', child: (context, args) => InternalPage(title: 'page 1')),
          ChildRoute('/page2', child: (context, args) => InternalPage(title: 'page 2')),
          ChildRoute('/page3', child: (context, args) => InternalPage(title: 'page 3'))
        ]),
      ];
}

class InternalPage extends StatelessWidget {
  final String title;

  const InternalPage({Key? key, required this.title}) : super(key: key);

  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}
