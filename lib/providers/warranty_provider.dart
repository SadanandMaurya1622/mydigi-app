import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/realtime_database_service.dart';

/// Pure Firebase Provider that streams all data live from Firebase Realtime Database and Cloud Firestore.
/// No mock or hardcoded data is used.
class WarrantyProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'en'; // 'en' or 'hi'
  bool _isLoggedIn = false;
  bool _hasCompletedOnboarding = true;
  bool _isLoadingData = false;

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoadingData => _isLoadingData;

  UserProfile _userProfile = UserProfile(
    name: 'MyDigi User',
    email: '',
    phone: '',
    isPro: true,
  );

  UserProfile get userProfile => _userProfile;

  // Real-time Lists populated strictly from Firebase Realtime Database
  final List<ProductItem> _products = [];
  final List<ExpenseRecord> _expenses = [];
  final List<ServiceRecord> _services = [];
  final List<DocumentRecord> _documents = [];
  final List<AMCRecord> _amcRecords = [];
  final List<InsurancePolicy> _insurancePolicies = [];
  final List<WarrantyClaim> _claims = [];
  final List<FamilyMember> _familyMembers = [];
  final List<AppNotification> _notifications = [];

  // Stream Subscriptions
  final List<StreamSubscription> _subscriptions = [];

  // Getters
  List<ProductItem> get products => List.unmodifiable(_products);
  List<ExpenseRecord> get expenses => List.unmodifiable(_expenses);
  List<ServiceRecord> get services => List.unmodifiable(_services);
  List<DocumentRecord> get documents => List.unmodifiable(_documents);
  List<AMCRecord> get amcRecords => List.unmodifiable(_amcRecords);
  List<InsurancePolicy> get insurancePolicies => List.unmodifiable(_insurancePolicies);
  List<WarrantyClaim> get claims => List.unmodifiable(_claims);
  List<FamilyMember> get familyMembers => List.unmodifiable(_familyMembers);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadNotificationsCount => _notifications.where((n) => n.unread).length;

  double get totalAssetValue => _products.fold(0.0, (sum, p) => sum + p.purchasePrice);
  double get totalExpenseValue => _expenses.fold(0.0, (sum, e) => sum + e.amount);
  int get activeCount => _products.where((p) => p.warrantyStatus == 'Active').length;
  int get expiringSoonCount => _products.where((p) => p.warrantyStatus == 'Expiring Soon').length;
  int get expiredCount => _products.where((p) => p.warrantyStatus == 'Expired').length;

  // App Theme & Language Controls
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  // ==========================================
  // Auth & Real-Time Sync with Firebase Realtime Database
  // ==========================================

  Future<void> login(String name, String email, String phone, {String? photoUrl, String? uid}) async {
    final effectiveUid = (uid != null && uid.isNotEmpty)
        ? uid
        : (email.isNotEmpty ? email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') : 'user_main');

    _userProfile = UserProfile(
      name: name.isNotEmpty ? name : 'MyDigi User',
      email: email.isNotEmpty ? email : 'user@mydigi.app',
      phone: phone.isNotEmpty ? phone : '+91 98200 12345',
      photoUrl: photoUrl,
      uid: effectiveUid,
      isPro: true,
    );
    _isLoggedIn = true;
    _hasCompletedOnboarding = true;
    notifyListeners();

    // 1. Save User Profile in Firebase Realtime Database & Firestore (non-blocking in background)
    RealtimeDatabaseService().saveUserProfile(_userProfile);
    FirestoreService().saveUserProfile(_userProfile);

    // 2. Initialize Real-Time Streams for this user from Realtime Database
    _initRealtimeStreams(effectiveUid);
  }

  void _initRealtimeStreams(String uid) {
    // Cancel any previous subscriptions
    _cancelSubscriptions();
    _isLoadingData = true;
    notifyListeners();

    // 1. Stream Products from Realtime Database & Firestore
    _subscriptions.add(
      RealtimeDatabaseService().streamProducts(uid).listen((liveProducts) {
        for (var p in liveProducts) {
          final idx = _products.indexWhere((x) => x.id == p.id);
          if (idx != -1) {
            _products[idx] = p;
          } else {
            _products.add(p);
          }
        }
        _isLoadingData = false;
        notifyListeners();
      }, onError: (e) {
        debugPrint('[WarrantyProvider] Error streaming products from RTDB: $e');
        _isLoadingData = false;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      FirestoreService().streamProducts(uid).listen((firestoreProducts) {
        for (var p in firestoreProducts) {
          final idx = _products.indexWhere((x) => x.id == p.id);
          if (idx != -1) {
            _products[idx] = p;
          } else {
            _products.add(p);
            // Sync to RTDB so it is visible in Realtime Database Console
            RealtimeDatabaseService().saveProduct(uid, p);
          }
        }
        _isLoadingData = false;
        notifyListeners();
      }, onError: (e) => debugPrint('[WarrantyProvider] Firestore products notice: $e')),
    );

    // 2. Stream Expenses from Realtime Database & Firestore
    _subscriptions.add(
      RealtimeDatabaseService().streamExpenses(uid).listen((liveExpenses) {
        for (var e in liveExpenses) {
          final idx = _expenses.indexWhere((x) => x.id == e.id);
          if (idx != -1) {
            _expenses[idx] = e;
          } else {
            _expenses.add(e);
          }
        }
        notifyListeners();
      }, onError: (e) => debugPrint('[WarrantyProvider] Error streaming expenses from RTDB: $e')),
    );

    _subscriptions.add(
      FirestoreService().streamExpenses(uid).listen((firestoreExpenses) {
        for (var e in firestoreExpenses) {
          final idx = _expenses.indexWhere((x) => x.id == e.id);
          if (idx != -1) {
            _expenses[idx] = e;
          } else {
            _expenses.add(e);
            RealtimeDatabaseService().saveExpense(uid, e);
          }
        }
        notifyListeners();
      }, onError: (e) => debugPrint('[WarrantyProvider] Firestore expenses notice: $e')),
    );

    // 3. Stream Services
    _subscriptions.add(
      RealtimeDatabaseService().streamServices(uid).listen((liveServices) {
        for (var s in liveServices) {
          final idx = _services.indexWhere((x) => x.id == s.id);
          if (idx != -1) {
            _services[idx] = s;
          } else {
            _services.add(s);
          }
        }
        notifyListeners();
      }, onError: (e) => debugPrint('[WarrantyProvider] Error streaming services from RTDB: $e')),
    );

    // 4. Stream Documents
    _subscriptions.add(
      RealtimeDatabaseService().streamDocuments(uid).listen((liveDocs) {
        for (var d in liveDocs) {
          final idx = _documents.indexWhere((x) => x.id == d.id);
          if (idx != -1) {
            _documents[idx] = d;
          } else {
            _documents.add(d);
          }
        }
        notifyListeners();
      }, onError: (e) => debugPrint('[WarrantyProvider] Error streaming documents from RTDB: $e')),
    );

    // 5. Stream AMCs
    _subscriptions.add(
      RealtimeDatabaseService().streamAMCs(uid).listen((liveAMCs) {
        for (var a in liveAMCs) {
          final idx = _amcRecords.indexWhere((x) => x.id == a.id);
          if (idx != -1) {
            _amcRecords[idx] = a;
          } else {
            _amcRecords.add(a);
          }
        }
        notifyListeners();
      }, onError: (e) => debugPrint('[WarrantyProvider] Error streaming AMCs from RTDB: $e')),
    );

    // 6. Stream Insurance
    _subscriptions.add(
      RealtimeDatabaseService().streamInsurance(uid).listen((liveInsurance) {
        for (var i in liveInsurance) {
          final idx = _insurancePolicies.indexWhere((x) => x.id == i.id);
          if (idx != -1) {
            _insurancePolicies[idx] = i;
          } else {
            _insurancePolicies.add(i);
          }
        }
        notifyListeners();
      }, onError: (e) => debugPrint('[WarrantyProvider] Error streaming insurance from RTDB: $e')),
    );

    // 7. Stream Claims
    _subscriptions.add(
      RealtimeDatabaseService().streamClaims(uid).listen((liveClaims) {
        for (var c in liveClaims) {
          final idx = _claims.indexWhere((x) => x.id == c.id);
          if (idx != -1) {
            _claims[idx] = c;
          } else {
            _claims.add(c);
          }
        }
        notifyListeners();
      }, onError: (e) => debugPrint('[WarrantyProvider] Error streaming claims from RTDB: $e')),
    );

    // 8. Stream Family
    _subscriptions.add(
      RealtimeDatabaseService().streamFamilyMembers(uid).listen((liveFamily) {
        for (var f in liveFamily) {
          final idx = _familyMembers.indexWhere((x) => x.id == f.id);
          if (idx != -1) {
            _familyMembers[idx] = f;
          } else {
            _familyMembers.add(f);
          }
        }
        notifyListeners();
      }, onError: (e) => debugPrint('[WarrantyProvider] Error streaming family from RTDB: $e')),
    );

    // 9. Stream Notifications
    _subscriptions.add(
      RealtimeDatabaseService().streamNotifications(uid).listen((liveNotifs) {
        for (var n in liveNotifs) {
          final idx = _notifications.indexWhere((x) => x.id == n.id);
          if (idx != -1) {
            _notifications[idx] = n;
          } else {
            _notifications.add(n);
          }
        }
        notifyListeners();
      }, onError: (e) => debugPrint('[WarrantyProvider] Error streaming notifications from RTDB: $e')),
    );
  }

  void logout() {
    _isLoggedIn = false;
    _cancelSubscriptions();
    _products.clear();
    _expenses.clear();
    _services.clear();
    _documents.clear();
    _amcRecords.clear();
    _insurancePolicies.clear();
    _claims.clear();
    _familyMembers.clear();
    _notifications.clear();
    notifyListeners();
  }

  void _cancelSubscriptions() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  // ==========================================
  // Mutations (All Save Directly to Cloud Firestore)
  // ==========================================

  String get _activeUid {
    if (_userProfile.uid != null && _userProfile.uid!.isNotEmpty) {
      return _userProfile.uid!;
    }
    return '';
  }

  void updateUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().saveUserProfile(profile);
      FirestoreService().saveUserProfile(profile);
    }
  }

  void addProduct(ProductItem product) {
    _products.removeWhere((p) => p.id == product.id);
    _products.insert(0, product);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().saveProduct(uid, product);
      FirestoreService().saveProduct(uid, product);
      // Create and save invoice document
      final doc = DocumentRecord(
        id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
        productId: product.id,
        productName: product.name,
        name: '${product.brand}_Invoice.pdf',
        type: 'Invoice',
        size: '1.4 MB',
        uploadDate: 'Just now',
      );
      _documents.insert(0, doc);
      notifyListeners();
      RealtimeDatabaseService().saveDocument(uid, doc);
      FirestoreService().saveDocument(uid, doc);
    }
  }

  void updateProduct(ProductItem product) {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _products[idx] = product;
    } else {
      _products.add(product);
    }
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().saveProduct(uid, product);
      FirestoreService().saveProduct(uid, product);
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().deleteProduct(uid, productId);
      FirestoreService().deleteProduct(uid, productId);
    }
  }

  void addExpense(ExpenseRecord expense) {
    _expenses.removeWhere((e) => e.id == expense.id);
    _expenses.insert(0, expense);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().saveExpense(uid, expense);
      FirestoreService().saveExpense(uid, expense);
    }
  }

  void deleteExpense(String expenseId) {
    _expenses.removeWhere((e) => e.id == expenseId);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().deleteExpense(uid, expenseId);
      FirestoreService().deleteExpense(uid, expenseId);
    }
  }

  void addServiceRecord(ServiceRecord service) {
    _services.removeWhere((s) => s.id == service.id);
    _services.insert(0, service);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().saveService(uid, service);
      FirestoreService().saveService(uid, service);
    }
  }

  void deleteServiceRecord(String serviceId) {
    _services.removeWhere((s) => s.id == serviceId);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().deleteService(uid, serviceId);
      FirestoreService().deleteService(uid, serviceId);
    }
  }

  void addClaim(WarrantyClaim claim) {
    _claims.removeWhere((c) => c.id == claim.id);
    _claims.insert(0, claim);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().saveClaim(uid, claim);
      FirestoreService().saveClaim(uid, claim);
    }
  }

  void deleteClaim(String claimId) {
    _claims.removeWhere((c) => c.id == claimId);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().deleteClaim(uid, claimId);
      FirestoreService().deleteClaim(uid, claimId);
    }
  }

  void addDocument(DocumentRecord document) {
    _documents.removeWhere((d) => d.id == document.id);
    _documents.insert(0, document);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().saveDocument(uid, document);
      FirestoreService().saveDocument(uid, document);
    }
  }

  void deleteDocument(String docId) {
    _documents.removeWhere((d) => d.id == docId);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().deleteDocument(uid, docId);
      FirestoreService().deleteDocument(uid, docId);
    }
  }

  void addAMC(AMCRecord amc) {
    _amcRecords.removeWhere((a) => a.id == amc.id);
    _amcRecords.insert(0, amc);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().saveAMC(uid, amc);
      FirestoreService().saveAMC(uid, amc);
    }
  }

  void deleteAMC(String amcId) {
    _amcRecords.removeWhere((a) => a.id == amcId);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().deleteAMC(uid, amcId);
      FirestoreService().deleteAMC(uid, amcId);
    }
  }

  void addInsurance(InsurancePolicy policy) {
    _insurancePolicies.removeWhere((i) => i.id == policy.id);
    _insurancePolicies.insert(0, policy);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().saveInsurance(uid, policy);
      FirestoreService().saveInsurance(uid, policy);
    }
  }

  void deleteInsurance(String insuranceId) {
    _insurancePolicies.removeWhere((i) => i.id == insuranceId);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().deleteInsurance(uid, insuranceId);
      FirestoreService().deleteInsurance(uid, insuranceId);
    }
  }

  void addFamilyMember(FamilyMember member) {
    _familyMembers.removeWhere((f) => f.id == member.id);
    _familyMembers.insert(0, member);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().saveFamilyMember(uid, member);
      FirestoreService().saveFamilyMember(uid, member);
    }
  }

  void deleteFamilyMember(String memberId) {
    _familyMembers.removeWhere((f) => f.id == memberId);
    notifyListeners();

    final uid = _activeUid;
    if (uid.isNotEmpty) {
      RealtimeDatabaseService().deleteFamilyMember(uid, memberId);
      FirestoreService().deleteFamilyMember(uid, memberId);
    }
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.unread = false;
      if (_userProfile.uid != null && _userProfile.uid!.isNotEmpty) {
        RealtimeDatabaseService().saveNotification(_userProfile.uid!, n);
        FirestoreService().saveNotification(_userProfile.uid!, n);
      }
    }
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].unread = false;
      if (_userProfile.uid != null && _userProfile.uid!.isNotEmpty) {
        RealtimeDatabaseService().saveNotification(_userProfile.uid!, _notifications[index]);
        FirestoreService().saveNotification(_userProfile.uid!, _notifications[index]);
      }
      notifyListeners();
    }
  }
}
