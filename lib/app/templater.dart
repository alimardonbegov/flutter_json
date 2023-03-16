import 'dart:io';
import 'package:docxtpl/docxtpl.dart';
import './data_source.dart';

class Templater {
  final DataSource ds;

  Templater(this.ds);

// private common methods:
  Future<Map<String, dynamic>> _createUserMap(
      Map<String, dynamic> companyData) async {
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
    final Map<String, dynamic> companyData =
        await ds.getData(companyId, 'selectForTpl');
    final Map<String, String> companyMap = _createCompanyMap(companyData);
    final Map<String, dynamic> userMap = await _createUserMap(companyData);
    return {...companyMap, ...userMap};
  }

// private unique methods for creating doc(bytes) from remote or local tpl:
  Future<List<int>> _createDocumentFromRemote(
    Map<String, String> userAndCompanyMap,
    String tplId,
  ) async {
    final String fullTplPath = await ds.getDocumentLink(tplId, 'templates');

    final generator = _TplGenerator(
      userAndCompanyMap: userAndCompanyMap,
      tplPath: fullTplPath,
      isRemoteFile: true,
    );
    List<int> bytes = await generator.createDocument();
    return bytes;
  }

  Future<List<int>> _createDocumentFromLocal(
    Map<String, String> userAndCompanyMap,
    String tplPath,
  ) async {
    final generator = _TplGenerator(
      userAndCompanyMap: userAndCompanyMap,
      tplPath: tplPath,
      isRemoteFile: false,
    );
    List<int> bytes = await generator.createDocument();
    return bytes;
  }

// public common method for upload document to data base:
  Future<String> uploadDocumentToDB(String companyId, List<int> bytes) async {
    final Map<String, dynamic> companyData =
        await ds.getData(companyId, 'selectForTpl');
    final String userId = companyData["user_id"];
    final record = await ds.sentDocumentToDB(bytes, userId, companyId);
    final String link = await ds.getDocumentLink(record.id, "documents");
    return link;
  }

// public unique methods for generating doc from remote or local tpl:
  Future<List<int>> generateDocumentFromRemote(
    String companyId,
    String tplPbId,
  ) async {
    final Map<String, String> map = await _createUserAndCompanyMap(companyId);
    List<int> bytes = await _createDocumentFromRemote(map, tplPbId);
    return bytes;
  }

  Future<List<int>> generateDocumentFromLoacal(
    String companyId,
    String tplPath,
  ) async {
    final Map<String, String> map = await _createUserAndCompanyMap(companyId);
    List<int> bytes = await _createDocumentFromLocal(map, tplPath);
    return bytes;
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

  Future<List<int>> createDocument() async {
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
      final String path = await docxTpl.save('tpl.docx');
      final file = File(path);
      final List<int> bytes = file.readAsBytesSync();
      file.deleteSync();
      return bytes;
    }
    return [];
  }
}
