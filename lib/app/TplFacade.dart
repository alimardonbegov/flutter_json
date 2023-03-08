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
    String userId,
    String companyId,
  ) async {
    print("start generating document");

    // получаем MAP user
    final ds = Modular.get<DataSource>();
    final Map<String, dynamic> userMap = await ds.readData(userId, "users");

    // получаем MAP company (здесь придумать получение MAP company через user тк он связан с компание по id)
    final Map<String, dynamic> companyMap =
        await ds.readData(companyId, "companies");

    // заворачиваем в одну MAP (userAndCompanyMap)
    final Map<String, String> userAndCompanyMap = {...userMap, ...companyMap};
    print(userAndCompanyMap);
    // получаем ссылку на тимплэйт, которую нужно передать будет в генератор
    final RecordModel record = await pb.collection('templates').getOne(tplId);
    final String fileName = record.getListValue<String>('document')[0];
    final String fullTplPath = pb.getFileUrl(record, fileName).toString();

    Map<String, String> templateData = {
      'CLIENT_FIO_UC': 'Begov Alimardon',
      'CLIENT_PASSPORT': '9988 777666',
      'COMPANY_NAME': 'Vanguard',
      'COMPANY_PIB': '00010010110',
      'DD_MM_YYYY': '02.03.2023',
    };
    final TplGenerator _generator = TplGenerator(
      userAndCompanyMap: userAndCompanyMap,
      tplPath: fullTplPath,
      isRemoteFile: true,
      isAssetFile: false,
    );
    _generator.createDocument();
    print("done generating document");
  }

  // uploadDocumentToPb() async {
  // }

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
