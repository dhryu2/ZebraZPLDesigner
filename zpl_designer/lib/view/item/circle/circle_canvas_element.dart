import 'package:zpl_designer/core/base_canvas_element.dart';

class CircleCanvasElement extends BaseCanvasElement {
  int diameter;
  int thickness;

  CircleCanvasElement({
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    int? diameter,
    this.thickness = 2,
  }) : diameter = diameter ?? width;

  @override
  String conversionZPLCode() {
    // ^GC: Graphic Circle
    // ^GCdiameter,thickness,color
    // color: B = Black (default), W = White
    return '^FO$x,$y^GC$diameter,$thickness,B^FS';
  }

  @override
  BaseCanvasElement copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
    int? zIndex,
    int? diameter,
    int? thickness,
  }) {
    return CircleCanvasElement(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      diameter: diameter ?? this.diameter,
      thickness: thickness ?? this.thickness,
    )..zIndex = zIndex ?? this.zIndex;
  }
}
