import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:tpl_docx/tpl_docx.dart';
import './data_source.dart';

enum TplName {
  jpr,
  izjava,
  pisanaPonudaPoslodavca,
  punomocBoravak,
  ugovorKnigovodstvo,
}

class Templater {
  final DataSource ds;
  final TplName tplName;
  final String companyId;

  const Templater._(this.ds, this.tplName, this.companyId);

  factory Templater({
    required TplName tplName,
    required DataSource ds,
    required String companyId,
  }) {
    switch (tplName) {
      case TplName.jpr: return JprTemplater(tplName: tplName, ds: ds, companyId: companyId);
      case TplName.izjava: return DocxTemplater(tplName: tplName, ds: ds, companyId: companyId);
      default: throw 'Erorr creating $tplName';
    }
  }

  Future<Map<String, String>> generateClientMap(String companyId) async => {"": ""};

  Future<List<int>> generateFile() async => [];

  Future<String> uploadFileToDB(String companyId, List<int> bytes) async {
    final Map<String, dynamic> companyData = await ds.getData(companyId, 'selectForTpl');
    final String userId = companyData["user_id"];

    final RecordModel record = await ds.sentDocToDB(bytes, userId, companyId, "docx");
    final String link = await ds.getDocLinkById(record.id, "documents");

    return link;
  }
}

/// docx templater for all docx file
class DocxTemplater extends Templater {
  final DataSource ds;
  final TplName tplName;
  final String companyId;

  DocxTemplater._({required this.ds, required this.tplName, required this.companyId}): super._(ds, tplName, companyId);

  factory DocxTemplater({
    required TplName tplName,
    required DataSource ds,
    required String companyId,
  }) {
    return DocxTemplater._(ds: ds, tplName: tplName, companyId: companyId);
  }

  late TplDocx _tpl;

  late Map<String, String> _mapForTpl; // final Map for tpl

  Future<Map<String, dynamic>> _createUserMap(Map<String, dynamic> companyData) async {
    final String userId = companyData["user_id"];
    final Map<String, dynamic> userData = await ds.getData(userId, "users");
    return userData["json"];
  }

  Map<String, String> _createCompanyMap(Map<String, dynamic> companyData) {
    return {
      "COMPANY_NAME": companyData["company_name"],
      "COMPANY_PIB": companyData["company_pib"],
      // добавить вручную новые строки для мэпы в тимплйэты
    };
  }

  Future<Map<String, String>> _createUserAndCompanyMap(companyId) async {
    final Map<String, dynamic> companyData = await ds.getData(companyId, 'selectForTpl');
    final Map<String, String> companyMap = _createCompanyMap(companyData);
    final Map<String, dynamic> userMap = await _createUserMap(companyData);
    return {...companyMap, ...userMap};
  }

  @override
  Future<Map<String, String>> generateClientMap(String companyId) async {
    final String fullTplPath = await ds.getDocLinkByName(tplName.toString(), 'templates');
    final List<int> bytes = await ds.getDocBytes(fullTplPath);
    _tpl = TplDocx(bytes);
    final List<String> fields = _tpl.mergedFields;
    final Map<String, String> userAndCompanyMap = await _createUserAndCompanyMap(companyId);
    final Map<String, String> mapFromField = Map.fromIterable(fields);
    _mapForTpl = {...mapFromField, ...userAndCompanyMap};
    return _mapForTpl;
  }

  @override
  Future<List<int>> generateFile() async {
    _tpl.writeMergedFields(_mapForTpl);
    return _tpl.getGeneratedBytes()!;
  }
}

/// pdf abstract templater for different pdf files (due to individual generator for each tpl page in pdf)
abstract class PdfTemplater extends Templater {
  PdfTemplater({required super.ds, required super.tplName, required super.companyId});

  final _pdf = pw.Document();
  late Map<String, String> _mapForTpl; // final Map for tpl

  Future<Font> _getFont() async {
    final fontData = await rootBundle.load("assets/fonts/Inter.ttf");
    return pw.Font.ttf(fontData);
  }

  Future<MemoryImage> _getAssetImage(String tplPath) async {
    final imageData = await rootBundle.load(tplPath);
    final imageBytes = Uint8List.view(imageData.buffer);
    return pw.MemoryImage(imageBytes);
  }

//! create map generator for PDF documents (for now it create a test Map)
  @override
  Future<Map<String, String>> generateClientMap(String companyId) async {
    _mapForTpl = {
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
      "prezime_2": "Podgornyi", // director
      "ime_2": "Aleksei", // director
      "datum rodeja": "12  03  1994", // with two spaces between for now
      "drzavljanstvo": "Rusko",
      "vrsta identif doc": "Dozvola za privremeni boravak i rad",
      "broj indet doc": "319098842",
      "izdat od": "FL Ulcinj",
      "osnov osiguranja": "Radni odnos",
      "datum doc": "20  03  2023", // with two spaces between for now
    };
    return _mapForTpl;
  }
}

class JprTemplater extends PdfTemplater {
  JprTemplater({required super.ds, required super.tplName, required super.companyId});

  Future<Page> _createFirstPage(Font font) async {
    final image = await _getAssetImage("assets/templates/{$tplName}/1.jpg");

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
                "${_mapForTpl["maticni broj"]}",
                style: pw.TextStyle(font: font, letterSpacing: 3.3),
              ), // 1.2 Maticni Broj / JMB
            ),
            pw.Positioned(
              top: 227,
              left: 139,
              child: pw.Text(
                "${_mapForTpl["company name"]}",
                style: pw.TextStyle(font: font),
              ), // 1.3 Puni Naziv / Prezime
            ),
            pw.Positioned(
              top: 301,
              left: 125,
              child: pw.Text(
                "${_mapForTpl["drzava"]}",
                style: pw.TextStyle(font: font),
              ), // 2.1 Drzava
            ),
            pw.Positioned(
              top: 313,
              left: 125,
              child: pw.Text(
                "${_mapForTpl["opstina"]}",
                style: pw.TextStyle(font: font),
              ), // 2.2 Opstina
            ),
            pw.Positioned(
              top: 326,
              left: 125,
              child: pw.Text(
                "${_mapForTpl["mjesto"]}",
                style: pw.TextStyle(font: font),
              ), // 2.3 Mjesto
            ),
            pw.Positioned(
              top: 339,
              left: 125,
              child: pw.Text(
                "${_mapForTpl["ulica i broj"]}",
                style: pw.TextStyle(font: font),
              ), // 2.4 Ulica i broj
            ),
            pw.Positioned(
              top: 362,
              left: 125,
              child: pw.Text(
                "${_mapForTpl["email"]}",
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
                "${_mapForTpl["broj dodatka B"]}",
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
                    "${_mapForTpl["napomena"]}",
                    style: pw.TextStyle(font: font),
                  ), // 4. Napomena
                )),
            pw.Positioned(
              top: 570,
              left: 67,
              child: pw.Text(
                "${_mapForTpl["JMB"]}",
                style: pw.TextStyle(font: font, letterSpacing: 3.9),
              ), // JMB
            ),
          ],
        )),
      ),
    );
  }

  Future<Page> _createSecondPage(Font font) async {
    final image = await _getAssetImage("assets/templates/JPR/2.jpg");
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
                "${_mapForTpl["naziv organa"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.1 Naziv organa
            pw.Positioned(
              top: 90,
              left: 108,
              child: pw.Text(
                "${_mapForTpl["datum registracije"]}",
                style: pw.TextStyle(font: font, fontSize: fz, letterSpacing: 4.8),
              ),
            ), // 1.2 Datum registracije
            pw.Positioned(
              top: 98,
              left: 108,
              child: pw.Text(
                "${_mapForTpl["broj regisrtarskog uloska"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.3 Broj regisrtarskog uloska
            pw.Positioned(
              top: 376,
              left: 20,
              child: pw.Text(
                "${_mapForTpl["podaci o vlascenom licu - JMB"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 5. Podaci o vlascenom licu - JMB
            pw.Positioned(
              top: 375.5,
              left: 118,
              child: pw.Text(
                "${_mapForTpl["prezime"]} ${_mapForTpl["ime"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 5. Podaci o vlascenom licu - Prezime i ime
            pw.Positioned(
              top: 375.5,
              left: 264,
              child: pw.Text(
                "${_mapForTpl["adresa"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 5. Podaci o vlascenom licu - Adresa
          ],
        )),
      ),
    );
  }

  Future<Page> _createThirdPage(Font font) async {
    final image = await _getAssetImage("assets/templates/JPR/3.jpg");
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
                "${_mapForTpl["JMB"]}",
                style: pw.TextStyle(font: font, fontSize: fz, letterSpacing: 4.3),
              ),
            ), // 1.1 JMB
            pw.Positioned(
              top: 87,
              left: 142,
              child: pw.Text(
                "${_mapForTpl["prezime_2"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.2 Prezime
            pw.Positioned(
              top: 87,
              left: 348,
              child: pw.Text(
                "${_mapForTpl["ime_2"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.3 Ime
            pw.Positioned(
              top: 114,
              left: 142,
              child: pw.Text(
                "${_mapForTpl["datum rodeja"]}",
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
                "${_mapForTpl["drzavljanstvo"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.11 Drzavljanstvo
            pw.Positioned(
                top: 191,
                left: 142,
                child: pw.SizedBox(
                  width: 110,
                  child: pw.Text(
                    "${_mapForTpl["vrsta identif doc"]}",
                    style: pw.TextStyle(font: font, fontSize: 8),
                  ),
                )), // 1.12 Vrsta identif documenta
            pw.Positioned(
              top: 194,
              left: 391,
              child: pw.Text(
                "${_mapForTpl["broj indet doc"]}",
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
            ), // 1.13 Broj indet documenta
            pw.Positioned(
              top: 209,
              left: 142,
              child: pw.Text(
                "${_mapForTpl["izdat od"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 1.14 Izdat od
            pw.Positioned(
              top: 582,
              left: 157,
              child: pw.Text(
                "${_mapForTpl["osnov osiguranja"]}",
                style: pw.TextStyle(font: font, fontSize: fz),
              ),
            ), // 4.2 Osnov osiguranja
            pw.Positioned(
              top: 616,
              left: 157,
              child: pw.Text(
                "${_mapForTpl["datum doc"]}",
                style: pw.TextStyle(font: font, fontSize: fz, letterSpacing: 4.5),
              ),
            ), // 4.5 Datum doc
          ],
        )),
      ),
    );
  }

  @override
  Future<List<int>> generateFile() async {
    final font = await _getFont();
    final pageOne = await _createFirstPage(font);
    final pageTwo = await _createSecondPage(font);
    final pageThree = await _createThirdPage(font);

    _pdf
      ..addPage(pageOne)
      ..addPage(pageTwo)
      ..addPage(pageThree);

    final bytes = await _pdf.save();
    return bytes;
  }
}
