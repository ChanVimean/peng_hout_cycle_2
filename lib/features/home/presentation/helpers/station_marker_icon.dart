import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Renders a station marker as a bitmap: a rounded "pill" showing [label]
/// sitting above a colored map pin. The pin's tip is at the bottom-center of
/// the image, so the default marker anchor (0.5, 1.0) points to the location.
///
/// [scale] is the pixel density used while rasterizing; it is passed back as
/// `imagePixelRatio` so the marker is displayed at a crisp, logical size.
Future<BitmapDescriptor> createStationMarkerBitmap({
  required String label,
  required Color color,
  double scale = 3.0,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final textPainter = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 13 * scale,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: 160 * scale);

  final hPad = 10 * scale;
  final vPad = 6 * scale;
  final pillWidth = textPainter.width + hPad * 2;
  final pillHeight = textPainter.height + vPad * 2;

  final pinRadius = 8 * scale;
  final pinTailHeight = 8 * scale;
  final gap = 4 * scale;
  final topMargin = 2 * scale;
  final pinDiameter = pinRadius * 2;

  final contentWidth = pillWidth > pinDiameter ? pillWidth : pinDiameter;
  final totalWidth = contentWidth;
  final centerX = totalWidth / 2;

  final pinCenterY = topMargin + pillHeight + gap + pinRadius;
  final tipY = pinCenterY + pinRadius + pinTailHeight;
  final totalHeight = tipY;

  // Pill.
  final pillLeft = centerX - pillWidth / 2;
  final pillRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(pillLeft, topMargin, pillWidth, pillHeight),
    Radius.circular(pillHeight / 2),
  );
  canvas.drawShadow(
    Path()..addRRect(pillRect),
    Colors.black54,
    2 * scale,
    false,
  );
  canvas.drawRRect(pillRect, Paint()..color = Colors.white);
  canvas.drawRRect(
    pillRect,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale
      ..color = color,
  );
  textPainter.paint(canvas, Offset(pillLeft + hPad, topMargin + vPad));

  // Pin (circle + pointed tail) below the pill.
  final pinCenter = Offset(centerX, pinCenterY);
  final pinPaint = Paint()..color = color;
  final tail = Path()
    ..moveTo(centerX - pinRadius * 0.7, pinCenterY + pinRadius * 0.4)
    ..lineTo(centerX, tipY)
    ..lineTo(centerX + pinRadius * 0.7, pinCenterY + pinRadius * 0.4)
    ..close();
  canvas.drawPath(tail, pinPaint);
  canvas.drawCircle(pinCenter, pinRadius, pinPaint);
  canvas.drawCircle(pinCenter, pinRadius * 0.4, Paint()..color = Colors.white);

  final image = await recorder.endRecording().toImage(
    totalWidth.ceil(),
    totalHeight.ceil(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(
    byteData!.buffer.asUint8List(),
    imagePixelRatio: scale,
  );
}
