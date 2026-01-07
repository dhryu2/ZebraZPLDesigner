import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/dpmm.dart';
import 'package:zpl_designer/view/item/barcode/barcode_canvas_element.dart';
import 'package:zpl_designer/view/item/box/box_canvas_element.dart';
import 'package:zpl_designer/view/item/circle/circle_canvas_element.dart';
import 'package:zpl_designer/view/item/diagonal/diagonal_canvas_element.dart';
import 'package:zpl_designer/view/item/ellipse/ellipse_canvas_element.dart';
import 'package:zpl_designer/view/item/line/line_canvas_element.dart';
import 'package:zpl_designer/view/item/qrcode/qrcode_canvas_element.dart';
import 'package:zpl_designer/view/item/text/text_canvas_element.dart';

class ZplParser {
  final Dpmm dpmm;

  ZplParser({required this.dpmm});

  /// 회전 코드를 ZplRotation으로 변환
  ZplRotation _parseRotation(String? rotationCode) {
    return switch (rotationCode) {
      'R' => ZplRotation.rotated90,
      'I' => ZplRotation.inverted,
      'B' => ZplRotation.rotated270,
      _ => ZplRotation.normal,
    };
  }

  /// ZPL 코드를 파싱하여 캔버스 요소 리스트로 변환
  List<BaseCanvasElement> parse(String zplCode) {
    final elements = <BaseCanvasElement>[];

    // ^XA와 ^XZ 사이의 내용만 파싱
    final startIndex = zplCode.indexOf('^XA');
    final endIndex = zplCode.indexOf('^XZ');

    if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
      return elements;
    }

    final content = zplCode.substring(startIndex + 3, endIndex);

    // 현재 위치 추적
    int currentX = 0;
    int currentY = 0;

    // 각 필드를 ^FS로 분리
    final fields = content.split('^FS');

    int zIndex = 0;

    for (final field in fields) {
      final trimmedField = field.trim();
      if (trimmedField.isEmpty) continue;

      // ^FO (Field Origin) 파싱
      final foMatch = RegExp(r'\^FO(\d+),(\d+)').firstMatch(trimmedField);
      if (foMatch != null) {
        currentX = int.parse(foMatch.group(1)!);
        currentY = int.parse(foMatch.group(2)!);
      }

      // ^GB (Graphic Box) 파싱 - 선(Line)인지 박스인지 구분
      final gbMatch = RegExp(r'\^GB(\d+),(\d+),(\d+)(?:,([BW]))?(?:,(\d+))?').firstMatch(trimmedField);
      if (gbMatch != null) {
        final width = int.parse(gbMatch.group(1)!);
        final height = int.parse(gbMatch.group(2)!);
        final thickness = int.parse(gbMatch.group(3)!);

        // 선인지 박스인지 판별 (width나 height가 thickness와 같으면 선)
        final isHorizontalLine = height <= thickness && width > height;
        final isVerticalLine = width <= thickness && height > width;

        if (isHorizontalLine || isVerticalLine) {
          // 선으로 처리
          final element = LineCanvasElement(
            x: dpmm.dotToMM(currentX).round(),
            y: dpmm.dotToMM(currentY).round(),
            width: dpmm.dotToMM(width).round().clamp(5, 1000),
            height: dpmm.dotToMM(height).round().clamp(5, 1000),
            thickness: thickness.clamp(1, 20),
            orientation: isHorizontalLine ? LineOrientation.horizontal : LineOrientation.vertical,
          )..zIndex = zIndex++;
          elements.add(element);
        } else {
          // 박스로 처리
          final element = BoxCanvasElement(
            x: dpmm.dotToMM(currentX).round(),
            y: dpmm.dotToMM(currentY).round(),
            width: dpmm.dotToMM(width).round().clamp(5, 1000),
            height: dpmm.dotToMM(height).round().clamp(5, 1000),
            thickness: thickness.clamp(1, 100),
          )..zIndex = zIndex++;
          elements.add(element);
        }
        continue;
      }

      // ^BQ (QR Code) 파싱 - 회전 코드 추가
      final bqMatch = RegExp(r'\^BQ([NRIB])?,?(\d+),(\d+)').firstMatch(trimmedField);
      if (bqMatch != null) {
        final rotationCode = bqMatch.group(1);
        final magnification = int.parse(bqMatch.group(3)!);

        // ^FD 에서 데이터 추출
        final fdMatch = RegExp(r'\^FD([HQML])A,(.+)$').firstMatch(trimmedField);
        String data = 'https://example.com';
        QRErrorCorrection errorCorrection = QRErrorCorrection.medium;

        if (fdMatch != null) {
          final ecCode = fdMatch.group(1)!;
          data = fdMatch.group(2) ?? data;

          errorCorrection = switch (ecCode) {
            'H' => QRErrorCorrection.high,
            'Q' => QRErrorCorrection.quality,
            'M' => QRErrorCorrection.medium,
            'L' => QRErrorCorrection.low,
            _ => QRErrorCorrection.medium,
          };
        }

        final size = magnification * 5; // 대략적인 mm 크기
        final element = QRCodeCanvasElement(
          x: dpmm.dotToMM(currentX).round(),
          y: dpmm.dotToMM(currentY).round(),
          width: size.clamp(5, 100),
          height: size.clamp(5, 100),
          data: data,
          magnification: magnification.clamp(1, 10),
          errorCorrection: errorCorrection,
          rotation: _parseRotation(rotationCode),
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^BC (Code 128 Barcode) 파싱 - 회전 코드 추가
      final bcMatch = RegExp(r'\^BC([NRIB]),(\d+),([YN])').firstMatch(trimmedField);
      if (bcMatch != null) {
        final rotationCode = bcMatch.group(1);
        final barcodeHeight = int.parse(bcMatch.group(2)!);
        final showText = bcMatch.group(3) == 'Y';

        // ^BY 에서 moduleWidth 추출
        final byMatch = RegExp(r'\^BY(\d+)').firstMatch(trimmedField);
        final moduleWidth = byMatch != null ? int.parse(byMatch.group(1)!) : 2;

        // ^FD 에서 데이터 추출
        final fdMatch = RegExp(r'\^FD(.+)$').firstMatch(trimmedField);
        final data = fdMatch?.group(1) ?? '123456';

        final element = BarcodeCanvasElement(
          x: dpmm.dotToMM(currentX).round(),
          y: dpmm.dotToMM(currentY).round(),
          width: 30,
          height: 15,
          barcodeType: BarcodeType.code128,
          data: data,
          moduleWidth: moduleWidth.clamp(1, 10),
          barcodeHeight: barcodeHeight.clamp(10, 500),
          showText: showText,
          rotation: _parseRotation(rotationCode),
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^B3 (Code 39 Barcode) 파싱 - 회전 코드 추가
      final b3Match = RegExp(r'\^B3([NRIB]),N,(\d+),([YN])').firstMatch(trimmedField);
      if (b3Match != null) {
        final rotationCode = b3Match.group(1);
        final barcodeHeight = int.parse(b3Match.group(2)!);
        final showText = b3Match.group(3) == 'Y';

        final byMatch = RegExp(r'\^BY(\d+)').firstMatch(trimmedField);
        final moduleWidth = byMatch != null ? int.parse(byMatch.group(1)!) : 2;

        final fdMatch = RegExp(r'\^FD(.+)$').firstMatch(trimmedField);
        final data = fdMatch?.group(1) ?? '123456';

        final element = BarcodeCanvasElement(
          x: dpmm.dotToMM(currentX).round(),
          y: dpmm.dotToMM(currentY).round(),
          width: 30,
          height: 15,
          barcodeType: BarcodeType.code39,
          data: data,
          moduleWidth: moduleWidth.clamp(1, 10),
          barcodeHeight: barcodeHeight.clamp(10, 500),
          showText: showText,
          rotation: _parseRotation(rotationCode),
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^BE (EAN-13 Barcode) 파싱 - 회전 코드 추가
      final beMatch = RegExp(r'\^BE([NRIB]),(\d+),([YN])').firstMatch(trimmedField);
      if (beMatch != null) {
        final rotationCode = beMatch.group(1);
        final barcodeHeight = int.parse(beMatch.group(2)!);
        final showText = beMatch.group(3) == 'Y';

        final byMatch = RegExp(r'\^BY(\d+)').firstMatch(trimmedField);
        final moduleWidth = byMatch != null ? int.parse(byMatch.group(1)!) : 2;

        final fdMatch = RegExp(r'\^FD(.+)$').firstMatch(trimmedField);
        final data = fdMatch?.group(1) ?? '123456';

        final element = BarcodeCanvasElement(
          x: dpmm.dotToMM(currentX).round(),
          y: dpmm.dotToMM(currentY).round(),
          width: 30,
          height: 15,
          barcodeType: BarcodeType.ean13,
          data: data,
          moduleWidth: moduleWidth.clamp(1, 10),
          barcodeHeight: barcodeHeight.clamp(10, 500),
          showText: showText,
          rotation: _parseRotation(rotationCode),
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^BU (UPC-A Barcode) 파싱 - 회전 코드 추가
      final buMatch = RegExp(r'\^BU([NRIB]),(\d+),([YN])').firstMatch(trimmedField);
      if (buMatch != null) {
        final rotationCode = buMatch.group(1);
        final barcodeHeight = int.parse(buMatch.group(2)!);
        final showText = buMatch.group(3) == 'Y';

        final byMatch = RegExp(r'\^BY(\d+)').firstMatch(trimmedField);
        final moduleWidth = byMatch != null ? int.parse(byMatch.group(1)!) : 2;

        final fdMatch = RegExp(r'\^FD(.+)$').firstMatch(trimmedField);
        final data = fdMatch?.group(1) ?? '123456';

        final element = BarcodeCanvasElement(
          x: dpmm.dotToMM(currentX).round(),
          y: dpmm.dotToMM(currentY).round(),
          width: 30,
          height: 15,
          barcodeType: BarcodeType.upca,
          data: data,
          moduleWidth: moduleWidth.clamp(1, 10),
          barcodeHeight: barcodeHeight.clamp(10, 500),
          showText: showText,
          rotation: _parseRotation(rotationCode),
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^A (Font/Text) 파싱 - 회전 코드(N, R, I, B) 추가
      final textMatch = RegExp(r'\^A([0A-Z])([NRIB]),(\d+),(\d+)').firstMatch(trimmedField);
      if (textMatch != null) {
        final fontCode = textMatch.group(1)!;
        final rotationCode = textMatch.group(2);
        final fontHeight = int.parse(textMatch.group(3)!);
        final fontWidth = int.parse(textMatch.group(4)!);

        // ^FB (Field Block) 파싱 - 멀티라인 텍스트, 정렬 포함
        // ^FBwidth,maxLines,lineSpacing,alignment,hangingIndent
        final fbMatch = RegExp(r'\^FB(\d+),(\d+)(?:,(\d+))?(?:,([LCRJ]))?').firstMatch(trimmedField);
        int? maxLine;
        int fieldWidth = 100;
        TextAlignment alignment = TextAlignment.left;
        if (fbMatch != null) {
          fieldWidth = int.parse(fbMatch.group(1)!);
          maxLine = int.parse(fbMatch.group(2)!);
          final alignCode = fbMatch.group(4);
          if (alignCode != null) {
            alignment = switch (alignCode) {
              'C' => TextAlignment.center,
              'R' => TextAlignment.right,
              'J' => TextAlignment.justified,
              _ => TextAlignment.left,
            };
          }
        }

        // ^FD 에서 텍스트 추출
        final fdMatch = RegExp(r'\^FD(.+)$').firstMatch(trimmedField);
        final text = fdMatch?.group(1) ?? 'Text';

        // 폰트 코드를 ZplFont로 변환
        ZplFont font = ZplFont.font0;
        for (final f in ZplFont.values) {
          if (f.zplCode == fontCode) {
            font = f;
            break;
          }
        }

        final element = TextCanvasElement(
          x: dpmm.dotToMM(currentX).round(),
          y: dpmm.dotToMM(currentY).round(),
          width: dpmm.dotToMM(fieldWidth).round().clamp(5, 500),
          height: dpmm.dotToMM(fontHeight).round().clamp(5, 200),
          text: text,
          fontHeight: fontHeight.clamp(10, 500),
          fontWidth: fontWidth.clamp(10, 500),
          font: font,
          maxLine: maxLine,
          rotation: _parseRotation(rotationCode),
          alignment: alignment,
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^GD (Graphic Diagonal Line) 파싱
      // ^GDwidth,height,thickness,color,orientation
      final gdMatch = RegExp(r'\^GD(\d+),(\d+),(\d+)(?:,[BW])?(?:,([RL]))?').firstMatch(trimmedField);
      if (gdMatch != null) {
        final width = int.parse(gdMatch.group(1)!);
        final height = int.parse(gdMatch.group(2)!);
        final thickness = int.parse(gdMatch.group(3)!);
        final orientationCode = gdMatch.group(4);

        final orientation = orientationCode == 'L'
            ? DiagonalOrientation.leftLeaning
            : DiagonalOrientation.rightLeaning;

        final element = DiagonalCanvasElement(
          x: dpmm.dotToMM(currentX).round(),
          y: dpmm.dotToMM(currentY).round(),
          width: dpmm.dotToMM(width).round().clamp(5, 1000),
          height: dpmm.dotToMM(height).round().clamp(5, 1000),
          thickness: thickness.clamp(1, 20),
          orientation: orientation,
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^GC (Graphic Circle) 파싱
      // ^GCdiameter,thickness,color
      final gcMatch = RegExp(r'\^GC(\d+),(\d+)').firstMatch(trimmedField);
      if (gcMatch != null) {
        final diameter = int.parse(gcMatch.group(1)!);
        final thickness = int.parse(gcMatch.group(2)!);

        final sizeMm = dpmm.dotToMM(diameter).round().clamp(5, 500);
        final element = CircleCanvasElement(
          x: dpmm.dotToMM(currentX).round(),
          y: dpmm.dotToMM(currentY).round(),
          width: sizeMm,
          height: sizeMm,
          diameter: sizeMm,
          thickness: thickness.clamp(1, 20),
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^GE (Graphic Ellipse) 파싱
      // ^GEwidth,height,thickness,color
      final geMatch = RegExp(r'\^GE(\d+),(\d+),(\d+)').firstMatch(trimmedField);
      if (geMatch != null) {
        final width = int.parse(geMatch.group(1)!);
        final height = int.parse(geMatch.group(2)!);
        final thickness = int.parse(geMatch.group(3)!);

        final element = EllipseCanvasElement(
          x: dpmm.dotToMM(currentX).round(),
          y: dpmm.dotToMM(currentY).round(),
          width: dpmm.dotToMM(width).round().clamp(5, 1000),
          height: dpmm.dotToMM(height).round().clamp(5, 1000),
          thickness: thickness.clamp(1, 20),
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }
    }

    return elements;
  }
}
