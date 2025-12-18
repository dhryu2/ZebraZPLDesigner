import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/dpmm.dart';
import 'package:zpl_designer/view/item/barcode/barcode_canvas_element.dart';
import 'package:zpl_designer/view/item/box/box_canvas_element.dart';
import 'package:zpl_designer/view/item/qrcode/qrcode_canvas_element.dart';
import 'package:zpl_designer/view/item/text/text_canvas_element.dart';

class ZplParser {
  final Dpmm dpmm;

  ZplParser({required this.dpmm});

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

      // ^GB (Graphic Box) 파싱
      final gbMatch = RegExp(r'\^GB(\d+),(\d+),(\d+)').firstMatch(trimmedField);
      if (gbMatch != null) {
        final width = int.parse(gbMatch.group(1)!);
        final height = int.parse(gbMatch.group(2)!);
        final thickness = int.parse(gbMatch.group(3)!);

        final element = BoxCanvasElement(
          x: dpmm.dotToMM(currentX).round(),
          y: dpmm.dotToMM(currentY).round(),
          width: dpmm.dotToMM(width).round().clamp(5, 1000),
          height: dpmm.dotToMM(height).round().clamp(5, 1000),
          thickness: thickness.clamp(1, 100),
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^BQ (QR Code) 파싱
      final bqMatch = RegExp(r'\^BQ[NO],(\d+),(\d+)').firstMatch(trimmedField);
      if (bqMatch != null) {
        final magnification = int.parse(bqMatch.group(2)!);

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
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^BC (Code 128 Barcode) 파싱
      final bcMatch = RegExp(r'\^BCN,(\d+),([YN])').firstMatch(trimmedField);
      if (bcMatch != null) {
        final barcodeHeight = int.parse(bcMatch.group(1)!);
        final showText = bcMatch.group(2) == 'Y';

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
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^B3 (Code 39 Barcode) 파싱
      final b3Match = RegExp(r'\^B3N,N,(\d+),([YN])').firstMatch(trimmedField);
      if (b3Match != null) {
        final barcodeHeight = int.parse(b3Match.group(1)!);
        final showText = b3Match.group(2) == 'Y';

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
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^BE (EAN-13 Barcode) 파싱
      final beMatch = RegExp(r'\^BEN,(\d+),([YN])').firstMatch(trimmedField);
      if (beMatch != null) {
        final barcodeHeight = int.parse(beMatch.group(1)!);
        final showText = beMatch.group(2) == 'Y';

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
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^BU (UPC-A Barcode) 파싱
      final buMatch = RegExp(r'\^BUN,(\d+),([YN])').firstMatch(trimmedField);
      if (buMatch != null) {
        final barcodeHeight = int.parse(buMatch.group(1)!);
        final showText = buMatch.group(2) == 'Y';

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
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }

      // ^A (Font/Text) 파싱
      final textMatch = RegExp(r'\^A([0A-Z])N,(\d+),(\d+)').firstMatch(trimmedField);
      if (textMatch != null) {
        final fontCode = textMatch.group(1)!;
        final fontHeight = int.parse(textMatch.group(2)!);
        final fontWidth = int.parse(textMatch.group(3)!);

        // ^FB (Field Block) 파싱 - 멀티라인 텍스트용
        final fbMatch = RegExp(r'\^FB(\d+),(\d+)').firstMatch(trimmedField);
        int? maxLine;
        int fieldWidth = 100;
        if (fbMatch != null) {
          fieldWidth = int.parse(fbMatch.group(1)!);
          maxLine = int.parse(fbMatch.group(2)!);
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
        )..zIndex = zIndex++;
        elements.add(element);
        continue;
      }
    }

    return elements;
  }
}
