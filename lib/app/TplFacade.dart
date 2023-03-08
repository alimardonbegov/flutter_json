import 'package:pocketbase/pocketbase.dart';
import 'TplGenerator.dart';

class TplFacade {
  final PocketBase pb;
  TplFacade(this.pb);

  generateDocumentFromRemoteTpl(
      Map<String, String> templateData, String id) async {
    final RecordModel record = await pb.collection('templates').getOne(id);
    final String fileName = record.getListValue<String>('document')[0];
    final String fullTplPath = pb.getFileUrl(record, fileName).toString();

    final TplGenerator _generator = TplGenerator(
      templateData: templateData,
      tplPath: fullTplPath,
      isRemoteFile: true,
      isAssetFile: false,
    );
    _generator.createDocument();
  }

  // uploadDocumentToPb() async {
  //   final record = await pb.collection('documents').create(
  //     body: {
  //       'title': 'Hello world!', // some regular text field
  //     },
  //     files: [
  //       http.MultipartFile.fromString(
  //         'document',
  //         'example content 1...',
  //         filename: 'file1.txt',
  //       ),
  //       http.MultipartFile.fromString(
  //         'document',
  //         'example content 2...',
  //         filename: 'file2.txt',
  //       ),
  //     ],
  //   );
  // }

  generateDocumentFromLocalTpl(
      Map<String, String> templateData, String tplPath) {
    final TplGenerator _generator = TplGenerator(
      templateData: templateData,
      tplPath: tplPath,
      isRemoteFile: false,
      isAssetFile: true,
    );
  }
}
