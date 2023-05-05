import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:templater/templater.dart';

import 'package:http/http.dart' as http;

class JprPdfTemplate extends PdfTemplater {
  final List<List<int>> pagesAsBytes;

  JprPdfTemplate(this.pagesAsBytes);

  /// get pdf page as image from asset
  // Future<MemoryImage> _getImage(String tplPath) async {
  //   final imageData = await rootBundle.load(tplPath);
  //   final imageBytes = Uint8List.view(imageData.buffer);
  //   return pw.MemoryImage(imageBytes);
  // }

  Future<Page> _createFirstPage(Font font, Map<String, String> mapForTpl) async {
    // final image = await _getImage("assets/templates/jpr/1.jpg");

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          image: pw.DecorationImage(
            image: pw.MemoryImage(Uint8List.fromList(pagesAsBytes[2])),
            fit: pw.BoxFit.cover,
          ),
        ),
        child: pw.Container(
            child: pw.Stack(
          children: <pw.Widget>[
            pw.Positioned(
              top: 115,
              left: 280,
              child: pw.Text(
                "x",
                style: pw.TextStyle(font: font),
              ),
            ), // tip documentd
            pw.Positioned(
              top: 184,
              left: 139,
              child: pw.Text(
                "x",
                style: pw.TextStyle(font: font),
              ), // 1.1 Tip lica (Pravno lice)
            ),
            pw.Positioned(
              top: 206,
              left: 139,
              child: pw.Text(
                "${mapForTpl["maticni broj"]}",
                style: pw.TextStyle(font: font, letterSpacing: 3.3),
              ), // 1.2 Maticni Broj / JMB
            ),
            pw.Positioned(
              top: 227,
              left: 139,
              child: pw.Text(
                "${mapForTpl["company name"]}",
                style: pw.TextStyle(font: font),
              ), // 1.3 Puni Naziv / Prezime
            ),
            pw.Positioned(
              top: 301,
              left: 125,
              child: pw.Text(
                "${mapForTpl["drzava"]}",
                style: pw.TextStyle(font: font),
              ), // 2.1 Drzava
            ),
            pw.Positioned(
              top: 313,
              left: 125,
              child: pw.Text(
                "${mapForTpl["opstina"]}",
                style: pw.TextStyle(font: font),
              ), // 2.2 Opstina
            ),
            pw.Positioned(
              top: 326,
              left: 125,
              child: pw.Text(
                "${mapForTpl["mjesto"]}",
                style: pw.TextStyle(font: font),
              ), // 2.3 Mjesto
            ),
            pw.Positioned(
              top: 339,
              left: 125,
              child: pw.Text(
                "${mapForTpl["ulica i broj"]}",
                style: pw.TextStyle(font: font),
              ), // 2.4 Ulica i broj
            ),
            pw.Positioned(
              top: 362,
              left: 125,
              child: pw.Text(
                "${mapForTpl["email"]}",
                style: pw.TextStyle(font: font),
              ), // 2.6 e-mail
            ),
            pw.Positioned(
              top: 398,
              left: 30,
              child: pw.Text(
                "x",
                style: pw.TextStyle(font: font),
              ), // 3.1 Dodatak A
            ),
            pw.Positioned(
              top: 423,
              left: 30,
              child: pw.Text(
                "x",
                style: pw.TextStyle(font: font),
              ), // 3.2 Dodatak B
            ),
            pw.Positioned(
              top: 436,
              left: 156,
              child: pw.Text(
                "${mapForTpl["broj dodatka B"]}",
                style: pw.TextStyle(font: font),
              ), // 3.2.1 Broj dodatka B
            ),
            pw.Positioned(
              top: 458,
              left: 30,
              child: pw.Text(
                "x",
                style: pw.TextStyle(font: font),
              ), // 3.3 Dadatak C
            ),
            pw.Positioned(
                top: 498,
                left: 26,
                child: pw.SizedBox(
                  width: 400,
                  child: pw.Text(
                    "${mapForTpl["napomena"]}",
                    style: pw.TextStyle(font: font),
                  ), // 4. Napomena
                )),
            pw.Positioned(
              top: 570,
              left: 67,
              child: pw.Text(
                "${mapForTpl["JMB"]}",
                style: pw.TextStyle(font: font, letterSpacing: 3.9),
              ), // JMB
            ),
          ],
        )),
      ),
    );
  }

  Future<Page> _createSecondPage(Font font, Map<String, String> mapForTpl) async {
    // final image = await _getImage("assets/templates/jpr/2.jpg");
    const double fz = 8;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          image: pw.DecorationImage(
            image: pw.MemoryImage(Uint8List.fromList(pagesAsBytes[1])),
            fit: pw.BoxFit.cover,
          ),
        ),
        child: pw.Container(
            child: pw.Stack(
          children: <pw.Widget>[
            pw.Positioned(
              top: 81,
              left: 108,
              child: pw.Text(
                "${mapForTpl["naziv organa"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.1 Naziv organa
            pw.Positioned(
              top: 90,
              left: 108,
              child: pw.Text(
                "${mapForTpl["datum registracije"]}",
                style: pw.TextStyle(font: font, fontSize: fz, letterSpacing: 4.8),
              ),
            ), // 1.2 Datum registracije
            pw.Positioned(
              top: 98,
              left: 108,
              child: pw.Text(
                "${mapForTpl["broj regisrtarskog uloska"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.3 Broj regisrtarskog uloska
            pw.Positioned(
              top: 376,
              left: 20,
              child: pw.Text(
                "${mapForTpl["podaci o vlascenom licu - JMB"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 5. Podaci o vlascenom licu - JMB
            pw.Positioned(
              top: 375.5,
              left: 118,
              child: pw.Text(
                "${mapForTpl["prezime"]} ${mapForTpl["ime"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 5. Podaci o vlascenom licu - Prezime i ime
            pw.Positioned(
              top: 375.5,
              left: 264,
              child: pw.Text(
                "${mapForTpl["adresa"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 5. Podaci o vlascenom licu - Adresa
          ],
        )),
      ),
    );
  }

  Future<Page> _createThirdPage(Font font, Map<String, String> mapForTpl) async {
    // final image = await _getImage("assets/templates/jpr/3.jpg");
    const double fz = 11;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          image: pw.DecorationImage(
            image: pw.MemoryImage(Uint8List.fromList(pagesAsBytes[0])),
            fit: pw.BoxFit.cover,
          ),
        ),
        child: pw.Container(
            child: pw.Stack(
          children: <pw.Widget>[
            pw.Positioned(
              top: 76,
              left: 142,
              child: pw.Text(
                "${mapForTpl["JMB"]}",
                style: pw.TextStyle(font: font, fontSize: fz, letterSpacing: 4.3),
              ),
            ), // 1.1 JMB
            pw.Positioned(
              top: 87,
              left: 142,
              child: pw.Text(
                "${mapForTpl["prezime_2"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.2 Prezime
            pw.Positioned(
              top: 87,
              left: 348,
              child: pw.Text(
                "${mapForTpl["ime_2"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.3 Ime
            pw.Positioned(
              top: 114,
              left: 142,
              child: pw.Text(
                "${mapForTpl["datum rodeja"]}",
                style: pw.TextStyle(font: font, fontSize: fz, letterSpacing: 5),
              ),
            ), // 1.6. Datum rodeja
            pw.Positioned(
              top: 164,
              left: 142,
              child: pw.Text(
                "X", // !add check male or female (using bool value and if else construction)
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.10 Pol
            pw.Positioned(
              top: 178,
              left: 142,
              child: pw.Text(
                "${mapForTpl["drzavljanstvo"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.11 Drzavljanstvo
            pw.Positioned(
                top: 191,
                left: 142,
                child: pw.SizedBox(
                  width: 110,
                  child: pw.Text(
                    "${mapForTpl["vrsta identif doc"]}",
                    style: pw.TextStyle(font: font, fontSize: 8),
                  ),
                )), // 1.12 Vrsta identif documenta
            pw.Positioned(
              top: 194,
              left: 391,
              child: pw.Text(
                "${mapForTpl["broj indet doc"]}",
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
            ), // 1.13 Broj indet documenta
            pw.Positioned(
              top: 209,
              left: 142,
              child: pw.Text(
                "${mapForTpl["izdat od"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.14 Izdat od
            pw.Positioned(
              top: 582,
              left: 157,
              child: pw.Text(
                "${mapForTpl["osnov osiguranja"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 4.2 Osnov osiguranja
            pw.Positioned(
              top: 616,
              left: 157,
              child: pw.Text(
                "${mapForTpl["datum doc"]}",
                style: pw.TextStyle(font: font, fontSize: fz, letterSpacing: 4.5),
              ),
            ), // 4.5 Datum doc
          ],
        )),
      ),
    );
  }

  /// get the Font for the inserted text
  Future<Font> _getFont() async {
    //! убрал для теста вне flutter'a
    // final fontData = await rootBundle.load("assets/fonts/Inter.ttf");
    // return pw.Font.ttf(fontData);

    //! добавил для теста вне flutter'a
    final Client client = Client();
    final Response response = await client
        .get(Uri.parse("https://raw.githubusercontent.com/alimardonbegov/flutter_json/main/assets/fonts/Inter.ttf"));

    final bytes = response.bodyBytes;
    return pw.Font.ttf(ByteData.view(bytes.buffer));
  }

  @override
  Future<List<int>> generateBytes(Map<String, String> mapForTpl) async {
    /// an empty pdf document in which the generated pages are saved
    final pdf = pw.Document();

    final font = await _getFont();
    final pageOne = await _createFirstPage(font, mapForTpl);
    final pageTwo = await _createSecondPage(font, mapForTpl);
    final pageThree = await _createThirdPage(font, mapForTpl);

    pdf
      ..addPage(pageOne)
      ..addPage(pageTwo)
      ..addPage(pageThree);

    final bytes = await pdf.save();
    return bytes;
  }
}
