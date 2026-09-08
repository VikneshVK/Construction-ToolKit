import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildcalc/core/components/icons/buildcalc_app_logo.dart';

void main() {
  test('Generate 1024x1024 Master App Icon PNG directly via Canvas', () async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 1024, 1024));

    // 1. Solid matte void background
    final bgPaint = Paint()..color = const Color(0xFF0F1115);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1024, 1024), bgPaint);

    // 2. Inner rounded container with subtle gold border and shadow
    final containerRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(112, 112, 800, 800),
      const Radius.circular(190),
    );

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawRRect(containerRect.shift(const Offset(0, 14)), shadowPaint);

    // Container surface
    final containerPaint = Paint()..color = const Color(0xFF13171E);
    canvas.drawRRect(containerRect, containerPaint);

    // Gold edge border
    final borderPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawRRect(containerRect, borderPaint);

    // 3. Render the BuildCalc emblem centered inside
    // Target logo size: 560x560
    const logoSize = 560.0;
    const offset = (1024.0 - logoSize) / 2.0;

    canvas.save();
    canvas.translate(offset, offset);
    BuildCalcLogoPainter().paint(canvas, const Size(logoSize, logoSize));
    canvas.restore();

    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final file = File('assets/icon/app_icon.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(pngBytes);

    expect(await file.exists(), isTrue);
    expect(file.lengthSync(), greaterThan(5000));
  });

  test('Generate 1024x1024 Adaptive Icon Foreground PNG', () async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 1024, 1024));

    // Transparent background, logo centered within safe 512x512 zone
    const logoSize = 512.0;
    const offset = (1024.0 - logoSize) / 2.0;

    canvas.save();
    canvas.translate(offset, offset);
    BuildCalcLogoPainter().paint(canvas, const Size(logoSize, logoSize));
    canvas.restore();

    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final file = File('assets/icon/app_icon_foreground.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(pngBytes);

    expect(await file.exists(), isTrue);
    expect(file.lengthSync(), greaterThan(1000));
  });
}
