import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

/// Service for persisting and syncing user data with Cloud Firestore.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection Reference for Users
  CollectionReference<Map<String, dynamic>> get _usersCol => _db.collection('users');

  /// 1. Save or Update User Profile in Firestore: `users/{uid}`
  Future<void> saveUserProfile(UserProfile profile) async {
    if (profile.uid == null || profile.uid!.isEmpty) {
      debugPrint('[FirestoreService] No UID provided to save user profile.');
      return;
    }

    try {
      final docRef = _usersCol.doc(profile.uid);
      await docRef.set({
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phone,
        'photoUrl': profile.photoUrl,
        'uid': profile.uid,
        'isPro': profile.isPro,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[FirestoreService] User profile saved to Firestore: users/${profile.uid}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving user profile: $e');
    }
  }

  /// 2. Fetch User Profile
  Future<UserProfile?> fetchUserProfile(String uid) async {
    try {
      final doc = await _usersCol.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('[FirestoreService] Error fetching user profile: $e');
    }
    return null;
  }

  /// 3. Save or Update Product: `users/{uid}/products/{productId}`
  Future<void> saveProduct(String uid, ProductItem product) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('products').doc(product.id).set(
            product.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Product saved: ${product.name} (id: ${product.id})');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving product: $e');
    }
  }

  /// 4. Delete Product: `users/{uid}/products/{productId}`
  Future<void> deleteProduct(String uid, String productId) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('products').doc(productId).delete();
      debugPrint('[FirestoreService] Product deleted: $productId');
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting product: $e');
    }
  }

  /// 5. Fetch all Products for a user
  Future<List<ProductItem>> fetchProducts(String uid) async {
    if (uid.isEmpty) return [];
    try {
      final snapshot = await _usersCol.doc(uid).collection('products').get();
      return snapshot.docs.map((doc) => ProductItem.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('[FirestoreService] Error fetching products: $e');
      return [];
    }
  }

  /// 6. Save Expense: `users/{uid}/expenses/{expenseId}`
  Future<void> saveExpense(String uid, ExpenseRecord expense) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('expenses').doc(expense.id).set(
            expense.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Expense saved: ${expense.productName} - ₹${expense.amount}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving expense: $e');
    }
  }

  /// 7. Fetch all Expenses for a user
  Future<List<ExpenseRecord>> fetchExpenses(String uid) async {
    if (uid.isEmpty) return [];
    try {
      final snapshot = await _usersCol.doc(uid).collection('expenses').get();
      return snapshot.docs.map((doc) => ExpenseRecord.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('[FirestoreService] Error fetching expenses: $e');
      return [];
    }
  }

  /// 8. Save Claim: `users/{uid}/claims/{claimId}`
  Future<void> saveClaim(String uid, WarrantyClaim claim) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('claims').doc(claim.id).set(
            claim.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Claim saved: ${claim.ticketNumber}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving claim: $e');
    }
  }

  /// 8.1 Save Service: `users/{uid}/services/{serviceId}`
  Future<void> saveService(String uid, ServiceRecord service) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('services').doc(service.id).set(
            service.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Service record saved: ${service.serviceType}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving service record: $e');
    }
  }

  /// 9. Save Document / Invoice: `users/{uid}/documents/{docId}`
  Future<void> saveDocument(String uid, DocumentRecord docRecord) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('documents').doc(docRecord.id).set(
            docRecord.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Document saved: ${docRecord.name}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving document: $e');
    }
  }

  /// 10. Save AMC: `users/{uid}/amcs/{amcId}`
  Future<void> saveAMC(String uid, AMCRecord amc) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('amcs').doc(amc.id).set(
            amc.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] AMC saved: ${amc.productName}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving AMC: $e');
    }
  }

  /// 11. Initial Sync: Upload default items to Cloud Firestore if collection is empty
  Future<void> syncInitialDataIfEmpty(
    String uid, {
    required List<ProductItem> defaultProducts,
    required List<ExpenseRecord> defaultExpenses,
    required List<AMCRecord> defaultAMCs,
    required List<WarrantyClaim> defaultClaims,
    required List<DocumentRecord> defaultDocuments,
  }) async {
    if (uid.isEmpty) return;
    try {
      final existing = await _usersCol.doc(uid).collection('products').limit(1).get();
      if (existing.docs.isEmpty) {
        debugPrint('[FirestoreService] New user detected. Seeding initial data into Firestore...');
        final batch = _db.batch();

        for (final prod in defaultProducts) {
          final docRef = _usersCol.doc(uid).collection('products').doc(prod.id);
          batch.set(docRef, prod.toMap());
        }

        for (final exp in defaultExpenses) {
          final docRef = _usersCol.doc(uid).collection('expenses').doc(exp.id);
          batch.set(docRef, exp.toMap());
        }

        for (final amc in defaultAMCs) {
          final docRef = _usersCol.doc(uid).collection('amcs').doc(amc.id);
          batch.set(docRef, amc.toMap());
        }

        for (final clm in defaultClaims) {
          final docRef = _usersCol.doc(uid).collection('claims').doc(clm.id);
          batch.set(docRef, clm.toMap());
        }

        for (final doc in defaultDocuments) {
          final docRef = _usersCol.doc(uid).collection('documents').doc(doc.id);
          batch.set(docRef, doc.toMap());
        }

        await batch.commit();
        debugPrint('[FirestoreService] Seed data successfully committed to Firestore!');
      }
    } catch (e) {
      debugPrint('[FirestoreService] Error syncing initial data: $e');
    }
  }
}
