import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:templater/templater.dart';

abstract class DataSource {
  /// pocket base auth
  final PocketBase pb;

  /// user's config path for rendering fields of information about user
  final String configPath;

  DataSource(this.pb, this.configPath);

  /// user's config for rendering fields of information about user
  late final Map<String, Map<String, List<String>>> _userConfig;
  Map<String, Map<String, List<String>>> get config => _userConfig;

  late final List<dynamic> _usersList;
  List<dynamic> get usersList => _usersList;

  /// create users List for initial rendering
  Future<void> getInitData(String collectionName);

  /// get data of the record
  Future<Map<String, dynamic>> getData(String id, String collectionName);

  /// get document link of the record (for example for templates or generated files from templates)
  Future<String> getDocLinkById(String docId, String collectionName, {int fileNumberInRecord = 0});

  /// update user's data in data base
  Future<void> updateData(String id, Map<String, dynamic> jsonItem, String key, String value);

  /// upload document to data base (for example generated doc)
  Future<RecordModel> sentDocToDB(List<int> bytes, String companyId);

  /// get document bytes from data base (for example template)
  Future<List<int>> getDocBytes(String fileUrl);

  // Future<List<

  //! rewrite method in the future
  Future<Map<String, String>> generateClientMap(Templater template, String companyId);
}

// ! POCKET BASE
class PocketBaseDataSource extends DataSource {
  PocketBaseDataSource(super.pb, super.configPath);

  @override
  Future<void> getInitData(collectionName) async {
    final List<dynamic> recordsUsers = await pb.collection(collectionName).getFullList();
    _usersList = recordsUsers;

    final String response = await rootBundle.loadString(configPath);
    final jsonConfigParsed = await json.decode(response);
    final Map<String, Map<String, List<String>>> finalMapFromJson = {};

    jsonConfigParsed.forEach((key, value) {
      final Map<String, dynamic> valueMap = Map<String, dynamic>.from(value);
      finalMapFromJson[key] = valueMap.map((k, v) => MapEntry(k, List<String>.from(v)));
    });

    _userConfig = finalMapFromJson;
  }

  @override
  Future<Map<String, dynamic>> getData(String id, String collectionName) async {
    if (id != null) {
      try {
        final record = await pb.collection(collectionName).getOne(id);
        return record.data;
      } catch (e) {
        print("error fetching data by this id: $id");
        print("error message: ${e}");
      }
    } else {
      print("There is no data");
    }
    return <String, dynamic>{};
  }

  @override
  Future<String> getDocLinkById(String docId, String collectionName, {int fileNumberInRecord = 0}) async {
    final RecordModel recordTpl = await pb.collection(collectionName).getOne(docId);
    final String fileName = recordTpl.getListValue<String>('document')[fileNumberInRecord];
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
  Future<RecordModel> sentDocToDB(
    List<int> bytes,
    String companyId,
  ) async {
    final Map<String, dynamic> companyData = await getData(companyId, 'selectForTpl');
    final String userId = companyData["user_id"];

    final record = await pb.collection('documents').create(
      body: {
        "user": userId, //связываем документ с user
        "company": companyId, //связываем документ с company
      },
      files: [
        http.MultipartFile.fromBytes(
          "document",
          bytes,
          filename: "file",
        )
      ],
    );
    return record;
  }

  @override
  Future<List<int>> getDocBytes(String fileUrl) async {
    try {
      final Client client = Client();
      final Response response = await client.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      throw Exception('error downloading file: ' + e.toString());
    }
  }

  @override
  Future<Map<String, String>> generateClientMap(Templater template, String companyId) async {
    Future<Map<String, dynamic>> _createUserMap(Map<String, dynamic> companyData) async {
      final String userId = companyData["user_id"];
      final Map<String, dynamic> userData = await getData(userId, "users");
      return userData["json"];
    }

    //! добавить вручную новые строки для мэпы в тимплйэты
    Map<String, String> _createCompanyMap(Map<String, dynamic> companyData) {
      return {
        "COMPANY_NAME": companyData["company_name"],
        "COMPANY_PIB": companyData["company_pib"],
      };
    }

    if (template.runtimeType == DocxTemplater) {
      final Map<String, dynamic> companyData = await getData(companyId, 'selectForTpl');
      final Map<String, String> companyMap = _createCompanyMap(companyData);
      final Map<String, dynamic> userMap = await _createUserMap(companyData);
      return {...companyMap, ...userMap};
    } else {
      //! create map generator for PDF documents (for now it create a test Map)
      return {
        //first page
        "maticni broj": "03523456",
        "company name": "COMPANY DOO",
        "drzava": "Crna Gora",
        "opstina": "Budva",
        "mjesto": "Sveti Stefat",
        "ulica i broj": "BB Slobode",
        "email": "email@gmail.com",
        "broj dodatka B": "1",
        "napomena": "Prijava lica ovlaštenog za elektronsko slanje podatka PU; izvršnog direktora",
        "JMB": "2402986223104",
        //second page
        "naziv organa": "Centralni registar privrednih subjekata",
        "datum registracije": "08  02  2023", // with two spaces between for now
        "broj regisrtarskog uloska": "5 - 1114596/001",
        "podaci o vlascenom licu - JMB": "0807984220007",
        "prezime": "Garkavyy",
        "ime": "Alexander",
        "adresa": "Bar, Dobra Voda, Marelica bb",
        //third page
        "prezime_2": "Podgornyi", // director
        "ime_2": "Aleksei", // director
        "datum rodeja": "12  03  1994", // with two spaces between for now
        "drzavljanstvo": "Rusko",
        "vrsta identif doc": "Dozvola za privremeni boravak i rad",
        "broj indet doc": "319098842",
        "izdat od": "FL Ulcinj",
        "osnov osiguranja": "Radni odnos",
        "datum doc": "20  03  2023", // with two spaces between for now
      };
    }
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

//     _userConfig = finalMapFromJson;
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
//
// Future<List<int>> _getDocBytesFromLocal(String docPath) async {
//   try {
//     final file = File(docPath);
//     return file.readAsBytesSync();
//   } catch (e) {
//     throw Exception('error downloading local .docx template file: ' + e.toString());
//   }
// }
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

//     _userConfig = finalMapFromJson;
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
