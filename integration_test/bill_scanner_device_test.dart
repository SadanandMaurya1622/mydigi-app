import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mydigi_app/services/bill_scanner.dart';
import 'package:mydigi_app/providers/warranty_provider.dart';
import 'package:mydigi_app/screens/add_product_screen.dart';
import 'package:mydigi_app/screens/scanner_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class _FixtureImagePicker extends ImagePicker {
  _FixtureImagePicker(this.photo);
  final XFile photo;

  @override
  Future<LostDataResponse> retrieveLostData() async => LostDataResponse.empty();

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async => photo;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'image values automatically appear in the form using native OCR',
    (tester) async {
      // Synthetic receipt: does not open the camera or modify a user's vault.
      final directory = await Directory(
        '${(await getTemporaryDirectory()).path}/bill-ocr-test',
      ).create();
      final file = File('${directory.path}/receipt.png');
      final provider = WarrantyProvider();
      try {
        final receipt = img.Image(width: 1200, height: 1000);
        img.fill(receipt, color: img.ColorRgb8(255, 255, 255));
        const lines = [
          'TEST ELECTRONICS',
          'TAX INVOICE',
          'Invoice No: TEST-12345',
          'Invoice Date: 12/09/2026',
          'Product Name: Samsung Refrigerator',
          'Brand: Samsung',
          'Model No: RT28',
          'Subtotal: 1000.00',
          'Tax: 180.00',
          'Grand Total: 1180.50',
        ];
        for (var i = 0; i < lines.length; i++) {
          img.drawString(
            receipt,
            lines[i],
            font: img.arial48,
            x: 50,
            y: 40 + i * 86,
            color: img.ColorRgb8(0, 0, 0),
          );
        }
        await file.writeAsBytes(img.encodePng(receipt));
        final bill = await BillScanner().scan(XFile(file.path));
        expect(bill.invoiceNumber, 'TEST-12345');
        expect(bill.purchaseDate, DateTime(2026, 9, 12));
        expect(bill.productName, 'Samsung Refrigerator');
        expect(bill.brand, 'Samsung');
        expect(bill.amount, 1180.50);
        expect(bill.amountIsBillTotal, isTrue);

        // Use the real scanner screen and native OCR. Only camera input is
        // supplied by the fixture; there is no tap on Review Bill Details.
        final navigator = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: provider,
            child: MaterialApp(
              navigatorKey: navigator,
              home: const Scaffold(body: Text('Bill scan test')),
            ),
          ),
        );
        navigator.currentState!.push(
          MaterialPageRoute(
            builder: (_) => ScannerScreen(
              imagePicker: _FixtureImagePicker(XFile(file.path)),
            ),
          ),
        );
        for (var attempt = 0; attempt < 200; attempt++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (find.byType(AddProductScreen).evaluate().isNotEmpty) break;
        }
        await tester.pumpAndSettle();
        expect(find.byType(AddProductScreen), findsOneWidget);
        for (final entry in {
          'Product Title / Name *': 'Samsung Refrigerator',
          'Brand *': 'Samsung',
          'Purchase Price (₹) *': '1180.50',
        }.entries) {
          final field = find.byKey(ValueKey('product-field-${entry.key}'));
          expect(
            tester.widget<TextFormField>(field).controller!.text,
            entry.value,
          );
        }
        expect(provider.products, isEmpty);
        expect(provider.documents, isEmpty);
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      } finally {
        provider.dispose();
        await directory.delete(recursive: true);
      }
    },
  );
}
