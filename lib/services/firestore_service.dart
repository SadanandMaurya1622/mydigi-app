import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

/// Service for persisting and syncing 100% pure real-time data with Cloud Firestore.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Collection Reference for Users: /users
  CollectionReference<Map<String, dynamic>> get _usersCol => _db.collection('users');

  // ==========================================
  // 1. User Profile
  // ==========================================

  /// Save or Update User Profile in Firestore: `users/{uid}`
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

  /// Fetch User Profile once
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

  // ==========================================
  // 2. Real-Time Streams (Live Sync from Firebase)
  // ==========================================

  /// Stream of Products from `users/{uid}/products`
  Stream<List<ProductItem>> streamProducts(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _usersCol.doc(uid).collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductItem.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Stream of Expenses from `users/{uid}/expenses`
  Stream<List<ExpenseRecord>> streamExpenses(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _usersCol.doc(uid).collection('expenses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ExpenseRecord.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Stream of Services from `users/{uid}/services`
  Stream<List<ServiceRecord>> streamServices(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _usersCol.doc(uid).collection('services').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ServiceRecord.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Stream of Documents from `users/{uid}/documents`
  Stream<List<DocumentRecord>> streamDocuments(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _usersCol.doc(uid).collection('documents').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DocumentRecord.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Stream of AMCs from `users/{uid}/amcs`
  Stream<List<AMCRecord>> streamAMCs(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _usersCol.doc(uid).collection('amcs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AMCRecord.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Stream of Insurance from `users/{uid}/insurance`
  Stream<List<InsurancePolicy>> streamInsurance(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _usersCol.doc(uid).collection('insurance').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => InsurancePolicy.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Stream of Claims from `users/{uid}/claims`
  Stream<List<WarrantyClaim>> streamClaims(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _usersCol.doc(uid).collection('claims').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => WarrantyClaim.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Stream of Family Members from `users/{uid}/family`
  Stream<List<FamilyMember>> streamFamilyMembers(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _usersCol.doc(uid).collection('family').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FamilyMember.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Stream of Notifications from `users/{uid}/notifications`
  Stream<List<AppNotification>> streamNotifications(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _usersCol.doc(uid).collection('notifications').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppNotification.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // ==========================================
  // 3. Create, Update & Delete Mutations (Firebase Operations)
  // ==========================================

  /// Save Product: `users/{uid}/products/{productId}`
  Future<void> saveProduct(String uid, ProductItem product) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('products').doc(product.id).set(
            product.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Product saved to Firebase: ${product.name} (id: ${product.id})');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving product: $e');
    }
  }

  /// Delete Product: `users/{uid}/products/{productId}`
  Future<void> deleteProduct(String uid, String productId) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('products').doc(productId).delete();
      debugPrint('[FirestoreService] Product deleted from Firebase: $productId');
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting product: $e');
    }
  }

  /// Save Expense: `users/{uid}/expenses/{expenseId}`
  Future<void> saveExpense(String uid, ExpenseRecord expense) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('expenses').doc(expense.id).set(
            expense.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Expense saved to Firebase: ₹${expense.amount}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving expense: $e');
    }
  }

  /// Delete Expense: `users/{uid}/expenses/{expenseId}`
  Future<void> deleteExpense(String uid, String expenseId) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('expenses').doc(expenseId).delete();
      debugPrint('[FirestoreService] Expense deleted from Firebase: $expenseId');
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting expense: $e');
    }
  }

  /// Save Service: `users/{uid}/services/{serviceId}`
  Future<void> saveService(String uid, ServiceRecord service) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('services').doc(service.id).set(
            service.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Service record saved to Firebase: ${service.serviceType}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving service record: $e');
    }
  }

  /// Delete Service: `users/{uid}/services/{serviceId}`
  Future<void> deleteService(String uid, String serviceId) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('services').doc(serviceId).delete();
      debugPrint('[FirestoreService] Service record deleted from Firebase: $serviceId');
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting service record: $e');
    }
  }

  /// Save Claim: `users/{uid}/claims/{claimId}`
  Future<void> saveClaim(String uid, WarrantyClaim claim) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('claims').doc(claim.id).set(
            claim.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Claim saved to Firebase: ${claim.ticketNumber}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving claim: $e');
    }
  }

  /// Delete Claim: `users/{uid}/claims/{claimId}`
  Future<void> deleteClaim(String uid, String claimId) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('claims').doc(claimId).delete();
      debugPrint('[FirestoreService] Claim deleted from Firebase: $claimId');
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting claim: $e');
    }
  }

  /// Save Document: `users/{uid}/documents/{docId}`
  Future<void> saveDocument(String uid, DocumentRecord docRecord) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('documents').doc(docRecord.id).set(
            docRecord.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Document saved to Firebase: ${docRecord.name}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving document: $e');
    }
  }

  /// Delete Document: `users/{uid}/documents/{docId}`
  Future<void> deleteDocument(String uid, String docId) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('documents').doc(docId).delete();
      debugPrint('[FirestoreService] Document deleted from Firebase: $docId');
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting document: $e');
    }
  }

  /// Save AMC: `users/{uid}/amcs/{amcId}`
  Future<void> saveAMC(String uid, AMCRecord amc) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('amcs').doc(amc.id).set(
            amc.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] AMC saved to Firebase: ${amc.productName}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving AMC: $e');
    }
  }

  /// Delete AMC: `users/{uid}/amcs/{amcId}`
  Future<void> deleteAMC(String uid, String amcId) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('amcs').doc(amcId).delete();
      debugPrint('[FirestoreService] AMC deleted from Firebase: $amcId');
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting AMC: $e');
    }
  }

  /// Save Insurance: `users/{uid}/insurance/{insuranceId}`
  Future<void> saveInsurance(String uid, InsurancePolicy policy) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('insurance').doc(policy.id).set(
            policy.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Insurance policy saved to Firebase: ${policy.productName}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving insurance: $e');
    }
  }

  /// Delete Insurance: `users/{uid}/insurance/{insuranceId}`
  Future<void> deleteInsurance(String uid, String insuranceId) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('insurance').doc(insuranceId).delete();
      debugPrint('[FirestoreService] Insurance deleted from Firebase: $insuranceId');
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting insurance: $e');
    }
  }

  /// Save Family Member: `users/{uid}/family/{memberId}`
  Future<void> saveFamilyMember(String uid, FamilyMember member) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('family').doc(member.id).set(
            member.toMap(),
            SetOptions(merge: true),
          );
      debugPrint('[FirestoreService] Family member saved to Firebase: ${member.name}');
    } catch (e) {
      debugPrint('[FirestoreService] Error saving family member: $e');
    }
  }

  /// Delete Family Member: `users/{uid}/family/{memberId}`
  Future<void> deleteFamilyMember(String uid, String memberId) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('family').doc(memberId).delete();
      debugPrint('[FirestoreService] Family member deleted from Firebase: $memberId');
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting family member: $e');
    }
  }

  /// Save Notification: `users/{uid}/notifications/{notifId}`
  Future<void> saveNotification(String uid, AppNotification notif) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('notifications').doc(notif.id).set(
            notif.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('[FirestoreService] Error saving notification: $e');
    }
  }

  /// Delete Notification: `users/{uid}/notifications/{notifId}`
  Future<void> deleteNotification(String uid, String notifId) async {
    if (uid.isEmpty) return;
    try {
      await _usersCol.doc(uid).collection('notifications').doc(notifId).delete();
    } catch (e) {
      debugPrint('[FirestoreService] Error deleting notification: $e');
    }
  }
}
