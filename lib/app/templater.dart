import 'dart:io';
import 'package:docxtpl/docxtpl.dart';
import './data_source.dart';

class Templater {
  final DataSource ds;

  Templater(this.ds);

  Map<String, String> _createCompanyMap(Map<String, dynamic> companyData) {
    return {
      "COMPANY_NAME": companyData["company_name"],
      "COMPANY_PIB": companyData["company_pib"],
      // добавить вручную новые строки для мэпы в тимплйэты
    };
  }

  Future<Map<String, dynamic>> _createUserMap(
      Map<String, dynamic> companyData) async {
    final String userId = companyData["user_id"];
    final Map<String, dynamic> userData = await ds.getData(userId, "users");
    return userData["json"];
  }

  Future<void> _createDocument({
    required Map<String, String> userAndCompanyMap,
    String? tplPath,
    String? tplPbId,
  }) async {
    late final String fullTplPath;
    late final bool isRemoteTpl;

    if (tplPath == null) {
      fullTplPath = await ds.getDocumentLink(tplPbId!, 'templates');
      isRemoteTpl = true;
      print("create document from remote");
    } else {
      fullTplPath = tplPath;
      isRemoteTpl = false;
      print("create document from local");
    }

    final generator = _TplGenerator(
      userAndCompanyMap: userAndCompanyMap!,
      tplPath: fullTplPath,
      isRemoteFile: isRemoteTpl,
    );
    await generator.createDocument();
  }

  Future<void> _uploadDocumentToDB(
      Map<String, dynamic> companyData, String companyId) async {
    final String path = Directory.current.path;
    final String userId = companyData["user_id"];
    final file = File("${path}/tpl.docx");

    final record = await ds.sentDocumentToDB(file, userId, companyId);
    file.deleteSync();

    final String link = await ds.getDocumentLink(record.id, "documents");
    print(link);
  }

  Future<void> generateDocument({
    required String companyId,
    String? tplPbId,
    String? tplLocalPath,
  }) async {
    final Map<String, dynamic> companyData =
        await ds.getData(companyId, 'selectForTpl');

    final Map<String, String> companyMap = _createCompanyMap(companyData);
    final Map<String, dynamic> userMap = await _createUserMap(companyData);
    final Map<String, String> userAndCompanyMap = {...companyMap, ...userMap};

    await _createDocument(
      userAndCompanyMap: userAndCompanyMap,
      tplPbId: tplPbId,
      tplPath: tplLocalPath,
    );
    await _uploadDocumentToDB(companyData, companyId);
  }
}

class _TplGenerator {
  final Map<String, String> userAndCompanyMap;
  final String tplPath;
  final bool isRemoteFile;

  _TplGenerator({
    required this.userAndCompanyMap,
    required this.tplPath,
    required this.isRemoteFile,
  });

  Future<void> createDocument() async {
    final DocxTpl docxTpl = DocxTpl(
        docxTemplate: tplPath,
        isRemoteFile: isRemoteFile,
        isAssetFile: !isRemoteFile);

    final response = await docxTpl.parseDocxTpl();
    print(response.mergeStatus);

    List<String> fields = docxTpl.getMergeFields();
    Map<String, String> mapFromField = Map.fromIterable(fields);
    Map<String, String> mapForTpl = {...mapFromField, ...userAndCompanyMap};

    if (response.mergeStatus == MergeResponseStatus.Success) {
      await docxTpl.writeMergeFields(data: mapForTpl);
      await docxTpl.save('tpl.docx');
    }
  }
}
