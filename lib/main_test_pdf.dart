import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/app/tpl_factory.dart';
import 'package:flutter_js/private/private_pb.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pocketbase/pocketbase.dart';
import './app/pdf_tpl.dart';
import 'app/data_source.dart';
import 'app/docx_tpl.dart';
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
      // final String tplId = "xwshzdift79mk6n";
      // final Map<String, String> client = {
      //   //first page
      //   "maticni broj": "03523456",
      //   "company name": "COMPANY DOO",
      //   "drzava": "Crna Gora",
      //   "opstina": "Budva",
      //   "mjesto": "Sveti Stefat",
      //   "ulica i broj": "BB Slobode",
      //   "email": "email@gmail.com",
      //   "broj dodatka B": "1",
      //   "napomena": "Prijava lica ovlaštenog za elektronsko slanje podatka PU; izvršnog direktora",
      //   "JMB": "2402986223104",
      //   //second page
      //   "naziv organa": "Centralni registar privrednih subjekata",
      //   "datum registracije": "08  02  2023", // with two spaces between for now
      //   "broj regisrtarskog uloska": "5 - 1114596/001",
      //   "podaci o vlascenom licu - JMB": "0807984220007",
      //   "prezime": "Garkavyy",
      //   "ime": "Alexander",
      //   "adresa": "Bar, Dobra Voda, Marelica bb",
      //   //third page
      //   "prezime_2": "Podgornyi", // director
      //   "ime_2": "Aleksei", // director
      //   "datum rodeja": "12  03  1994", // with two spaces between for now
      //   "drzavljanstvo": "Rusko",
      //   "vrsta identif doc": "Dozvola za privremeni boravak i rad",
      //   "broj indet doc": "319098842",
      //   "izdat od": "FL Ulcinj",
      //   "osnov osiguranja": "Radni odnos",
      //   "datum doc": "20  03  2023", // with two spaces between for now
      // };

      final String companyId = "f6tt406qe0fu7q2";

      //! factory
      final tpl = TplFactory(name: TplName.jpr, ds: ds, companyId: companyId);

      // print(TplName.jpr.toString().split('.').last);
      //! PDF

      // final jpr = JPRtpl(ds: ds, clientMap: client);
      // final bytes = await jpr.generateFile();
      // final linkToPdf = await jpr.uploadFileToDB(companyId, bytes);
      // print(linkToPdf);

      // final file = File("/Users/alimardon/Downloads/JPR_generated.pdf");
      // file.writeAsBytesSync(bytes);

      // !DOCX
      // final templater = DocxTemplater(ds);
      // final List<int> bytesDocx = await templater.generateDoc(tplId, companyId);
      // final String linkToDocx = await templater.uploadDocToDB(companyId, bytesDocx);
      // print(linkToDocx);

      // print("file created");
      return true;
    }

    // load image from assets (error)
    // final imgSrc = await rootBundle.load('/assets/templates/JPR/1.jpg');
    // final imgUtf8 = imgSrc.buffer.asUint8List();
    // final image = pw.MemoryImage(imgUtf8);

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
