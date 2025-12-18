import 'package:zpl_designer/core/base_canvas_element.dart';

class BoxCanvasElement extends BaseCanvasElement {
  int thickness;
  ZplRotation rotation;

  BoxCanvasElement({
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    this.thickness = 2,
    this.rotation = ZplRotation.normal,
  });

  @override
  String conversionZPLCode() {
    // ^FO: Field Origin (위치)
    // ^GB: Graphic Box (width, height, thickness, color, rounding)
    // ^FS: Field Separator
    // Note: ^GB doesn't support rotation in ZPL, rotation is visual only
    return '^FO$x,$y^GB$width,$height,$thickness^FS';
  }

  @override
  BaseCanvasElement copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
    int? zIndex,
    int? thickness,
    ZplRotation? rotation,
  }) {
    return BoxCanvasElement(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      thickness: thickness ?? this.thickness,
      rotation: rotation ?? this.rotation,
    )..zIndex = zIndex ?? this.zIndex;
  }
}
