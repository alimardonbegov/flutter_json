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
    print('Template file fields found: $fields');
    Map<String, String> mapFromField = Map.fromIterable(fields);
    print(mapFromField);

    // var mapping = {
    //   "COMPANY_NAME": "company_name"
    // }

    // mapFromField.keys.forEach((fieldKey) {
    //   userAndCompanyMap.keys.forEach((clientKey) {
    //     if (fi)
    //   });
    // });
    // !2
    // здесь будем создавать новую MAP, которую будем передавать в док для замены,
    // где ключ это field из документов, а значения из MAP, которую соберем общую по user и company
    // добавить проверку наличия в templateData всех значений, по ключам которые должны совпадать с fields

    if (response.mergeStatus == MergeResponseStatus.Success) {
      await docxTpl.writeMergeFields(data: userAndCompanyMap);
      var savedFile = await docxTpl.save('generatedDocument.docx');
    }
  }
}
