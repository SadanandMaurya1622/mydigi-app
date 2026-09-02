import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

/// Service responsible for managing 100% Realtime Database operations
/// at https://mydigi-a2402-default-rtdb.firebaseio.com
class RealtimeDatabaseService {
  static final RealtimeDatabaseService _instance = RealtimeDatabaseService._internal();
  factory RealtimeDatabaseService() => _instance;
  RealtimeDatabaseService._internal();

  FirebaseDatabase get _rtdb => FirebaseDatabase.instance;

  DatabaseReference _userRef(String uid) => _rtdb.ref('users/$uid');

  // ==========================================
  // 1. User Profile Operations
  // ==========================================

  Future<void> saveUserProfile(UserProfile profile) async {
    if (profile.uid == null || profile.uid!.isEmpty) return;
    try {
      final ref = _userRef(profile.uid!).child('profile');
      await ref.set({
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phone,
        'photoUrl': profile.photoUrl ?? '',
        'uid': profile.uid,
        'isPro': profile.isPro,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('[RTDB] User profile synced to Realtime Database: users/${profile.uid}/profile');
    } catch (e) {
      debugPrint('[RTDB] Error saving user profile to Realtime Database: $e');
    }
  }

  // ==========================================
  // 2. Real-Time Streams (onValue from RTDB)
  // ==========================================

  Stream<List<ProductItem>> streamProducts(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _userRef(uid).child('products').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return <ProductItem>[];
      final val = snapshot.value;
      final List<ProductItem> list = [];
      if (val is Map) {
        val.forEach((key, item) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(ProductItem.fromMap(map, key.toString()));
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final item = val[i];
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(ProductItem.fromMap(map, 'item_$i'));
          }
        }
      }
      return list;
    });
  }

  Stream<List<ExpenseRecord>> streamExpenses(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _userRef(uid).child('expenses').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return <ExpenseRecord>[];
      final val = snapshot.value;
      final List<ExpenseRecord> list = [];
      if (val is Map) {
        val.forEach((key, item) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(ExpenseRecord.fromMap(map, key.toString()));
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final item = val[i];
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(ExpenseRecord.fromMap(map, 'exp_$i'));
          }
        }
      }
      return list;
    });
  }

  Stream<List<ServiceRecord>> streamServices(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _userRef(uid).child('services').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return <ServiceRecord>[];
      final val = snapshot.value;
      final List<ServiceRecord> list = [];
      if (val is Map) {
        val.forEach((key, item) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(ServiceRecord.fromMap(map, key.toString()));
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final item = val[i];
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(ServiceRecord.fromMap(map, 'srv_$i'));
          }
        }
      }
      return list;
    });
  }

  Stream<List<DocumentRecord>> streamDocuments(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _userRef(uid).child('documents').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return <DocumentRecord>[];
      final val = snapshot.value;
      final List<DocumentRecord> list = [];
      if (val is Map) {
        val.forEach((key, item) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(DocumentRecord.fromMap(map, key.toString()));
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final item = val[i];
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(DocumentRecord.fromMap(map, 'doc_$i'));
          }
        }
      }
      return list;
    });
  }

  Stream<List<AMCRecord>> streamAMCs(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _userRef(uid).child('amcs').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return <AMCRecord>[];
      final val = snapshot.value;
      final List<AMCRecord> list = [];
      if (val is Map) {
        val.forEach((key, item) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(AMCRecord.fromMap(map, key.toString()));
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final item = val[i];
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(AMCRecord.fromMap(map, 'amc_$i'));
          }
        }
      }
      return list;
    });
  }

  Stream<List<InsurancePolicy>> streamInsurance(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _userRef(uid).child('insurance').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return <InsurancePolicy>[];
      final val = snapshot.value;
      final List<InsurancePolicy> list = [];
      if (val is Map) {
        val.forEach((key, item) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(InsurancePolicy.fromMap(map, key.toString()));
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final item = val[i];
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(InsurancePolicy.fromMap(map, 'ins_$i'));
          }
        }
      }
      return list;
    });
  }

  Stream<List<WarrantyClaim>> streamClaims(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _userRef(uid).child('claims').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return <WarrantyClaim>[];
      final val = snapshot.value;
      final List<WarrantyClaim> list = [];
      if (val is Map) {
        val.forEach((key, item) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(WarrantyClaim.fromMap(map, key.toString()));
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final item = val[i];
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(WarrantyClaim.fromMap(map, 'claim_$i'));
          }
        }
      }
      return list;
    });
  }

  Stream<List<FamilyMember>> streamFamilyMembers(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _userRef(uid).child('family').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return <FamilyMember>[];
      final val = snapshot.value;
      final List<FamilyMember> list = [];
      if (val is Map) {
        val.forEach((key, item) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(FamilyMember.fromMap(map, key.toString()));
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final item = val[i];
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(FamilyMember.fromMap(map, 'fam_$i'));
          }
        }
      }
      return list;
    });
  }

  Stream<List<AppNotification>> streamNotifications(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _userRef(uid).child('notifications').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return <AppNotification>[];
      final val = snapshot.value;
      final List<AppNotification> list = [];
      if (val is Map) {
        val.forEach((key, item) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(AppNotification.fromMap(map, key.toString()));
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final item = val[i];
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            list.add(AppNotification.fromMap(map, 'notif_$i'));
          }
        }
      }
      return list;
    });
  }

  // ==========================================
  // 3. Create, Update & Delete Mutations (RTDB)
  // ==========================================

  Future<void> saveProduct(String uid, ProductItem product) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('products/${product.id}').set(product.toMap());
      debugPrint('[RTDB] Product saved to Realtime Database: ${product.name} (id: ${product.id})');
    } catch (e) {
      debugPrint('[RTDB] Error saving product to Realtime Database: $e');
    }
  }

  Future<void> deleteProduct(String uid, String productId) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('products/$productId').remove();
      debugPrint('[RTDB] Product removed from Realtime Database: $productId');
    } catch (e) {
      debugPrint('[RTDB] Error deleting product from Realtime Database: $e');
    }
  }

  Future<void> saveExpense(String uid, ExpenseRecord expense) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('expenses/${expense.id}').set(expense.toMap());
      debugPrint('[RTDB] Expense saved to Realtime Database: ₹${expense.amount}');
    } catch (e) {
      debugPrint('[RTDB] Error saving expense to Realtime Database: $e');
    }
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('expenses/$expenseId').remove();
    } catch (e) {
      debugPrint('[RTDB] Error deleting expense from Realtime Database: $e');
    }
  }

  Future<void> saveService(String uid, ServiceRecord service) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('services/${service.id}').set(service.toMap());
    } catch (e) {
      debugPrint('[RTDB] Error saving service to Realtime Database: $e');
    }
  }

  Future<void> deleteService(String uid, String serviceId) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('services/$serviceId').remove();
    } catch (e) {
      debugPrint('[RTDB] Error deleting service from Realtime Database: $e');
    }
  }

  Future<void> saveClaim(String uid, WarrantyClaim claim) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('claims/${claim.id}').set(claim.toMap());
    } catch (e) {
      debugPrint('[RTDB] Error saving claim to Realtime Database: $e');
    }
  }

  Future<void> deleteClaim(String uid, String claimId) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('claims/$claimId').remove();
    } catch (e) {
      debugPrint('[RTDB] Error deleting claim from Realtime Database: $e');
    }
  }

  Future<void> saveDocument(String uid, DocumentRecord docRecord) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('documents/${docRecord.id}').set(docRecord.toMap());
    } catch (e) {
      debugPrint('[RTDB] Error saving document to Realtime Database: $e');
    }
  }

  Future<void> deleteDocument(String uid, String docId) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('documents/$docId').remove();
    } catch (e) {
      debugPrint('[RTDB] Error deleting document from Realtime Database: $e');
    }
  }

  Future<void> saveAMC(String uid, AMCRecord amc) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('amcs/${amc.id}').set(amc.toMap());
    } catch (e) {
      debugPrint('[RTDB] Error saving AMC to Realtime Database: $e');
    }
  }

  Future<void> deleteAMC(String uid, String amcId) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('amcs/$amcId').remove();
    } catch (e) {
      debugPrint('[RTDB] Error deleting AMC from Realtime Database: $e');
    }
  }

  Future<void> saveInsurance(String uid, InsurancePolicy policy) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('insurance/${policy.id}').set(policy.toMap());
    } catch (e) {
      debugPrint('[RTDB] Error saving insurance to Realtime Database: $e');
    }
  }

  Future<void> deleteInsurance(String uid, String insuranceId) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('insurance/$insuranceId').remove();
    } catch (e) {
      debugPrint('[RTDB] Error deleting insurance from Realtime Database: $e');
    }
  }

  Future<void> saveFamilyMember(String uid, FamilyMember member) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('family/${member.id}').set(member.toMap());
    } catch (e) {
      debugPrint('[RTDB] Error saving family member to Realtime Database: $e');
    }
  }

  Future<void> deleteFamilyMember(String uid, String memberId) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('family/$memberId').remove();
    } catch (e) {
      debugPrint('[RTDB] Error deleting family member from Realtime Database: $e');
    }
  }

  Future<void> saveNotification(String uid, AppNotification notif) async {
    if (uid.isEmpty) return;
    try {
      await _userRef(uid).child('notifications/${notif.id}').set(notif.toMap());
    } catch (e) {
      debugPrint('[RTDB] Error saving notification to Realtime Database: $e');
    }
  }
}
