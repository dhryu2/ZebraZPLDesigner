import 'package:zpl_designer/core/base_canvas_element.dart';

enum ZplFont {
  font0('0', 'Default (A0)'),
  fontA('A', 'Font A'),
  fontB('B', 'Font B'),
  fontC('C', 'Font C (OCR-B)'),
  fontD('D', 'Font D'),
  fontE('E', 'Font E (OCR-A)'),
  fontF('F', 'Font F'),
  fontG('G', 'Font G'),
  fontH('H', 'Font H'),
  fontP('P', 'Font P'),
  fontQ('Q', 'Font Q'),
  fontR('R', 'Font R'),
  fontS('S', 'Font S'),
  fontT('T', 'Font T'),
  fontU('U', 'Font U'),
  fontV('V', 'Font V');

  final String zplCode;
  final String displayName;

  const ZplFont(this.zplCode, this.displayName);
}

/// Text alignment for ^FB command
enum TextAlignment {
  left('L', '왼쪽'),
  center('C', '가운데'),
  right('R', '오른쪽'),
  justified('J', '양쪽');

  final String zplCode;
  final String displayName;

  const TextAlignment(this.zplCode, this.displayName);
}

class TextCanvasElement extends BaseCanvasElement {
  TextCanvasElement({
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    this.text = "Text",
    this.fontHeight = 20,
    this.fontWidth = 20,
    this.font = ZplFont.font0,
    this.maxLine,
    this.showBorder = false,
    this.borderThickness = 2,
    this.rotation = ZplRotation.normal,
    this.alignment = TextAlignment.left,
  });

  String text;
  int fontHeight;
  int fontWidth;
  ZplFont font;
  int? maxLine;
  bool showBorder;
  int borderThickness;
  ZplRotation rotation;
  TextAlignment alignment;

  @override
  String conversionZPLCode() {
    final buffer = StringBuffer();

    // 테두리가 있으면 먼저 ^GB 명령어 추가
    if (showBorder) {
      buffer.write('^FO$x,$y^GB$width,$height,$borderThickness^FS');
    }

    // ^FO: Field Origin (위치)
    // ^A: Font selection (font, orientation, height, width)
    // ^FD: Field Data
    // ^FS: Field Separator
    // rotation.zplCode = N (0°), R (90°), I (180°), B (270°)
    final fbCmd = '^FB$width,${maxLine ?? 1},0,${alignment.zplCode},0';
    buffer.write('^FO$x,$y^A${font.zplCode}${rotation.zplCode},$fontHeight,$fontWidth$fbCmd^FD$text^FS');

    return buffer.toString();
  }

  @override
  BaseCanvasElement copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
    int? zIndex,
    String? text,
    int? fontHeight,
    int? fontWidth,
    ZplFont? font,
    int? maxLine,
    bool? showBorder,
    int? borderThickness,
    ZplRotation? rotation,
    TextAlignment? alignment,
  }) {
    return TextCanvasElement(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      text: text ?? this.text,
      fontHeight: fontHeight ?? this.fontHeight,
      fontWidth: fontWidth ?? this.fontWidth,
      font: font ?? this.font,
      maxLine: maxLine ?? this.maxLine,
      showBorder: showBorder ?? this.showBorder,
      borderThickness: borderThickness ?? this.borderThickness,
      rotation: rotation ?? this.rotation,
      alignment: alignment ?? this.alignment,
    )..zIndex = zIndex ?? this.zIndex;
  }
}
