import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import './app/pdf_tpl.dart';

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
  List<ModularRoute> get routes => [ChildRoute('/', child: (context, args) => HomePage())];
}

class HomePage extends StatelessWidget {
  Widget build(BuildContext context) {
    Future<bool> getFont() async {
      final fontData = await rootBundle.load("assets/fonts/Inter.ttf");
      final ttf = pw.Font.ttf(fontData);

      //! JPR first page
      final Map<String, String> client = {
        //first page
        "maticni broj": "03523456",
        "company name": "COMPANY DOO",
        "drzava": "Crna Gora",
        "opstina": "Budva",
        "mjesto": "Sveti Stefat",
        "ulica i broj": "BB Slobode",
        "email": "email@gmail.com",
        "broj dodatka B": "1",
        "napomena": "Prijava lica ovlaštenog za elektronsko slanje podatka PU; izvršnog direktora",
        "JMB": "2402986223104",
        //second page
        "naziv organa": "Centralni registar privrednih subjekata",
        "datum registracije": "08  02  2023", // with two spaces between for now
        "broj regisrtarskog uloska": "5 - 1114596/001",
        "podaci o vlascenom licu - JMB": "0807984220007",
        "prezime": "Garkavyy",
        "ime": "Alexander",
        "adresa": "Bar, Dobra Voda, Marelica bb",
        //third page
        "prezime_2": "Podgornyi",
        "ime_2": "Aleksei",
        "datum rodeja": "12  03  1994", // with two spaces between for now
        "drzavljanstvo": "Rusko",
        "vrsta identif doc": "Dozvola za privremeni boravak i rad",
        "broj indet doc": "319098842",
        "izdat od": "FL Ulcinj",
        "osnov osiguranja": "Radni odnos",
        "datum doc": "20  03  2023", // with two spaces between for now
      };

      final JPRtemplate = JPRtpl(font: ttf, client: client);

      final pdf = pw.Document();

      final pageOne = JPRtemplate.createFirstPage();
      final pageTwo = JPRtemplate.createSecondPage();
      final pageThree = JPRtemplate.createThirdPage();

      pdf
        ..addPage(pageOne)
        ..addPage(pageTwo)
        ..addPage(pageThree);

      final generatedBytes = await pdf.save();
      final file = File("/Users/alimardon/Downloads/JPR_generated.pdf");
      file.writeAsBytesSync(generatedBytes);

      // ! 2
      print("file created");
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
            future: getFont(),
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
