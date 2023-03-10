import 'package:docxtpl/docxtpl.dart';

class TplGenerator {
  final Map<String, String> userAndCompanyMap;
  final String tplPath;
  final bool isRemoteFile;
  final bool isAssetFile;

  TplGenerator({
    required this.userAndCompanyMap,
    required this.tplPath,
    required this.isRemoteFile,
    required this.isAssetFile,
  });

  Future<void> createDocument() async {
    final DocxTpl docxTpl = DocxTpl(
        docxTemplate: tplPath,
        isRemoteFile: isRemoteFile,
        isAssetFile: isAssetFile);

    final response = await docxTpl.parseDocxTpl();
    print(response.mergeStatus);
    print(response.message);

    List<String> fields = docxTpl.getMergeFields();
    Map<String, String> mapFromField = Map.fromIterable(fields);
    Map<String, String> mapForTpl = {...mapFromField, ...userAndCompanyMap};

    if (response.mergeStatus == MergeResponseStatus.Success) {
      await docxTpl.writeMergeFields(data: mapForTpl);
      await docxTpl.save('tpl.docx');
    }
  }
}
