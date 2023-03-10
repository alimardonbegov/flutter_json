import 'dart:io';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import './TplGenerator.dart';
import './DataSource.dart';

class TplFacade {
  final PocketBase pb;
  final DataSource ds = Modular.get<DataSource>();

  TplFacade(this.pb);

  Future<void> generateDocumentFromRemoteTpl(
    String tplId,
    String companyId,
  ) async {
    // получаем MAP company
    final Map<String, dynamic> companyData =
        await ds.readData(companyId, 'selectForTpl');

    final Map<String, dynamic> companyMap = {
      "COMPANY_NAME": companyData["company_name"],
      "COMPANY_PIB": companyData["company_pib"],
    };

    // получаем MAP user
    final String userId = companyData["user_id"];
    final Map<String, dynamic> userData = await ds.readData(userId, "users");
    final Map<String, dynamic> userMap = userData["json"];

    // заворачиваем в одну MAP (userAndCompanyMap)
    final Map<String, String> userAndCompanyMap = {...userMap, ...companyMap};

    // получаем ссылку на тимплэйт
    final String fullTplPath = await ds.readDocumentLink(tplId, 'templates');

    final _generator = TplGenerator(
      userAndCompanyMap: userAndCompanyMap,
      tplPath: fullTplPath,
      isRemoteFile: true,
      isAssetFile: false,
    );
    await _generator.createDocument();
  }

  Future<void> uploadDocumentToPb() async {
    final path = Directory.current.path;
    final file = File("${path}/tpl.docx");
    final bytes = file.readAsBytesSync();

    final record = await pb.collection('documents').create(
      body: {
        'title': '',
      },
      files: [
        http.MultipartFile.fromBytes(
          "document",
          bytes,
          filename: "generatedDocument.docx",
        )
      ],
    );
    file.deleteSync();
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
