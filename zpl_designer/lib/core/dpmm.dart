enum Dpmm {
  dpmm6(6),
  dpmm8(8),
  dpmm12(12),
  dpmm24(24);

  final int value;

  const Dpmm(this.value);

  /// DPI (dots per inch)로 변환
  int get dpi => (value * 25.4).round();

  /// dot(픽셀)을 mm로 변환
  double dotToMM(int dotCount) => dotCount / value;

  /// mm를 dot(픽셀)로 변환
  int mmToDot(double mm) => (mm * value).round();
}
