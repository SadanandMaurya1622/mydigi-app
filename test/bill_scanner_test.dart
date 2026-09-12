import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mydigi_app/services/bill_scanner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('google_mlkit_text_recognizer');
  final calls = <MethodCall>[];
  var fail = false;
  setUp(() {
    calls.clear();
    fail = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'vision#startTextRecognizer') {
            if (fail) throw PlatformException(code: 'unreadable_image');
            return {
              'text': 'Invoice No: REAL-123\nGrand Total: 1,250.75',
              'blocks': [],
            };
          }
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  test(
    'passes captured file to native OCR, parses results and closes recognizer',
    () async {
      final result = await BillScanner().scan(
        XFile('/tmp/mydigi-test-bill.png'),
      );
      expect(
        calls.first.arguments['imageData']['path'],
        '/tmp/mydigi-test-bill.png',
      );
      expect(result.invoiceNumber, 'REAL-123');
      expect(result.amount, 1250.75);
      expect(calls.last.method, 'vision#closeTextRecognizer');
    },
  );

  test('releases native resources after recognition failure', () async {
    fail = true;
    await expectLater(
      BillScanner().scan(XFile('/tmp/bad-photo.png')),
      throwsA(isA<PlatformException>()),
    );
    expect(calls.last.method, 'vision#closeTextRecognizer');
  });

  test('pairs total and amount even when ML Kit reports separate columns', () {
    TextLine line(String value, double x, double y) => TextLine(
      text: value,
      elements: [],
      boundingBox: Rect.fromLTWH(x, y, 100, 20),
      recognizedLanguages: [],
      cornerPoints: [],
      confidence: null,
      angle: null,
    );
    TextBlock block(TextLine line) => TextBlock(
      text: line.text,
      lines: [line],
      boundingBox: line.boundingBox,
      recognizedLanguages: [],
      cornerPoints: [],
    );
    final text = BillScanner.readingOrder(
      RecognizedText(
        text: 'wrong block order',
        blocks: [
          block(line('1250.75', 400, 80)),
          block(line('Grand Total:', 20, 78)),
          block(line('TEST STORE', 20, 10)),
        ],
      ),
    );
    expect(text, 'TEST STORE\nGrand Total: 1250.75');
  });
}
