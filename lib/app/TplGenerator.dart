import 'package:docxtpl/docxtpl.dart';

class TplGenerator {
  final Map<String, String> templateData;
  final String tplPath;
  final bool isRemoteFile;
  final bool isAssetFile;

  TplGenerator({
    required this.templateData,
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

    // var fields = docxTpl.getMergeFields();
    // print('Template file fields found: $fields');
    // добавить проверку наличия в templateData всех значений, по ключам которые должны совпадать с fields

    if (response.mergeStatus == MergeResponseStatus.Success) {
      await docxTpl.writeMergeFields(data: templateData);
      var savedFile = await docxTpl.save('generatedDocument.docx');
    }
  }
}
