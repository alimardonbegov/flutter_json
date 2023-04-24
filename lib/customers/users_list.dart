import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// import 'package:pdf_google_fonts/pdf_google_fonts.dart';

import '../app/data_source.dart';
import '../app/pdf_tpl.dart';
import '../app/templater.dart';
import './data/user_data_cubit.dart';

/// left part of the screen - rendering list of users

class UsersListWidget extends StatelessWidget {
  final ds = Modular.get<DataSource>();

  Future<bool> getUsers() async {
    await ds.getInitData("selectInit");

    //! PDF templater 1

    final pdf = pw.Document();

    //load image from assets (error)
    // final imgSrc = await rootBundle.load('/assets/templates/JPR/1.jpg');
    // final imgUtf8 = imgSrc.buffer.asUint8List();
    // final image = pw.MemoryImage(imgUtf8);

    final image =
        pw.MemoryImage(File("/Users/alimardon/Downloads/1.jpg").readAsBytesSync()); // delete after assets loading
    final fontData = await rootBundle.load("assets/fonts/Inter.ttf");
    final ttf = pw.Font.ttf(fontData);

    //! JPR first page

    final pages = JPR();
    final firstPage = pages.createFirstPage(image, ttf);

    pdf.addPage(firstPage);

    final generatedBytes = await pdf.save();
    final file = File("/Users/alimardon/Downloads/pdf.pdf");
    file.writeAsBytesSync(generatedBytes);

    // ! 2

    // ! TEMPLATOR for docx

    // final templater = Templater(ds);

    // String tplId = "xwshzdift79mk6n";
    // String tplPath = "assets/templates/tpl.docx";
    // String companyId = "f6tt406qe0fu7q2";

    // final templater = Templater(ds);

    // final List<int> bytes = await templater.generateDoc(tplId, companyId);
    // final String linkToDoc = await templater.uploadDocToDB(companyId, bytes);

    // print(linkToDoc);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final ds = Modular.get<DataSource>();
    final cubit = BlocProvider.of<ChosenUserCubit>(context);

    return FutureBuilder(
      future: getUsers(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: ds.usersList.length,
            itemBuilder: (context, index) {
              var item = ds.usersList[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(item.getStringValue("username")),
                subtitle: Text(item.getStringValue("company")),
                onTap: () => cubit.choseUser(item.id),
              );
            },
          );
        } else if (snapshot.hasError) {
          print("snapshot error: ${snapshot.error}");
          return const Text("Something went wrong");
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class PdfDocParser extends PdfDocumentParserBase {
  PdfDocParser(super.bytes);

  @override
  void mergeDocument(PdfDocument pdfDocument) {}

  @override
  int get size => bytes.length;

  @override
  // TODO: implement xrefOffset
  int get xrefOffset => throw UnimplementedError();
}
