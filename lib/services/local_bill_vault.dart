import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/product_model.dart';

/// Stores each photo and its metadata together in permanent app storage.
/// On web Hive uses IndexedDB. Local records are never sent to Firebase.
class LocalBillVault {
  LocalBillVault({Future<LazyBox<Map>> Function()? openBox})
    : _boxOpener = openBox;

  final Future<LazyBox<Map>> Function()? _boxOpener;
  Future<LazyBox<Map>>? _opening;
  static Future<void>? _initialization;
  static const maxPhotoBytes = 20 * 1024 * 1024;

  Future<LazyBox<Map>> _box() async {
    try {
      return await (_opening ??= _open());
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<LazyBox<Map>> _open() async {
    if (_boxOpener != null) return _boxOpener();
    try {
      await (_initialization ??= Hive.initFlutter('mydigi_vault'));
    } catch (_) {
      _initialization = null;
      rethrow;
    }
    return Hive.openLazyBox<Map>('bill_photos_v1');
  }

  String _prefix(String owner) => '${sha256.convert(utf8.encode(owner))}:';

  static String newId() {
    final random = Random.secure();
    final suffix = List.generate(
      12,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return 'bill-${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }

  Future<DocumentRecord> save({
    required String owner,
    required String id,
    required Uint8List photo,
    ProductItem? product,
  }) async {
    if (photo.isEmpty || photo.length > maxPhotoBytes) {
      throw const FormatException('Choose a photo smaller than 20 MB.');
    }
    final (extension, mimeType) = _format(photo);
    final now = DateTime.now();
    final document = DocumentRecord(
      id: id,
      productId: product?.id ?? '',
      productName: product?.name ?? 'Bill photo',
      name:
          'Bill_${now.toIso8601String().replaceAll(RegExp(r'[:.]'), '-')}.$extension',
      type: 'Invoice',
      size: photo.length < 1024 * 1024
          ? '${(photo.length / 1024).ceil()} KB'
          : '${(photo.length / (1024 * 1024)).toStringAsFixed(1)} MB',
      uploadDate: now.toIso8601String(),
      isLocal: true,
      mimeType: mimeType,
    );
    final box = await _box();
    // A single database entry prevents metadata from pointing at a missing
    // separately written file. Await the disk flush before reporting success.
    await box.put('${_prefix(owner)}$id', {
      'document': document.toMap(),
      'photo': Uint8List.fromList(photo),
    });
    await box.flush();
    return document;
  }

  Future<List<DocumentRecord>> load(String owner) async {
    final box = await _box();
    final prefix = _prefix(owner);
    final documents = <DocumentRecord>[];
    final keys = box.keys
        .whereType<String>()
        .where((key) => key.startsWith(prefix))
        .toList();
    for (final key in keys) {
      final record = await box.get(key);
      if (record == null) continue;
      documents.add(
        DocumentRecord.fromMap(
          Map<String, dynamic>.from(record['document'] as Map),
        ),
      );
    }
    documents.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
    return documents;
  }

  Future<Uint8List> readPhoto(String owner, String id) async {
    final box = await _box();
    final record = await box.get('${_prefix(owner)}$id');
    final photo = record?['photo'];
    if (photo is! Uint8List || photo.isEmpty) {
      throw StateError('This photo is not available on this device.');
    }
    return Uint8List.fromList(photo);
  }

  Future<void> delete(String owner, String id) async {
    final box = await _box();
    await box.delete('${_prefix(owner)}$id');
    await box.flush();
  }

  static (String, String) _format(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 137 &&
        ascii.decode(bytes.sublist(1, 4), allowInvalid: true) == 'PNG') {
      return ('png', 'image/png');
    }
    if (bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255) {
      return ('jpg', 'image/jpeg');
    }
    if (bytes.length >= 12) {
      final header = ascii.decode(bytes.sublist(0, 12), allowInvalid: true);
      if (header.startsWith('RIFF') && header.endsWith('WEBP')) {
        return ('webp', 'image/webp');
      }
      if (header.startsWith('GIF8')) return ('gif', 'image/gif');
      if (header.contains('ftyphei')) return ('heic', 'image/heic');
    }
    throw const FormatException(
      'Please choose a JPEG, PNG, WebP, GIF or HEIC photo.',
    );
  }
}
