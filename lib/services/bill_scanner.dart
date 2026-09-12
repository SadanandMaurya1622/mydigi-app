import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../models/scanned_bill.dart';
import 'bill_details_parser.dart';

class BillScanner {
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<ScannedBill> scan(XFile photo) async {
    if (!isSupported) {
      throw UnsupportedError('Bill scanning requires Android or iOS');
    }
    final recognizer = TextRecognizer();
    try {
      final result = await recognizer
          .processImage(InputImage.fromFilePath(photo.path))
          .timeout(const Duration(seconds: 30));
      return BillDetailsParser().parse(readingOrder(result));
    } finally {
      await recognizer.close();
    }
  }

  /// ML Kit may report a price column separately from its labels. Join lines
  /// sharing a row before parsing, so "Grand total" stays with its amount.
  @visibleForTesting
  static String readingOrder(RecognizedText result) {
    final lines = result.blocks.expand((block) => block.lines).toList()
      ..sort(
        (a, b) => a.boundingBox.center.dy.compareTo(b.boundingBox.center.dy),
      );
    if (lines.isEmpty) return result.text;
    final rows = <List<TextLine>>[];
    for (final line in lines) {
      final previous = rows.isEmpty ? null : rows.last.first;
      if (previous != null &&
          (line.boundingBox.center.dy - previous.boundingBox.center.dy).abs() <
              math.min(line.boundingBox.height, previous.boundingBox.height) *
                  0.6) {
        rows.last.add(line);
      } else {
        rows.add([line]);
      }
    }
    return rows
        .map((row) {
          row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
          return row.map((line) => line.text).join(' ');
        })
        .join('\n');
  }
}
