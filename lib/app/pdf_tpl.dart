import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class JPRtpl {
  final Font font;
  final Map<String, String> client;

  JPRtpl({required this.font, required this.client});

  createFirstPage() {
    final image =
        pw.MemoryImage(File("/Users/alimardon/Downloads/1.jpg").readAsBytesSync()); // delete after assets loading
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          image: pw.DecorationImage(
            image: image,
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
                "${client["maticni broj"]}",
                style: pw.TextStyle(font: font, letterSpacing: 3.3),
              ), // 1.2 Maticni Broj / JMB
            ),
            pw.Positioned(
              top: 227,
              left: 139,
              child: pw.Text(
                "${client["company name"]}",
                style: pw.TextStyle(font: font),
              ), // 1.3 Puni Naziv / Prezime
            ),
            pw.Positioned(
              top: 301,
              left: 125,
              child: pw.Text(
                "${client["drzava"]}",
                style: pw.TextStyle(font: font),
              ), // 2.1 Drzava
            ),
            pw.Positioned(
              top: 313,
              left: 125,
              child: pw.Text(
                "${client["opstina"]}",
                style: pw.TextStyle(font: font),
              ), // 2.2 Opstina
            ),
            pw.Positioned(
              top: 326,
              left: 125,
              child: pw.Text(
                "${client["mjesto"]}",
                style: pw.TextStyle(font: font),
              ), // 2.3 Mjesto
            ),
            pw.Positioned(
              top: 339,
              left: 125,
              child: pw.Text(
                "${client["ulica i broj"]}",
                style: pw.TextStyle(font: font),
              ), // 2.4 Ulica i broj
            ),
            pw.Positioned(
              top: 362,
              left: 125,
              child: pw.Text(
                "${client["email"]}",
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
                "${client["broj dodatka B"]}",
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
                    "${client["napomena"]}",
                    style: pw.TextStyle(font: font),
                  ), // 4. Napomena
                )),
            pw.Positioned(
              top: 570,
              left: 67,
              child: pw.Text(
                "${client["JMB"]}",
                style: pw.TextStyle(font: font, letterSpacing: 3.9),
              ), // JMB
            ),
          ],
        )),
      ),
    );
  }

  createSecondPage() {
    final image =
        pw.MemoryImage(File("/Users/alimardon/Downloads/2.jpg").readAsBytesSync()); // delete after assets loading
    const double fz = 8;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          image: pw.DecorationImage(
            image: image,
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
                "${client["naziv organa"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.1 Naziv organa
            pw.Positioned(
              top: 90,
              left: 108,
              child: pw.Text(
                "${client["datum registracije"]}",
                style: pw.TextStyle(font: font, fontSize: fz, letterSpacing: 4.8),
              ),
            ), // 1.2 Datum registracije
            pw.Positioned(
              top: 98,
              left: 108,
              child: pw.Text(
                "${client["broj regisrtarskog uloska"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.3 Broj regisrtarskog uloska
            pw.Positioned(
              top: 376,
              left: 20,
              child: pw.Text(
                "${client["podaci o vlascenom licu - JMB"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 5. Podaci o vlascenom licu - JMB
            pw.Positioned(
              top: 375.5,
              left: 118,
              child: pw.Text(
                "${client["prezime"]} ${client["ime"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 5. Podaci o vlascenom licu - Prezime i ime
            pw.Positioned(
              top: 375.5,
              left: 264,
              child: pw.Text(
                "${client["adresa"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 5. Podaci o vlascenom licu - Adresa
          ],
        )),
      ),
    );
  }

  createThirdPage() {
    final image =
        pw.MemoryImage(File("/Users/alimardon/Downloads/3.jpg").readAsBytesSync()); // delete after assets loading
    const double fz = 11;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          image: pw.DecorationImage(
            image: image,
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
                "${client["JMB"]}",
                style: pw.TextStyle(font: font, fontSize: fz, letterSpacing: 4.3),
              ),
            ), // 1.1 JMB
            pw.Positioned(
              top: 87,
              left: 142,
              child: pw.Text(
                "${client["prezime_2"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.2 Prezime
            pw.Positioned(
              top: 87,
              left: 348,
              child: pw.Text(
                "${client["ime_2"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.3 Ime
            pw.Positioned(
              top: 114,
              left: 142,
              child: pw.Text(
                "${client["datum rodeja"]}",
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
                "${client["drzavljanstvo"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.11 Drzavljanstvo
            pw.Positioned(
                top: 191,
                left: 142,
                child: pw.SizedBox(
                  width: 110,
                  child: pw.Text(
                    "${client["vrsta identif doc"]}",
                    style: pw.TextStyle(font: font, fontSize: 8),
                  ),
                )), // 1.12 Vrsta identif documenta
            pw.Positioned(
              top: 194,
              left: 391,
              child: pw.Text(
                "${client["broj indet doc"]}",
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
            ), // 1.13 Broj indet documenta
            pw.Positioned(
              top: 209,
              left: 142,
              child: pw.Text(
                "${client["izdat od"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.14 Izdat od
            pw.Positioned(
              top: 582,
              left: 157,
              child: pw.Text(
                "${client["osnov osiguranja"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 4.2 Osnov osiguranja
            pw.Positioned(
              top: 616,
              left: 157,
              child: pw.Text(
                "${client["datum doc"]}",
                style: pw.TextStyle(font: font, fontSize: fz, letterSpacing: 4.5),
              ),
            ), // 4.5 Datum doc
          ],
        )),
      ),
    );
  }
}
