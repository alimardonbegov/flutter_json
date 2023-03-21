// import 'dart:io';
// import 'dart:math';
// import 'package:docx_template/docx_template.dart';

// void main() {
//   Future<void> generateDocument() async {
//     final f = File("../assets/tpl.docx");
//     final docx = await DocxTemplate.fromBytes(await f.readAsBytes());

//     Content content = Content();
//     content
//       ..add(TextContent("clientFIO", "Begov Alimardon"))
//       ..add(TextContent("clientPassport", "9988 777666"))
//       ..add(TextContent("companyName", "Vanguard"))
//       ..add(TextContent("companyPIB", "00010010110"))
//       ..add(TextContent("date", "01.03.2023"));

//     int randomNumber = Random().nextInt(1000);

//     final docGenerated = await docx.generate(content);
//     final fileGenerated = File('generated$randomNumber.docx');
//     if (docGenerated != null) await fileGenerated.writeAsBytes(docGenerated);
//   }

//   generateDocument();
// }
