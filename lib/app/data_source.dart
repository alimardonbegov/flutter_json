import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

abstract class DataSource {
  final PocketBase pb;
  final String configPath;

  DataSource(this.pb, this.configPath);

  late final Map<String, Map<String, String>> _config;
  Map<String, Map<String, String>> get config => _config;

  late final List<dynamic> _usersList;
  List<dynamic> get usersList => _usersList;

  Future<void> getInitData(String collectionName);

  Future<Map<String, dynamic>> getData(String id, String collectionName);

  Future<String> getDocumentLink(String docId, String collectionName);

  Future<void> updateData(
    String id,
    Map<String, dynamic> jsonItem,
    String key,
    String value,
  );
  Future<RecordModel> sentDocumentToDB(
    File file,
    String userId,
    String companyId,
  );
}

// ! POCKET BASE
class PocketBaseDataSource extends DataSource {
  PocketBaseDataSource(super.pb, super.configPath);

  @override
  Future<void> getInitData(collectionName) async {
    final List<dynamic> recordsUsers =
        await pb.collection(collectionName).getFullList();
    _usersList = recordsUsers;

    final String response = await rootBundle.loadString(configPath);
    final jsonConfigParsed = await json.decode(response);
    final Map<String, Map<String, String>> finalMapFromJson = {};
    jsonConfigParsed.forEach((key, value) {
      finalMapFromJson[key] = value.cast<String, String>();
    });
    _config = finalMapFromJson;
  }

  @override
  Future<Map<String, dynamic>> getData(String id, String collectionName) async {
    if (id != null) {
      try {
        final record = await pb.collection(collectionName).getOne(id);
        return record.data;
      } catch (e) {
        print("error fetching data by this id: $id");
      }
    } else {
      print("There is no data");
    }
    return <String, dynamic>{};
  }

  @override
  Future<String> getDocumentLink(String docId, String collectionName) async {
    final RecordModel recordTpl =
        await pb.collection(collectionName).getOne(docId);
    final String fileName = recordTpl.getListValue<String>('document')[0];
    return pb.getFileUrl(recordTpl, fileName).toString();
  }

  @override
  Future<void> updateData(
    String id,
    Map<String, dynamic> jsonItem,
    String key,
    String value,
  ) async {
    if (jsonItem[key] != value) {
      jsonItem[key] = value;
      final jsonDataUpdated = jsonEncode(jsonItem);
      final body = <String, dynamic>{"json": jsonDataUpdated};
      await pb.collection('users').update(id, body: body);
    }
  }

  @override
  Future<RecordModel> sentDocumentToDB(
      File file, String userId, String companyId) async {
    final record = await pb.collection('documents').create(
      body: {
        "user": userId, //привязываем документ к user
        "company": companyId, //привязываем документ к company
      },
      files: [
        http.MultipartFile.fromBytes(
          "document",
          file.readAsBytesSync(),
          filename: "gen.docx",
        )
      ],
    );
    return record;
  }
}


// ! LOCAL
// class LocalDataSource extends DataSource {
//   LocalDataSource(super.dataPath, super.configPath);

//   Future<dynamic> _readLocalFile(localPath) async {
//     final File fileData = File(localPath);
//     final String jsonData = await fileData.readAsString();
//     return jsonDecode(jsonData);
//   }

//   @override
//   Future<void> getData(id) async {
//     final jsonData = await _readLocalFile(dataPath);
//     _jsonItem = jsonData;

//     final jsonConfigParsed = await _readLocalFile(configPath);
//     final Map<String, Map<String, String>> finalMapFromJson = {};
//     jsonConfigParsed.forEach((key, value) {
//       finalMapFromJson[key] = value.cast<String, String>();
//     });

//     _config = finalMapFromJson;
//   }

//   @override
//   Future<void> updateData(key, value, id) async {
//     if (_jsonItem[key] != value) {
//       final File file = File(dataPath);
//       _jsonItem[key] = value;
//       final jsonDataUpdated = jsonEncode(_jsonItem);
//       await file.writeAsString(jsonDataUpdated);
//     }
//   }

//   @override
//   Future<void> getInitData() async {}
// }


// ! HTTP
// class HttpDataSource extends DataSource {
//   HttpDataSource(super.dataPath, super.configPath);
//   Future<dynamic> _readHttpInf(url) async {
//     final http.Response response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load data from $url');
//     }
//   }

//   @override
//   Future<void> getData(id) async {
//     final jsonData = await _readHttpInf(dataPath);
//     _jsonItem = jsonData;

//     final jsonConfigParsed = await _readHttpInf(configPath);
//     final Map<String, Map<String, String>> finalMapFromJson = {};
//     jsonConfigParsed.forEach((key, value) {
//       finalMapFromJson[key] = value.cast<String, String>();
//     });

//     _config = finalMapFromJson;
//   }

//   @override
//   Future<void> updateData(key, value, id) async {
//     if (_jsonItem[key] != value) {
//       final Map<String, dynamic> data = {key: value};
//       final http.Response response =
//           await http.patch(Uri.parse(dataPath), body: jsonEncode(data));
//       if (response.statusCode != 200) {
//         await Future.delayed(Duration(seconds: 2));
//         print("Data has updated. New data are: $_jsonItem");
//       }
//     }
//   }

//   @override
//   Future<void> getInitData() async {}
// }


