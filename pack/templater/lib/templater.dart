import 'dart:convert';
import 'package:archive/archive_io.dart';

abstract class Templater {
  const Templater();
  Future<List<int>> generateBytes(Map<String, String> mapForTpl);
}

/// templater for docx format
class DocxTemplater extends Templater {
  final List<int> tplBytes;

  const DocxTemplater(this.tplBytes);

  @override
  Future<List<int>> generateBytes(Map<String, String> mapForTpl) async {
    final tpl = _TplDocx(tplBytes);

    final List<String> fields = tpl.mergedFields;
    final Map<String, String> mapFromField = Map.fromIterable(fields);
    final map = {...mapFromField, ...mapForTpl};

    tpl.writeMergedFields(map);
    return tpl.getGeneratedBytes()!;
  }
}

/// Templater for pdf format. Create new instance of PdfTemplater and rewrite this method for specific pdf.
/// Use package:pdf for creating pdf pages
abstract class PdfTemplater extends Templater {
  @override
  Future<List<int>> generateBytes(Map<String, String> mapForTpl) async => [];
}

/// templater for docx
class _TplDocx {
  final List<int> bytes;

  List<String> _mergedFields = [];
  late Archive _zip;
  late String _docXml;
  late int _documentXmlIndex;

  _TplDocx(this.bytes) {
    _getArchiveAndXmlString();
    _getMergedFields();
  }

  void _getArchiveAndXmlString() {
    _zip = ZipDecoder().decodeBytes(bytes, verify: true);

    _documentXmlIndex = _zip.files.indexWhere((file) => file.name == 'word/document.xml');

    final ArchiveFile documentXml = _zip.files[_documentXmlIndex];
    final List<int> content = documentXml.content as List<int>;

    _docXml = utf8.decode(content);
  }

  void _getMergedFields() {
    final List<String> fields = [];
    final RegExp re = RegExp('{{\\w*}}', caseSensitive: true, multiLine: true);
    final Iterable<Match> matches = re.allMatches(_docXml);

    if (matches.isEmpty) {
      fields;
    } else {
      for (var match in matches) {
        final int group = match.groupCount;
        final String field = match.group(group)!;
        final String firstChunk = field.replaceAll('{{', '').trim(); // remove templating braces
        final String secChunk = firstChunk.replaceAll('}}', '').trim(); // remove templating braces
        fields.add(secChunk);
      }
    }
    _mergedFields = fields.toSet().toList();
  }

  /// get merged fields from template
  List<String> get mergedFields => _mergedFields;

  /// write your data in template (Map <String, String> as "MERGE_FIELD_ONE" : "write this instead")
  void writeMergedFields(Map<String, String> data) {
    for (var field in _mergedFields) {
      if (data.containsKey(field) &&
          _docXml.contains(
            RegExp(
              '{{\\w*}}',
              caseSensitive: true,
              multiLine: true,
            ),
          )) {
        _docXml = _docXml.replaceAll(RegExp('{{$field}}'), data[field]!);
      }
    }
  }

  /// get generated docx bytes
  List<int>? getGeneratedBytes() {
    final Archive newZip = Archive();
    for (var file in _zip.files) {
      if (file.name != 'word/document.xml') {
        newZip.addFile(file);
      } else {
        final List<int> xmlBytes = utf8.encode(_docXml);
        final ArchiveFile newWordDocumentXml = ArchiveFile('word/document.xml', xmlBytes.length, xmlBytes);
        newZip.addFile(newWordDocumentXml);
      }
    }

    return ZipEncoder().encode(newZip);
  }
}
