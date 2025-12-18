import 'package:zpl_designer/core/base_canvas_element.dart';

enum QRErrorCorrection {
  high('H', 'High (~30%)'),
  quality('Q', 'Quality (~25%)'),
  medium('M', 'Medium (~15%)'),
  low('L', 'Low (~7%)');

  final String zplCode;
  final String displayName;

  const QRErrorCorrection(this.zplCode, this.displayName);
}

class QRCodeCanvasElement extends BaseCanvasElement {
  String data;
  int magnification;
  QRErrorCorrection errorCorrection;
  bool showBorder;
  int borderThickness;
  ZplRotation rotation;

  QRCodeCanvasElement({
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    this.data = 'https://example.com',
    this.magnification = 3,
    this.errorCorrection = QRErrorCorrection.medium,
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

    // ^BQ: QR Code Bar Code
    // rotation.zplCode: N (0°), R (90°), I (180°), B (270°)
    // 2: Model 2 (recommended)
    // magnification: 1-10 (size multiplier)
    // Error correction is encoded in the data field
    buffer.write('^FO$x,$y^BQ${rotation.zplCode},2,$magnification^FD${errorCorrection.zplCode}A,$data^FS');

    return buffer.toString();
  }

  @override
  BaseCanvasElement copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
    int? zIndex,
    String? data,
    int? magnification,
    QRErrorCorrection? errorCorrection,
    bool? showBorder,
    int? borderThickness,
    ZplRotation? rotation,
  }) {
    return QRCodeCanvasElement(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      data: data ?? this.data,
      magnification: magnification ?? this.magnification,
      errorCorrection: errorCorrection ?? this.errorCorrection,
      showBorder: showBorder ?? this.showBorder,
      borderThickness: borderThickness ?? this.borderThickness,
      rotation: rotation ?? this.rotation,
    )..zIndex = zIndex ?? this.zIndex;
  }
}
