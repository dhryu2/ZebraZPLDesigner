import 'package:zpl_designer/core/base_canvas_element.dart';

enum BarcodeType {
  code128('Code 128', 'C'),
  code39('Code 39', '3'),
  ean13('EAN-13', 'E'),
  upca('UPC-A', 'U');

  final String displayName;
  final String zplCode;

  const BarcodeType(this.displayName, this.zplCode);
}

class BarcodeCanvasElement extends BaseCanvasElement {
  BarcodeType barcodeType;
  String data;
  int moduleWidth;
  int barcodeHeight;
  bool showText;
  bool showBorder;
  int borderThickness;
  ZplRotation rotation;

  BarcodeCanvasElement({
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    this.barcodeType = BarcodeType.code128,
    this.data = '123456',
    this.moduleWidth = 2,
    this.barcodeHeight = 30,
    this.showText = true,
    this.showBorder = false,
    this.borderThickness = 2,
    this.rotation = ZplRotation.normal,
  });

  @override
  String conversionZPLCode() {
    final buffer = StringBuffer();

    // 테두리가 있으면 먼저 ^GB 명령어 추가
    if (showBorder) {
      buffer.write('^FO$x,$y^GB$width,$height,$borderThickness^FS');
    }

    final textIndicator = showText ? 'Y' : 'N';
    final rot = rotation.zplCode;

    switch (barcodeType) {
      case BarcodeType.code128:
        // ^BC: Code 128 Bar Code
        buffer.write('^FO$x,$y^BY$moduleWidth^BC$rot,$barcodeHeight,$textIndicator,N,N^FD$data^FS');
      case BarcodeType.code39:
        // ^B3: Code 39 Bar Code
        buffer.write('^FO$x,$y^BY$moduleWidth^B3$rot,N,$barcodeHeight,$textIndicator,N^FD$data^FS');
      case BarcodeType.ean13:
        // ^BE: EAN-13 Bar Code
        buffer.write('^FO$x,$y^BY$moduleWidth^BE$rot,$barcodeHeight,$textIndicator,N^FD$data^FS');
      case BarcodeType.upca:
        // ^BU: UPC-A Bar Code
        buffer.write('^FO$x,$y^BY$moduleWidth^BU$rot,$barcodeHeight,$textIndicator,N,Y^FD$data^FS');
    }

    return buffer.toString();
  }

  @override
  BaseCanvasElement copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
    int? zIndex,
    BarcodeType? barcodeType,
    String? data,
    int? moduleWidth,
    int? barcodeHeight,
    bool? showText,
    bool? showBorder,
    int? borderThickness,
    ZplRotation? rotation,
  }) {
    return BarcodeCanvasElement(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      barcodeType: barcodeType ?? this.barcodeType,
      data: data ?? this.data,
      moduleWidth: moduleWidth ?? this.moduleWidth,
      barcodeHeight: barcodeHeight ?? this.barcodeHeight,
      showText: showText ?? this.showText,
      showBorder: showBorder ?? this.showBorder,
      borderThickness: borderThickness ?? this.borderThickness,
      rotation: rotation ?? this.rotation,
    )..zIndex = zIndex ?? this.zIndex;
  }
}
