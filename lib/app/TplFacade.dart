import 'dart:convert';
import 'dart:io';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import './TplGenerator.dart';
import './DataSource.dart';

class TplFacade {
  final PocketBase pb;
  TplFacade(this.pb);

  generateDocumentFromRemoteTpl(
    String tplId,
    String companyId,
  ) async {
    print("start generating document");

    final DataSource ds = Modular.get<DataSource>();

    // получаем MAP company
    final RecordModel recordCompanyForTpl =
        await pb.collection('selectForTpl').getOne(companyId);
    final Map<String, dynamic> mapFromRecordCompany = recordCompanyForTpl.data;

    final Map<String, dynamic> companyMap = {
      "COMPANY_NAME": mapFromRecordCompany["company_name"],
      "COMPANY_PIB": mapFromRecordCompany["company_pib"],
    };

    // получаем MAP user
    final String userId = mapFromRecordCompany["user_id"];
    final Map<String, dynamic> userMap = await ds.readData(userId, "users");

    // заворачиваем в одну MAP (userAndCompanyMap)
    final Map<String, String> userAndCompanyMap = {...userMap, ...companyMap};

    // получаем ссылку на тимплэйт, которую нужно передать будет в генератор
    final RecordModel recordTpl =
        await pb.collection('templates').getOne(tplId);
    final String fileName = recordTpl.getListValue<String>('document')[0];
    final String fullTplPath = pb.getFileUrl(recordTpl, fileName).toString();

    final _generator = TplGenerator(
      userAndCompanyMap: userAndCompanyMap,
      tplPath: fullTplPath,
      isRemoteFile: true,
      isAssetFile: false,
    );
    _generator.createDocument();
    print("done generating document");
  }

  uploadDocumentToPb() async {
    final file = File(
        "C:/Users/Alima/Desktop/projects/30. Document_generator/flutter_js/generatedDocument.docx");
    final bytes = file.readAsBytesSync();

    final record = await pb.collection('documents').create(
      body: {
        'title': 'Hello world!', // some regular text field
      },
      files: [
        http.MultipartFile.fromBytes(
          "document",
          bytes,
          filename: "generatedDoc.docx",
        )
      ],
    );
  }

  // generateDocumentFromLocalTpl(
  //     Map<String, String> templateData, String tplPath) {
  //   final TplGenerator _generator = TplGenerator(
  //     templateData: templateData,
  //     tplPath: tplPath,
  //     isRemoteFile: false,
  //     isAssetFile: true,
  //   );
  // }
}
