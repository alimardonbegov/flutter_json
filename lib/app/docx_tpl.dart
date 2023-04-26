import 'package:pocketbase/pocketbase.dart';
import 'package:tpl_docx/tpl_docx.dart';
import './data_source.dart';

class DocxTemplater {
  final DataSource ds;

  DocxTemplater(this.ds);

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

  Future<List<int>> generateDoc(String tplId, String companyId) async {
    final String fullTplPath = await ds.getDocLink(tplId, 'templates');
    final List<int> bytes = await ds.getDocBytes(fullTplPath);

    final tpl = TplDocx(bytes);
    final List<String> fields = tpl.mergedFields;

    final Map<String, String> userAndCompanyMap = await _createUserAndCompanyMap(companyId);
    final Map<String, String> mapFromField = Map.fromIterable(fields);
    final Map<String, String> mapForTpl = {...mapFromField, ...userAndCompanyMap};

    tpl.writeMergedFields(mapForTpl);
    return tpl.getGeneratedBytes()!;
  }

  Future<String> uploadDocToDB(String companyId, List<int> bytes) async {
    final Map<String, dynamic> companyData = await ds.getData(companyId, 'selectForTpl');
    final String userId = companyData["user_id"];

    final RecordModel record = await ds.sentDocToDB(bytes, userId, companyId, "docx");
    final String link = await ds.getDocLink(record.id, "documents");

    return link;
  }
}
