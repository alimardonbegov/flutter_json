import 'package:flutter_js/app/data_source.dart';
import 'package:flutter_js/app/pdf_templaters.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:templater/templater.dart';

// create your own "pb_auth.json" file

// {
//   "LOGIN": "your_login@gmail.com",
//   "PASS": "your_password"
// }

// start this test with these VS Code with launch configuration:

// {
//     "version": "0.2.0",
//     "configurations": [
//         {
//             "name": "Test",
//             "request": "launch",
//             "type": "dart",
//             "program": "test/templater_test.dart",
//             "args": [
//                 "--dart-define-from-file",
//                 "pb_auth.json"
//               ]
//         }
//     ]
// }

void main() async {
  final pb = PocketBase('https://app.advanture.me');
  const login = String.fromEnvironment('LOGIN');
  const pass = String.fromEnvironment('PASS');
  final authData = await pb.admins.authWithPassword(login, pass);

  final ds = PocketBaseDataSource(pb, "");

  Future<void> createFile() async {
    const String docxTplId = "xwshzdift79mk6n"; // izjava
    const String docxTplIdTest = "7za2t8cwdpbxmb0"; // izjava with several pages in docx for test
    const String pdfTplId = "ro1w28rndyicb9j";
    const String companyId = "f6tt406qe0fu7q2";

    //! подумать над фабрикой (снизу видно одинаковый код)

    //! нужно добавить проверку форматов документов (docx / jpg для pdf) по id тимплейтера
    // в зависимости от формата файлов определить тип создаваемого шаблона:
    // - pdf в случае jpg формата файлов
    // - docx в случае docx формата файлов
    // если пдф, то нужно передать конкретный тип (например jpr) и страницы
    // не то же ли самое, что сделать вручную это и никая фабрика не нужна?

    //! Docx Templater test

    final pages = await ds.createListOfTplfPagesAsBytes(docxTplIdTest);

    final docxTpl = DocxTemplater(pages[0]);

    final mapForTpl = await ds.generateClientMap(docxTpl, companyId);
    final resultBytes = await docxTpl.generateBytes(mapForTpl);
    final record = await ds.sendFileToDB(resultBytes, companyId);
    final fileUrl = await ds.getFileUrlById(record.id, "documents");
    print("docx generated file url: $fileUrl");

    //! PDF Templater test

    final p = await ds.createListOfTplfPagesAsBytes(pdfTplId);

    final pdfTpl = JprPdfTemplate(p);

    final map = await ds.generateClientMap(pdfTpl, companyId);
    final bytes = await pdfTpl.generateBytes(map);
    final r = await ds.sendFileToDB(bytes, companyId);
    final url = await ds.getFileUrlById(r.id, "documents");
    print("pdf generated file url: $url");
  }

  await createFile();
  print("finish");
}
