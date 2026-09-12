import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:mydigi_app/models/product_model.dart';
import 'package:mydigi_app/providers/warranty_provider.dart';
import 'package:mydigi_app/services/local_bill_vault.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProductItem testProduct() => ProductItem(
  id: 'product-1',
  name: 'Test refrigerator',
  category: 'Appliances',
  brand: 'Test',
  modelNumber: 'R1',
  serialNumber: 'S1',
  purchaseDate: '12 Sep 2026',
  purchasePrice: 100,
  sellerName: 'Store',
  invoiceNumber: 'INV-1',
  warrantyPeriod: '1 Year',
  warrantyStartDate: '12 Sep 2026',
  warrantyEndDate: '12 Sep 2027',
  warrantyStatus: 'Active',
  daysRemaining: 365,
  imageUrl: '',
  costBreakdown: CostBreakdown(purchase: 100),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late LocalBillVault vault;
  late Uint8List photo;

  LocalBillVault newVault() => LocalBillVault(
    openBox: () => Hive.openLazyBox<Map>('test_bills', path: directory.path),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('mydigi-vault-');
    vault = newVault();
    photo = img.encodePng(img.Image(width: 8, height: 8));
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'photo bytes and attachment metadata survive closing and reopening storage',
    () async {
      final saved = await vault.save(
        owner: 'alice',
        id: 'bill-1',
        photo: photo,
        product: testProduct(),
      );
      await Hive.close();
      vault = newVault();
      final restored = await vault.load('alice');
      expect(restored.single.toMap(), saved.toMap());
      expect(restored.single.productId, 'product-1');
      expect(restored.single.isLocal, isTrue);
      expect(restored.single.mimeType, 'image/png');
      expect(restored.single.name, endsWith('.png'));
      expect(await vault.readPhoto('alice', 'bill-1'), photo);
    },
  );

  test(
    'one account cannot list, read, overwrite or delete another account photo',
    () async {
      await vault.save(owner: 'alice', id: 'same-id', photo: photo);
      expect(await vault.load('bob'), isEmpty);
      await expectLater(vault.readPhoto('bob', 'same-id'), throwsStateError);
      final otherPhoto = img.encodeJpg(img.Image(width: 5, height: 5));
      await vault.save(owner: 'bob', id: 'same-id', photo: otherPhoto);
      await vault.delete('bob', 'same-id');
      expect(await vault.readPhoto('alice', 'same-id'), photo);
      expect(await vault.load('bob'), isEmpty);
    },
  );

  test(
    'saving a previously saved capture with product details updates one record',
    () async {
      await vault.save(owner: 'alice', id: 'capture-id', photo: photo);
      await vault.save(
        owner: 'alice',
        id: 'capture-id',
        photo: photo,
        product: testProduct(),
      );
      final docs = await vault.load('alice');
      expect(docs, hasLength(1));
      expect(docs.single.productId, 'product-1');
      expect(await vault.readPhoto('alice', 'capture-id'), photo);
    },
  );

  test('invalid or oversized photos do not create vault entries', () async {
    await expectLater(
      vault.save(owner: 'alice', id: 'empty', photo: Uint8List(0)),
      throwsFormatException,
    );
    await expectLater(
      vault.save(
        owner: 'alice',
        id: 'invalid',
        photo: Uint8List.fromList([1, 2, 3]),
      ),
      throwsFormatException,
    );
    await expectLater(
      vault.save(
        owner: 'alice',
        id: 'large',
        photo: Uint8List(LocalBillVault.maxPhotoBytes + 1),
      ),
      throwsFormatException,
    );
    expect(await vault.load('alice'), isEmpty);
  });

  test(
    'failed persistence does not report a saved photo in provider state',
    () async {
      final broken = LocalBillVault(
        openBox: () async => throw const FileSystemException('disk full'),
      );
      final provider = WarrantyProvider(billVault: broken);
      await expectLater(
        provider.saveBillPhoto(photo),
        throwsA(isA<FileSystemException>()),
      );
      expect(provider.documents, isEmpty);
      provider.dispose();
    },
  );

  test(
    'provider restores guest vault after restart and attaches only the actual photo',
    () async {
      var provider = WarrantyProvider(billVault: vault);
      final product = testProduct();
      await provider.saveBillPhoto(
        photo,
        product: product,
        documentId: 'bill-1',
      );
      provider.addProduct(product);
      expect(provider.documents, hasLength(1));
      provider.dispose();
      await Hive.close();

      provider = WarrantyProvider(billVault: newVault());
      await provider.loadLocalBills();
      expect(provider.documents.single.productId, product.id);
      expect(await provider.readBillPhoto(provider.documents.single), photo);
      await provider.deleteDocument('bill-1');
      expect(provider.documents, isEmpty);
      provider.dispose();
      await Hive.close();
      expect(await newVault().load('guest_user'), isEmpty);
    },
  );

  test('older metadata-only documents remain readable without new fields', () {
    final document = DocumentRecord.fromMap({
      'id': 'legacy',
      'name': 'Invoice.pdf',
    });
    expect(document.isLocal, isFalse);
    expect(document.previewUrl, isNull);
    expect(document.mimeType, isNull);
  });
}
