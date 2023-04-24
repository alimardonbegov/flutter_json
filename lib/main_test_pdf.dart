import 'dart:io';

import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;

void main() async {
  final tpl = File("/Users/alimardon/Desktop/projects/1. customers/lib/JPR_blank.pdf").readAsBytesSync();
  print(tpl);

  final ByteData data = await rootBundle.load('assets/templates/tpl.docx');
  // final Uint8List bytes = data.buffer.asUint8List();
  // final pdfDocument = PdfDocument.openData(bytes);

  // final document = pdfWidgets.Document();
  // for (var i = 0; i < pdfDocument.pagesCount; i++) {
  //   final page = pdfDocument.getPage(i + 1);
  //   final image = pdfWidgets.Image(pdfWidgets.MemoryImage(page.render()));
  //   document.addPage(pdfWidgets.Page(build: (context) => image));
  // }

  // // Render the PDF as a set of pages
  // final pdfBytes = await document.save();
  // // ...
}
