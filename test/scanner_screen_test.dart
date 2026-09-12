import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mydigi_app/providers/warranty_provider.dart';
import 'package:mydigi_app/models/product_model.dart';
import 'package:mydigi_app/models/scanned_bill.dart';
import 'package:mydigi_app/services/bill_scanner.dart';
import 'package:mydigi_app/services/local_bill_vault.dart';
import 'package:mydigi_app/screens/add_product_screen.dart';
import 'package:mydigi_app/screens/scanner_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeImagePicker extends ImagePicker {
  final sources = <ImageSource>[];
  Future<XFile?> Function()? capture;
  LostDataResponse? recovered;

  @override
  Future<LostDataResponse> retrieveLostData() async =>
      recovered ?? LostDataResponse.empty();

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    sources.add(source);
    expect(preferredCameraDevice, CameraDevice.rear);
    expect(requestFullMetadata, isFalse);
    return capture == null ? null : await capture!();
  }
}

class FakeBillVault extends LocalBillVault {
  final documents = <String, DocumentRecord>{};
  final photos = <String, Uint8List>{};
  bool failSave = false;
  Completer<void>? saveGate;
  int saveCalls = 0;

  @override
  Future<DocumentRecord> save({
    required String owner,
    required String id,
    required Uint8List photo,
    ProductItem? product,
  }) async {
    saveCalls++;
    if (saveGate != null) await saveGate!.future;
    if (failSave) throw StateError('Storage full');
    final document = DocumentRecord(
      id: id,
      productId: product?.id ?? '',
      productName: product?.name ?? 'Bill photo',
      name: 'Bill.png',
      type: 'Invoice',
      size: '${photo.length} B',
      uploadDate: '2026-09-12T12:00:00',
      isLocal: true,
      mimeType: 'image/png',
    );
    documents[id] = document;
    photos[id] = photo;
    return document;
  }

  @override
  Future<List<DocumentRecord>> load(String owner) async =>
      documents.values.toList();

  @override
  Future<Uint8List> readPhoto(String owner, String id) async => photos[id]!;
}

class FakeBillScanner extends BillScanner {
  Future<ScannedBill> Function()? recognize;
  @override
  bool get isSupported => true;
  @override
  Future<ScannedBill> scan(XFile photo) async =>
      recognize == null ? const ScannedBill() : await recognize!();
}

void main() {
  late WarrantyProvider provider;
  late FakeBillVault vault;
  late Uint8List billBytes;
  late FakeBillScanner scanner;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vault = FakeBillVault();
    provider = WarrantyProvider(billVault: vault);
    billBytes = img.encodePng(img.Image(width: 4, height: 4));
    scanner = FakeBillScanner();
  });

  tearDown(() {
    provider.dispose();
  });

  XFile billPhoto() =>
      XFile.fromData(billBytes, name: 'bill.png', mimeType: 'image/png');

  Future<void> openScanner(WidgetTester tester, FakeImagePicker picker) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          navigatorKey: navigator,
          home: const Scaffold(body: Text('Test Home')),
        ),
      ),
    );
    navigator.currentState!.push(
      MaterialPageRoute(
        builder: (_) =>
            ScannerScreen(imagePicker: picker, billScanner: scanner),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> waitForPhoto(WidgetTester tester) async {
    // Image codecs complete outside the widget tester's fake async clock.
    await tester.runAsync(() async {
      for (var attempt = 0; attempt < 100; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
        if (find
            .byKey(const ValueKey('bill-photo-preview'))
            .evaluate()
            .isNotEmpty) {
          return;
        }
      }
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bill-photo-preview')), findsOneWidget);
  }

  Future<void> waitForDetails(WidgetTester tester) async {
    await tester.runAsync(() async {
      for (var attempt = 0; attempt < 100; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
        if (find.byType(AddProductScreen).evaluate().isNotEmpty) return;
      }
    });
    await tester.pumpAndSettle();
    expect(find.byType(AddProductScreen), findsOneWidget);
  }

  testWidgets('Scan Bill opens the real camera API; cancel allows retry', (
    tester,
  ) async {
    final picker = FakeImagePicker();
    await openScanner(tester, picker);
    await tester.pumpAndSettle();
    expect(picker.sources, [ImageSource.camera]);
    expect(find.byKey(const ValueKey('enter-bill-details')), findsNothing);
    expect(provider.products, isEmpty);

    await tester.tap(find.byKey(const ValueKey('open-bill-camera')));
    await tester.pumpAndSettle();
    expect(picker.sources, [ImageSource.camera, ImageSource.camera]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'permission denial shows recovery instructions and allows retry',
    (tester) async {
      final picker = FakeImagePicker()
        ..capture = () async =>
            throw PlatformException(code: 'camera_access_denied');
      await openScanner(tester, picker);
      await tester.pumpAndSettle();
      expect(find.textContaining('Allow access in Settings'), findsOneWidget);
      expect(find.byKey(const ValueKey('enter-bill-details')), findsNothing);

      picker.capture = () async => billPhoto();
      await tester.tap(find.byKey(const ValueKey('open-bill-camera')));
      await waitForPhoto(tester);
      expect(find.byKey(const ValueKey('camera-error')), findsNothing);
    },
  );

  testWidgets('captured photo is used for manual review without sample data', (
    tester,
  ) async {
    final picker = FakeImagePicker()..capture = () async => billPhoto();
    await openScanner(tester, picker);
    await waitForPhoto(tester);
    final image = tester.widget<Image>(
      find.byKey(const ValueKey('bill-photo-preview')),
    );
    expect((image.image as MemoryImage).bytes, billBytes);
    expect(find.text('LG Refrigerator Invoice'), findsNothing);
    expect(provider.products, isEmpty);

    await tester.tap(find.byKey(const ValueKey('enter-bill-details')));
    await tester.pumpAndSettle();
    expect(find.byType(AddProductScreen), findsOneWidget);
    expect(
      tester.widget<AddProductScreen>(find.byType(AddProductScreen)).billPhoto,
      billBytes,
    );
    expect(
      find.text('LG Frost-Free Double Door Refrigerator 360L'),
      findsNothing,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bill-photo-preview')), findsOneWidget);
  });

  testWidgets('canceling a retake preserves the captured photo', (
    tester,
  ) async {
    final picker = FakeImagePicker()..capture = () async => billPhoto();
    await openScanner(tester, picker);
    await waitForPhoto(tester);
    picker.capture = () async => null;
    await tester.tap(find.byKey(const ValueKey('open-bill-camera')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bill-photo-preview')), findsOneWidget);
    expect(find.byKey(const ValueKey('enter-bill-details')), findsOneWidget);
  });

  testWidgets(
    'recovers a photo after Android activity restart without recapturing',
    (tester) async {
      final picker = FakeImagePicker()
        ..recovered = LostDataResponse(
          files: [billPhoto()],
          type: RetrieveType.image,
        );
      await openScanner(tester, picker);
      await waitForPhoto(tester);
      expect(picker.sources, isEmpty);
    },
  );

  testWidgets('supports gallery selection after canceling the camera', (
    tester,
  ) async {
    final picker = FakeImagePicker();
    await openScanner(tester, picker);
    await tester.pumpAndSettle();
    picker.capture = () async => billPhoto();
    await tester.tap(find.byKey(const ValueKey('choose-bill-photo')));
    await waitForPhoto(tester);
    expect(picker.sources, [ImageSource.camera, ImageSource.gallery]);
  });

  testWidgets(
    'save waits for persistence, prevents duplicate taps, and opens the stored photo',
    (tester) async {
      final picker = FakeImagePicker()..capture = () async => billPhoto();
      await openScanner(tester, picker);
      await waitForPhoto(tester);
      vault.saveGate = Completer<void>();
      await tester.tap(find.byKey(const ValueKey('save-bill-photo')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('save-bill-photo')));
      expect(vault.saveCalls, 1);
      expect(provider.documents, isEmpty);
      vault.saveGate!.complete();
      await tester.pumpAndSettle();
      expect(provider.documents, hasLength(1));
      expect(find.text('Open Vault'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('save-bill-photo')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('View bill'));
      await tester.pumpAndSettle();
      final image = tester.widget<Image>(
        find.byKey(const ValueKey('saved-bill-photo')),
      );
      expect((image.image as MemoryImage).bytes, billBytes);
    },
  );

  testWidgets(
    'failed photo save keeps the photo and permits a successful retry',
    (tester) async {
      vault.failSave = true;
      final picker = FakeImagePicker()..capture = () async => billPhoto();
      await openScanner(tester, picker);
      await waitForPhoto(tester);
      await tester.tap(find.byKey(const ValueKey('save-bill-photo')));
      await tester.pumpAndSettle();
      expect(provider.documents, isEmpty);
      expect(find.textContaining('Could not save the photo'), findsOneWidget);
      expect(find.byKey(const ValueKey('bill-photo-preview')), findsOneWidget);
      vault.failSave = false;
      await tester.tap(find.byKey(const ValueKey('save-bill-photo')));
      await tester.pumpAndSettle();
      expect(provider.documents, hasLength(1));
    },
  );

  testWidgets(
    'product save attaches the photo and preserves entered details when persistence fails',
    (tester) async {
      vault.failSave = true;
      final picker = FakeImagePicker()..capture = () async => billPhoto();
      await openScanner(tester, picker);
      await waitForPhoto(tester);
      await tester.tap(find.byKey(const ValueKey('enter-bill-details')));
      await tester.pumpAndSettle();
      for (final entry in {
        'Product Title / Name *': 'Test Fridge',
        'Brand *': 'Test Brand',
        'Purchase Price (₹) *': '500',
      }.entries) {
        final field = find.byKey(ValueKey('product-field-${entry.key}'));
        await tester.ensureVisible(field);
        await tester.enterText(field, entry.value);
      }
      final save = find.byKey(const ValueKey('save-product'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(provider.products, isEmpty);
      expect(provider.documents, isEmpty);
      expect(find.byType(AddProductScreen), findsOneWidget);
      expect(find.text('Test Fridge'), findsOneWidget);
      vault.failSave = false;
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(provider.products, hasLength(1));
      expect(provider.documents, hasLength(1));
      expect(provider.documents.single.productId, provider.products.single.id);
      expect(
        await provider.readBillPhoto(provider.documents.single),
        billBytes,
      );
      expect(find.text('Test Home'), findsOneWidget);
    },
  );

  testWidgets(
    'late camera result after leaving the screen does not update disposed state',
    (tester) async {
      final result = Completer<XFile?>();
      final picker = FakeImagePicker()..capture = () => result.future;
      await openScanner(tester, picker);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      result.complete(billPhoto());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(provider.products, isEmpty);
    },
  );

  testWidgets(
    'scan automatically opens filled fields and saves the corrected amount with the photo',
    (tester) async {
      scanner.recognize = () async => ScannedBill(
        rawText:
            'Product: Test Fridge\nBrand: Test Brand\nGrand Total: 1250.75',
        productName: 'Test Fridge',
        brand: 'Test Brand',
        invoiceNumber: 'REAL-42',
        purchaseDate: DateTime(2026, 9, 1),
        amount: 1250.75,
        amountIsBillTotal: true,
      );
      await openScanner(
        tester,
        FakeImagePicker()..capture = () async => billPhoto(),
      );
      await waitForDetails(tester);
      expect(find.text('Details filled from your photo'), findsOneWidget);
      expect(find.byKey(const ValueKey('bill-photo-preview')), findsNothing);
      expect(provider.products, isEmpty);
      expect(find.byKey(const ValueKey('bill-total-notice')), findsOneWidget);
      for (final entry in {
        'Product Title / Name *': 'Test Fridge',
        'Brand *': 'Test Brand',
        'Purchase Price (₹) *': '1250.75',
      }.entries) {
        final field = find.byKey(ValueKey('product-field-${entry.key}'));
        await tester.ensureVisible(field);
        expect(
          tester.widget<TextFormField>(field).controller!.text,
          entry.value,
        );
      }
      final priceField = find.byKey(
        const ValueKey('product-field-Purchase Price (₹) *'),
      );
      await tester.enterText(priceField, '1,199.50');
      final save = find.byKey(const ValueKey('save-product'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(provider.products.single.purchasePrice, 1199.50);
      expect(provider.products.single.invoiceNumber, 'REAL-42');
      expect(provider.products.single.purchaseDate, '1 Sep 2026');
      expect(provider.documents.single.productId, provider.products.single.id);
    },
  );

  testWidgets(
    'recognition failure keeps photo, allows retry and manual entry',
    (tester) async {
      scanner.recognize = () async =>
          throw PlatformException(code: 'ocr_failed');
      await openScanner(
        tester,
        FakeImagePicker()..capture = () async => billPhoto(),
      );
      await waitForPhoto(tester);
      expect(find.textContaining('Could not read the bill'), findsOneWidget);
      scanner.recognize = () async => const ScannedBill(amount: 500);
      await tester.tap(find.byKey(const ValueKey('retry-bill-reading')));
      await tester.pumpAndSettle();
      expect(find.byType(AddProductScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('retry-bill-reading')), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('bill-photo-preview')), findsOneWidget);
    },
  );

  for (final source in ['gallery', 'recovered camera']) {
    testWidgets(
      '$source opens detected values once; retake uses the new image values',
      (tester) async {
        scanner.recognize = () async =>
            const ScannedBill(productName: 'First Bill', amount: 500);
        final picker = FakeImagePicker();
        if (source == 'recovered camera') {
          picker.recovered = LostDataResponse(
            files: [billPhoto()],
            type: RetrieveType.image,
          );
        }
        await openScanner(tester, picker);
        if (source == 'gallery') {
          await tester.pumpAndSettle();
          picker.capture = () async => billPhoto();
          await tester.tap(find.byKey(const ValueKey('choose-bill-photo')));
        }
        await waitForDetails(tester);
        final name = find.byKey(
          const ValueKey('product-field-Product Title / Name *'),
        );
        expect(
          tester.widget<TextFormField>(name).controller!.text,
          'First Bill',
        );
        await tester.pageBack();
        await tester.pumpAndSettle();
        // Provider rebuilds and waiting on the photo must not reopen the form.
        provider.toggleTheme();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(AddProductScreen), findsNothing);
        expect(
          find.byKey(const ValueKey('bill-photo-preview')),
          findsOneWidget,
        );
        scanner.recognize = () async =>
            const ScannedBill(productName: 'Second Bill', amount: 700);
        picker.capture = () async => billPhoto();
        await tester.tap(find.byKey(const ValueKey('open-bill-camera')));
        await waitForDetails(tester);
        expect(
          tester.widget<TextFormField>(name).controller!.text,
          'Second Bill',
        );
        expect(provider.products, isEmpty);
        expect(provider.documents, isEmpty);
      },
    );
  }

  testWidgets('leaving during recognition safely ignores the late result', (
    tester,
  ) async {
    final result = Completer<ScannedBill>();
    scanner.recognize = () => result.future;
    await openScanner(
      tester,
      FakeImagePicker()..capture = () async => billPhoto(),
    );
    await tester.runAsync(() async {
      for (var attempt = 0; attempt < 100; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
        if (find.byKey(const ValueKey('bill-reading')).evaluate().isNotEmpty) {
          return;
        }
      }
    });
    expect(find.byKey(const ValueKey('bill-reading')), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    result.complete(const ScannedBill(amount: 1250));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
