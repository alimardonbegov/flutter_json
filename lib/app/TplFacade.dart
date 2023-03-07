import 'package:flutter_modular/flutter_modular.dart';
import 'package:pocketbase/pocketbase.dart';
import 'DataSource.dart';
import 'TplGenerator.dart';

class TplFacade {
  generateDocumentFromRemoteTpl(
      Map<String, String> templateData, String id) async {
    final ds = Modular.get<DataSource>();
    final RecordModel record = await ds.pb.collection('documents').getOne(id);
    final String fileName = record.getListValue<String>('document')[0];
    final String fullTplPath = ds.pb.getFileUrl(record, fileName).toString();

    final TplGenerator _generator = TplGenerator(
      templateData: templateData,
      tplPath: fullTplPath,
      isRemoteFile: true,
      isAssetFile: false,
    );
    _generator.createDocument();
  }

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
