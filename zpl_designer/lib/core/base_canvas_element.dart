/// ZPL Rotation values
/// N = Normal (0°), R = Rotated (90° clockwise), I = Inverted (180°), B = Bottom-up (270° clockwise)
enum ZplRotation {
  normal('N', '0°', 0),
  rotated90('R', '90°', 90),
  inverted('I', '180°', 180),
  rotated270('B', '270°', 270);

  final String zplCode;
  final String displayName;
  final int degrees;

  const ZplRotation(this.zplCode, this.displayName, this.degrees);
}

abstract class BaseCanvasElement {
  BaseCanvasElement({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.zIndex = 0,
  });

  int x;
  int y;
  int width;
  int height;
  int zIndex; // 낮을수록 뒤에 (먼저 렌더링), 높을수록 앞에 (나중에 렌더링)

  void movePosition(int x, int y) {
    this.x = x;
    this.y = y;
  }

  void resize(int width, int height) {
    this.width = width;
    this.height = height;
  }

  BaseCanvasElement copyWith({int? x, int? y, int? width, int? height, int? zIndex});

  String conversionZPLCode();
}
