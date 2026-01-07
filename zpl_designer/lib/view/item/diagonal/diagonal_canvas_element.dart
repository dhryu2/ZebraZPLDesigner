import 'package:zpl_designer/core/base_canvas_element.dart';

/// Diagonal line orientation
/// R = Right-leaning (/), L = Left-leaning (\)
enum DiagonalOrientation {
  rightLeaning('R', '오른쪽 대각선 (/)'),
  leftLeaning('L', '왼쪽 대각선 (\\)');

  final String zplCode;
  final String displayName;

  const DiagonalOrientation(this.zplCode, this.displayName);
}

class DiagonalCanvasElement extends BaseCanvasElement {
  int thickness;
  DiagonalOrientation orientation;

  DiagonalCanvasElement({
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    this.thickness = 2,
    this.orientation = DiagonalOrientation.rightLeaning,
  });

  @override
  String conversionZPLCode() {
    // ^GD: Graphic Diagonal Line
    // ^GDwidth,height,thickness,color,orientation
    // color: B = Black (default), W = White
    return '^FO$x,$y^GD$width,$height,$thickness,B,${orientation.zplCode}^FS';
  }

  @override
  BaseCanvasElement copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
    int? zIndex,
    int? thickness,
    DiagonalOrientation? orientation,
  }) {
    return DiagonalCanvasElement(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      thickness: thickness ?? this.thickness,
      orientation: orientation ?? this.orientation,
    )..zIndex = zIndex ?? this.zIndex;
  }
}
