import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_js/app/templater.dart';
import 'package:flutter_js/app/template_types.dart';
import 'package:flutter_js/private/private_pb.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pocketbase/pocketbase.dart';
import 'app/data_source.dart';
import 'main.dart';

void main() async {
  await pb.admins.authWithPassword(login, pass);
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
    // Modular.setInitialRoute('/');

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
  List<ModularRoute> get routes => [ChildRoute('/', child: (context, args) => HomePage())];
}

class HomePage extends StatelessWidget {
  final ds = Modular.get<DataSource>();

  Widget build(BuildContext context) {
    Future<bool> createFile() async {
      const String tplId = "xwshzdift79mk6n";
      const String companyId = "f6tt406qe0fu7q2";

      //! Templater test

      final String fullTplPath = await ds.getDocLinkById(tplId, 'templates');
      final List<int> docxBytes = await ds.getDocBytes(fullTplPath);

      final Template template = DocxTemplate(docxBytes);
      final Template templatePdf = JprPdfTemplate();

      final mapForTpl = await ds.generateClientMap(template, companyId);

      final tpl = Templater(template: template, mapForTpl: mapForTpl);
      final resultBytes = await tpl.generateFile();
      print(resultBytes);
      // final record = await ds.sentDocToDB(resultBytes, companyId);
      // final docLink = await ds.getDocLinkById(record.id, "documents");
      // print(docLink);

      return true;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Row(
        children: [
          FutureBuilder(
            future: createFile(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return Text("data");
              } else if (snapshot.hasError) {
                print("snapshot error: ${snapshot.error}");
                return const Text("Something went wrong");
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )
        ],
      ),
    );
  }
}
