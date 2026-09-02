import 'package:flutter/material.dart';
import '../models/product_model.dart';

class WarrantyProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'en'; // 'en' or 'hi'
  bool _isLoggedIn = true;
  bool _hasCompletedOnboarding = true;

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  UserProfile _userProfile = UserProfile(
    name: 'Sadanand Gupta',
    email: 'sadanand@example.com',
    phone: '+91 98200 12345',
    isPro: true,
  );

  UserProfile get userProfile => _userProfile;

  final List<ProductItem> _products = [
    ProductItem(
      id: 'prod-samsung-ac',
      name: 'Samsung AC 1.5 Ton 5 Star',
      category: 'Appliances',
      brand: 'Samsung',
      modelNumber: 'AR18TYSYAWKN',
      serialNumber: 'SAM-AC-9948271',
      purchaseDate: '15 May 2025',
      purchasePrice: 42000,
      sellerName: 'Reliance Digital, Mumbai',
      sellerContact: '+91 98200 12345',
      invoiceNumber: 'INV-2025-1025',
      warrantyPeriod: '1 Year + 10 Yr Compressor',
      warrantyStartDate: '15 May 2025',
      warrantyEndDate: '08 Sep 2026',
      warrantyStatus: 'Expiring Soon',
      daysRemaining: 7,
      extendedWarranty: false,
      hasAMC: false,
      imageUrl: 'https://images.unsplash.com/photo-1628744448840-55bdb2497bd4?auto=format&fit=crop&w=800&q=80',
      costBreakdown: CostBreakdown(
        purchase: 42000,
        installation: 1500,
        maintenance: 1850,
        repair: 0,
        accessories: 2500,
        amc: 0,
      ),
      notes: 'Installed in Master Bedroom. Stabilizer connected.',
    ),
    ProductItem(
      id: 'prod-sony-tv',
      name: 'Sony Bravia 55" 4K OLED TV',
      category: 'Electronics',
      brand: 'Sony',
      modelNumber: 'XR-55A80L',
      serialNumber: 'SNY-TV-558291',
      purchaseDate: '10 Jan 2026',
      purchasePrice: 124990,
      sellerName: 'Croma Megastore, Pune',
      sellerContact: '+91 98230 11998',
      invoiceNumber: 'CR-PUN-339182',
      warrantyPeriod: '2 Years Comprehensive',
      warrantyStartDate: '10 Jan 2026',
      warrantyEndDate: '10 Jan 2028',
      warrantyStatus: 'Active',
      daysRemaining: 497,
      extendedWarranty: true,
      hasAMC: true,
      imageUrl: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80',
      costBreakdown: CostBreakdown(
        purchase: 124990,
        accessories: 3200,
        amc: 4500,
      ),
      notes: 'Living room OLED display with Dolby Atmos soundbar.',
    ),
    ProductItem(
      id: 'prod-iphone16',
      name: 'iPhone 16 Pro Max 256GB',
      category: 'Gadgets',
      brand: 'Apple',
      modelNumber: 'MYWR3HN/A',
      serialNumber: 'DNPZ889102KL',
      imeiNumber: '356789012345678',
      purchaseDate: '20 Sep 2025',
      purchasePrice: 139900,
      sellerName: 'Apple Store BKC',
      sellerContact: '1800 120 120',
      invoiceNumber: 'INV-APL-9982',
      warrantyPeriod: '1 Year AppleCare+',
      warrantyStartDate: '20 Sep 2025',
      warrantyEndDate: '20 Sep 2026',
      warrantyStatus: 'Active',
      daysRemaining: 19,
      extendedWarranty: true,
      hasAMC: false,
      imageUrl: 'https://images.unsplash.com/photo-1678685888221-cda773a3dcdb?auto=format&fit=crop&w=800&q=80',
      costBreakdown: CostBreakdown(
        purchase: 139900,
        accessories: 4900,
      ),
      notes: 'Natural Titanium edition. AppleCare Plus active.',
    ),
    ProductItem(
      id: 'prod-re-bike',
      name: 'Royal Enfield Hunter 350',
      category: 'Vehicle',
      brand: 'Royal Enfield',
      modelNumber: 'HN-350 Dapper',
      serialNumber: 'RE350HN881920',
      purchaseDate: '14 Feb 2025',
      purchasePrice: 175000,
      sellerName: 'RE Brand Store Andheri',
      sellerContact: '+91 22 2839 9900',
      invoiceNumber: 'RE-MUM-2025-019',
      warrantyPeriod: '3 Years / 30,000 KM',
      warrantyStartDate: '14 Feb 2025',
      warrantyEndDate: '14 Feb 2028',
      warrantyStatus: 'Active',
      daysRemaining: 530,
      extendedWarranty: true,
      hasAMC: false,
      imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
      costBreakdown: CostBreakdown(
        purchase: 175000,
        maintenance: 8500,
        repair: 2100,
        accessories: 14000,
      ),
      notes: 'Registration MH 02 EX 8841. 4 free services availed.',
    ),
    ProductItem(
      id: 'prod-dell-laptop',
      name: 'Dell XPS 15 32GB 1TB',
      category: 'Electronics',
      brand: 'Dell',
      modelNumber: 'XPS-9530',
      serialNumber: 'DEL-88392-XPS',
      purchaseDate: '05 Jan 2026',
      purchasePrice: 165000,
      sellerName: 'Dell Online Store',
      sellerContact: '1800 425 0088',
      invoiceNumber: 'DEL-INV-44102',
      warrantyPeriod: '1 Year Onsite + Accidental',
      warrantyStartDate: '05 Jan 2026',
      warrantyEndDate: '05 Jan 2027',
      warrantyStatus: 'Active',
      daysRemaining: 126,
      extendedWarranty: true,
      hasAMC: false,
      imageUrl: 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?auto=format&fit=crop&w=800&q=80',
      costBreakdown: CostBreakdown(
        purchase: 165000,
        maintenance: 800,
        repair: 1200,
        accessories: 3200,
      ),
    ),
    ProductItem(
      id: 'prod-ifb-microwave',
      name: 'IFB 30L Convection Microwave',
      category: 'Appliances',
      brand: 'IFB',
      modelNumber: '30FRC2',
      serialNumber: 'IFB882910',
      purchaseDate: '10 Jan 2023',
      purchasePrice: 16500,
      sellerName: 'Vijay Sales',
      sellerContact: '1800 209 1010',
      invoiceNumber: 'VS-2023-771',
      warrantyPeriod: '1 Year Complete',
      warrantyStartDate: '10 Jan 2023',
      warrantyEndDate: '10 Jan 2024',
      warrantyStatus: 'Expired',
      daysRemaining: 0,
      extendedWarranty: false,
      hasAMC: false,
      imageUrl: 'https://images.unsplash.com/photo-1585659722983-3a675dabf23d?auto=format&fit=crop&w=800&q=80',
      costBreakdown: CostBreakdown(
        purchase: 16500,
        maintenance: 1200,
      ),
    ),
  ];

  final List<ExpenseRecord> _expenses = [
    ExpenseRecord(
      id: 'exp-1',
      productId: 'prod-samsung-ac',
      productName: 'Samsung AC 1.5 Ton',
      category: 'Maintenance',
      amount: 1850.0,
      date: '12 Aug 2026',
      serviceProvider: 'Urban Company Service Pro',
      notes: 'Deep jet pump cleaning and cooling gas pressure check.',
    ),
    ExpenseRecord(
      id: 'exp-2',
      productId: 'prod-sony-tv',
      productName: 'Sony Bravia 55" OLED',
      category: 'AMC',
      amount: 4500.0,
      date: '10 Jan 2026',
      serviceProvider: 'Sony Protect Plus Plan',
      notes: 'Extended panel insurance for 2nd year.',
    ),
    ExpenseRecord(
      id: 'exp-3',
      productId: 'prod-re-bike',
      productName: 'Royal Enfield Hunter 350',
      category: 'Service',
      amount: 3200.0,
      date: '02 Jul 2026',
      serviceProvider: 'RE Authorized Workshop Andheri',
      notes: '3rd periodic oil change & chain lubrication.',
    ),
    ExpenseRecord(
      id: 'exp-4',
      productId: 'prod-iphone16',
      productName: 'iPhone 16 Pro Max',
      category: 'Accessories',
      amount: 4900.0,
      date: '20 Sep 2025',
      serviceProvider: 'Apple Store BKC',
      notes: 'Original MagSafe Silicone Case & 30W Power Adapter.',
    ),
  ];

  final List<ServiceRecord> _services = [
    ServiceRecord(
      id: 'srv-1',
      productId: 'prod-samsung-ac',
      productName: 'Samsung AC 1.5 Ton',
      date: '12 Aug 2026',
      serviceType: 'Jet Pump Deep Cleaning',
      cost: 1850,
      technicianName: 'Ramesh Sharma',
      serviceProvider: 'Urban Company',
      nextServiceDate: '12 Feb 2027',
    ),
    ServiceRecord(
      id: 'srv-2',
      productId: 'prod-re-bike',
      productName: 'Royal Enfield Hunter 350',
      date: '02 Jul 2026',
      serviceType: '10,000 KM Periodic Service',
      cost: 3200,
      technicianName: 'Amit Verma',
      serviceProvider: 'RE Service Hub',
      nextServiceDate: '02 Jan 2027',
    ),
  ];

  final List<DocumentRecord> _documents = [
    DocumentRecord(
      id: 'doc-1',
      productId: 'prod-samsung-ac',
      productName: 'Samsung AC 1.5 Ton',
      name: 'Samsung_AC_Invoice.pdf',
      type: 'Invoice',
      size: '1.8 MB',
      uploadDate: '15 May 2025',
    ),
    DocumentRecord(
      id: 'doc-2',
      productId: 'prod-sony-tv',
      productName: 'Sony Bravia 55" OLED',
      name: 'Sony_Bravia_Bill_Warranty.pdf',
      type: 'Invoice',
      size: '2.4 MB',
      uploadDate: '10 Jan 2026',
    ),
    DocumentRecord(
      id: 'doc-3',
      productId: 'prod-iphone16',
      productName: 'iPhone 16 Pro Max',
      name: 'AppleCare_Certificate.pdf',
      type: 'Warranty Card',
      size: '940 KB',
      uploadDate: '20 Sep 2025',
    ),
    DocumentRecord(
      id: 'doc-4',
      productId: 'prod-re-bike',
      productName: 'Royal Enfield Hunter 350',
      name: 'RE_Hunter_Insurance_Policy.pdf',
      type: 'Insurance',
      size: '3.1 MB',
      uploadDate: '14 Feb 2025',
    ),
  ];

  final List<AMCRecord> _amcRecords = [
    AMCRecord(
      id: 'amc-1',
      productId: 'prod-sony-tv',
      productName: 'Sony Bravia 55" OLED TV',
      provider: 'Sony Protect Plus Care',
      planName: 'Comprehensive 2-Year Cover',
      startDate: '10 Jan 2026',
      endDate: '10 Jan 2028',
      cost: 4500,
      status: 'Active',
      contactNumber: '1800 103 7799',
      freeServicesRemaining: 2,
    ),
    AMCRecord(
      id: 'amc-2',
      productId: 'prod-samsung-ac',
      productName: 'Samsung AC 1.5 Ton',
      provider: 'Samsung Care+ Home',
      planName: 'Annual AC Wellness Plan',
      startDate: '15 May 2025',
      endDate: '15 May 2026',
      cost: 2499,
      status: 'Expiring Soon',
      contactNumber: '1800 407 267864',
      freeServicesRemaining: 1,
    ),
  ];

  final List<InsurancePolicy> _insurancePolicies = [
    InsurancePolicy(
      id: 'ins-1',
      productId: 'prod-re-bike',
      productName: 'Royal Enfield Hunter 350',
      provider: 'ICICI Lombard General Insurance',
      policyNumber: '3001/2025/998124',
      premiumAmount: 4850,
      coverageAmount: 165000,
      startDate: '14 Feb 2025',
      expiryDate: '13 Feb 2028',
      status: 'Active',
    ),
  ];

  final List<WarrantyClaim> _claims = [
    WarrantyClaim(
      id: 'clm-1',
      productId: 'prod-samsung-ac',
      productName: 'Samsung AC 1.5 Ton',
      ticketNumber: 'CLM-2026-SAM-491',
      claimDate: '28 Aug 2026',
      description: 'Minor vibration noise from outdoor fan motor.',
      serviceCenter: 'Samsung Authorized Center, Bandra',
      status: 'In Progress',
      technicianAssigned: 'Kunal Patil (Ph: 98199 44321)',
      claimAmount: 0.0,
    ),
  ];

  final List<FamilyMember> _familyMembers = [
    FamilyMember(
      id: 'fam-1',
      name: 'Pooja Gupta',
      role: 'Co-Owner',
      relation: 'Spouse',
      email: 'pooja.gupta@example.com',
      permissions: 'Full Manage Products',
    ),
    FamilyMember(
      id: 'fam-2',
      name: 'Aarav Gupta',
      role: 'Family Member',
      relation: 'Son',
      email: 'aarav.g@example.com',
      permissions: 'View Only & Add Invoices',
    ),
  ];

  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'notif-1',
      title: '🚨 AC Warranty Expiring in 7 Days!',
      message: 'Samsung 1.5 Ton AC standard 1-year warranty is ending. Book free final service inspection now.',
      date: '2 hours ago',
      type: 'expiry',
      unread: true,
      productId: 'prod-samsung-ac',
    ),
    AppNotification(
      id: 'notif-2',
      title: '🛡️ AMC Service Reminder',
      message: 'Sony Bravia 55" OLED TV has 1 free screen calibration & cleaning session left in current plan.',
      date: '1 day ago',
      type: 'amc',
      unread: true,
      productId: 'prod-sony-tv',
    ),
    AppNotification(
      id: 'notif-3',
      title: '✨ Bill Auto-Archived',
      message: 'Invoice for Apple Store BKC has been saved to secure encrypted cloud vault.',
      date: '3 days ago',
      type: 'invoice',
      unread: false,
      productId: 'prod-iphone16',
    ),
  ];

  // Getters
  List<ProductItem> get products => [..._products];
  List<ExpenseRecord> get expenses => [..._expenses];
  List<ServiceRecord> get services => [..._services];
  List<DocumentRecord> get documents => [..._documents];
  List<AMCRecord> get amcRecords => [..._amcRecords];
  List<InsurancePolicy> get insurancePolicies => [..._insurancePolicies];
  List<WarrantyClaim> get claims => [..._claims];
  List<FamilyMember> get familyMembers => [..._familyMembers];
  List<AppNotification> get notifications => [..._notifications];

  int get unreadNotificationsCount => _notifications.where((n) => n.unread).length;

  double get totalAssetValue => _products.fold(0.0, (sum, p) => sum + p.purchasePrice);
  double get totalExpenseValue => _expenses.fold(0.0, (sum, e) => sum + e.amount);
  int get activeCount => _products.where((p) => p.warrantyStatus == 'Active').length;
  int get expiringSoonCount => _products.where((p) => p.warrantyStatus == 'Expiring Soon').length;
  int get expiredCount => _products.where((p) => p.warrantyStatus == 'Expired').length;

  // Actions
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void updateUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void addProduct(ProductItem product) {
    _products.insert(0, product);
    // Add default invoice record
    _documents.insert(
      0,
      DocumentRecord(
        id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
        productId: product.id,
        productName: product.name,
        name: '${product.brand}_Invoice.pdf',
        type: 'Invoice',
        size: '1.4 MB',
        uploadDate: 'Just now',
      ),
    );
    notifyListeners();
  }

  void updateProduct(ProductItem product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _expenses.removeWhere((e) => e.productId == productId);
    _documents.removeWhere((d) => d.productId == productId);
    _amcRecords.removeWhere((a) => a.productId == productId);
    _claims.removeWhere((c) => c.productId == productId);
    notifyListeners();
  }

  void addExpense(ExpenseRecord expense) {
    _expenses.insert(0, expense);
    // Update product cost breakdown
    final productIndex = _products.indexWhere((p) => p.id == expense.productId);
    if (productIndex != -1) {
      final p = _products[productIndex];
      final cb = p.costBreakdown;
      CostBreakdown updated;
      switch (expense.category.toLowerCase()) {
        case 'maintenance':
        case 'service':
          updated = cb.copyWith(maintenance: cb.maintenance + expense.amount);
          break;
        case 'repair':
          updated = cb.copyWith(repair: cb.repair + expense.amount);
          break;
        case 'amc':
          updated = cb.copyWith(amc: cb.amc + expense.amount);
          break;
        case 'accessories':
          updated = cb.copyWith(accessories: cb.accessories + expense.amount);
          break;
        default:
          updated = cb.copyWith(other: cb.other + expense.amount);
      }
      _products[productIndex] = p.copyWith(costBreakdown: updated);
    }
    notifyListeners();
  }

  void addServiceRecord(ServiceRecord service) {
    _services.insert(0, service);
    notifyListeners();
  }

  void addClaim(WarrantyClaim claim) {
    _claims.insert(0, claim);
    notifyListeners();
  }

  void addDocument(DocumentRecord document) {
    _documents.insert(0, document);
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.unread = false;
    }
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].unread = false;
      notifyListeners();
    }
  }

  void login(String name, String email, String phone, {String? photoUrl, String? uid}) {
    _userProfile = UserProfile(
      name: name.isNotEmpty ? name : 'MyDigi User',
      email: email.isNotEmpty ? email : 'user@mydigi.app',
      phone: phone.isNotEmpty ? phone : '+91 98200 12345',
      photoUrl: photoUrl,
      uid: uid,
      isPro: true,
    );
    _isLoggedIn = true;
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }
}
