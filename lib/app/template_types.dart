///type of template (docx, pdf)
///docx required bytes, pdf tpl saved in assets
abstract class Template {}

class DocxTemplate extends Template {
  final List<int> bytes;
  DocxTemplate(this.bytes);
}

abstract class PdfTemplate extends Template {}

class JprPdfTemplate extends PdfTemplate {}
