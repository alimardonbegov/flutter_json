import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class JPR {
  createFirstPage(image, ttf) {
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
              top: 300,
              left: 750 / 16,
              child: pw.Text(
                "x",
                style: pw.TextStyle(font: ttf),
              ),
            ), // tip documentd
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "x",
                style: pw.TextStyle(font: ttf),
              ), // 1.1 Tip lica
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "0353353",
                style: pw.TextStyle(font: ttf),
              ), // 1.2 Maticni Broj / JMB
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "COMPANYNAME DOO",
                style: pw.TextStyle(font: ttf),
              ), // 1.3 Puni Naziv / Prezime
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "",
                style: pw.TextStyle(font: ttf),
              ), // 1.4 Scraceni naziv / Ime
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "Crna Gora",
                style: pw.TextStyle(font: ttf),
              ), // 2.1 Drzava
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "Budva",
                style: pw.TextStyle(font: ttf),
              ), // 2.2 Opstina
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "Sveti Stefat",
                style: pw.TextStyle(font: ttf),
              ), // 2.3 Mjesto
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "BB Slobode",
                style: pw.TextStyle(font: ttf),
              ), // 2.4 Ulica i broj
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "",
                style: pw.TextStyle(font: ttf),
              ), // 2.5 Broj telefona / fax
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "email@gmail.com",
                style: pw.TextStyle(font: ttf),
              ), // 2.6 e-mail
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "x",
                style: pw.TextStyle(font: ttf),
              ), // 3.1 Dodatak A
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "x",
                style: pw.TextStyle(font: ttf),
              ), // 3.2 Dodatak B
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "1",
                style: pw.TextStyle(font: ttf),
              ), // 3.2.1 Broj dodatka B
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "",
                style: pw.TextStyle(font: ttf),
              ), // 3.3 Dadatak C
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "Texttext text text text text text text text text text text text",
                style: pw.TextStyle(font: ttf),
              ), // 4. Napomena
            ),
            pw.Positioned(
              top: 10,
              right: 10,
              child: pw.Text(
                "0101010101010",
                style: pw.TextStyle(font: ttf),
              ), // JMB
            ),
          ],
        )),
      ),
    );
  }
}
