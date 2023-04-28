///type of template (docx, pdf)

// оставил конструктор с именем, так в Templater в DocxTemplate видит только родительские поля, тк работаю с абстракцией там
abstract class Template {
  final String tplName;

  Template(this.tplName);
}

class DocxTemplate extends Template {
  DocxTemplate(super.tplName);
}

abstract class PdfTemplate extends Template {
  PdfTemplate({String tplName = ''}) : super(tplName);
}

class JprPdfTemplate extends PdfTemplate {
  JprPdfTemplate({String tplName = ''}) : super(tplName: tplName);
}
