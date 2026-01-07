import 'package:zpl_designer/core/base_canvas_element.dart';

class EllipseCanvasElement extends BaseCanvasElement {
  int thickness;

  EllipseCanvasElement({
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    this.thickness = 2,
  });

  @override
  String conversionZPLCode() {
    // ^GE: Graphic Ellipse
    // ^GEwidth,height,thickness,color
    // color: B = Black (default), W = White
    return '^FO$x,$y^GE$width,$height,$thickness,B^FS';
  }

  @override
  BaseCanvasElement copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
    int? zIndex,
    int? thickness,
  }) {
    return EllipseCanvasElement(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      thickness: thickness ?? this.thickness,
    )..zIndex = zIndex ?? this.zIndex;
  }
}
