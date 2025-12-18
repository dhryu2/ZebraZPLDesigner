import 'package:zpl_designer/core/base_canvas_element.dart';

enum LineOrientation {
  horizontal('수평'),
  vertical('수직');

  final String displayName;

  const LineOrientation(this.displayName);
}

class LineCanvasElement extends BaseCanvasElement {
  int thickness;
  LineOrientation orientation;

  LineCanvasElement({
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    this.thickness = 2,
    this.orientation = LineOrientation.horizontal,
  });

  @override
  String conversionZPLCode() {
    // ^FO: Field Origin (위치)
    // ^GB: Graphic Box (width, height, thickness, color, rounding)
    // ^FS: Field Separator
    // Line is a box with width or height equal to thickness
    if (orientation == LineOrientation.horizontal) {
      return '^FO$x,$y^GB$width,$thickness,$thickness^FS';
    } else {
      return '^FO$x,$y^GB$thickness,$height,$thickness^FS';
    }
  }

  @override
  BaseCanvasElement copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
    int? zIndex,
    int? thickness,
    LineOrientation? orientation,
  }) {
    return LineCanvasElement(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      thickness: thickness ?? this.thickness,
      orientation: orientation ?? this.orientation,
    )..zIndex = zIndex ?? this.zIndex;
  }
}
