import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:templater/templater.dart';
import './main.dart';
import './app/data_source.dart';
import './app/pdf_templaters.dart';

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
      const String docxTplId = "xwshzdift79mk6n"; // izjava
      const String docxTplIdTest = "7za2t8cwdpbxmb0"; // izjava with several pages in docx for test
      const String pdfTplId = "ro1w28rndyicb9j";
      const String companyId = "f6tt406qe0fu7q2";

      late Templater tpl; //! Templater test for PdfTemplater

      //! нужно добавить проверку форматов документов (docx / jpg для pdf) по id тимплейтера

      // получить массив страниц по id тимплейтера
      // print(1);
      final pages = await ds.createListOfTplfPagesAsBytes(pdfTplId);
      // print(2);

      // в зависимости от формата файлов определить тип создаваемого шаблона:
      // - pdf в случае jpg формата файлов
      // - docx в случае docx формата файлов
      // если пдф, то нужно передать конкретный тип (например jpr) и страницы
      // не то же ли самое, что сделать вручную это и никая фабрика не нужна?

      tpl = JprPdfTemplate(pages);
      final mapForTpl = await ds.generateClientMap(tpl, companyId);
      final resultBytes = await tpl.generateBytes(mapForTpl);

      final record = await ds.sendFileToDB(resultBytes, companyId);
      final fileUrl = await ds.getFileUrlById(record.id, "documents");
      print(fileUrl);

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
