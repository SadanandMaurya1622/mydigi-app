class ProductItem {
  final String id;
  final String name;
  final String category; // 'Electronics', 'Appliances', 'Vehicle', 'Furniture', 'Gadgets', 'Other'
  final String brand;
  final String modelNumber;
  final String serialNumber;
  final String? imeiNumber;
  final String purchaseDate;
  final double purchasePrice;
  final String sellerName;
  final String sellerContact;
  final String invoiceNumber;
  final String warrantyPeriod;
  final String warrantyStartDate;
  final String warrantyEndDate;
  final String warrantyStatus; // 'Active', 'Expiring Soon', 'Expired'
  final int daysRemaining;
  final bool extendedWarranty;
  final bool hasAMC;
  final String imageUrl;
  final CostBreakdown costBreakdown;
  final String? notes;

  ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.modelNumber,
    required this.serialNumber,
    this.imeiNumber,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.sellerName,
    this.sellerContact = '',
    required this.invoiceNumber,
    required this.warrantyPeriod,
    required this.warrantyStartDate,
    required this.warrantyEndDate,
    required this.warrantyStatus,
    required this.daysRemaining,
    this.extendedWarranty = false,
    this.hasAMC = false,
    required this.imageUrl,
    required this.costBreakdown,
    this.notes,
  });

  double get totalCostOfOwnership =>
      purchasePrice +
      costBreakdown.installation +
      costBreakdown.maintenance +
      costBreakdown.repair +
      costBreakdown.accessories +
      costBreakdown.amc +
      costBreakdown.other;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'brand': brand,
      'modelNumber': modelNumber,
      'serialNumber': serialNumber,
      'imeiNumber': imeiNumber,
      'purchaseDate': purchaseDate,
      'purchasePrice': purchasePrice,
      'sellerName': sellerName,
      'sellerContact': sellerContact,
      'invoiceNumber': invoiceNumber,
      'warrantyPeriod': warrantyPeriod,
      'warrantyStartDate': warrantyStartDate,
      'warrantyEndDate': warrantyEndDate,
      'warrantyStatus': warrantyStatus,
      'daysRemaining': daysRemaining,
      'extendedWarranty': extendedWarranty,
      'hasAMC': hasAMC,
      'imageUrl': imageUrl,
      'costBreakdown': costBreakdown.toMap(),
      'notes': notes,
    };
  }

  factory ProductItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ProductItem(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Other',
      brand: map['brand'] ?? '',
      modelNumber: map['modelNumber'] ?? '',
      serialNumber: map['serialNumber'] ?? '',
      imeiNumber: map['imeiNumber'],
      purchaseDate: map['purchaseDate'] ?? '',
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      sellerName: map['sellerName'] ?? '',
      sellerContact: map['sellerContact'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      warrantyPeriod: map['warrantyPeriod'] ?? '',
      warrantyStartDate: map['warrantyStartDate'] ?? '',
      warrantyEndDate: map['warrantyEndDate'] ?? '',
      warrantyStatus: map['warrantyStatus'] ?? 'Active',
      daysRemaining: (map['daysRemaining'] as num?)?.toInt() ?? 0,
      extendedWarranty: map['extendedWarranty'] ?? false,
      hasAMC: map['hasAMC'] ?? false,
      imageUrl: map['imageUrl'] ?? 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?auto=format&fit=crop&w=800&q=80',
      costBreakdown: map['costBreakdown'] != null
          ? CostBreakdown.fromMap(Map<String, dynamic>.from(map['costBreakdown']))
          : CostBreakdown(purchase: (map['purchasePrice'] as num?)?.toDouble() ?? 0.0),
      notes: map['notes'],
    );
  }

  ProductItem copyWith({
    String? id,
    String? name,
    String? category,
    String? brand,
    String? modelNumber,
    String? serialNumber,
    String? imeiNumber,
    String? purchaseDate,
    double? purchasePrice,
    String? sellerName,
    String? sellerContact,
    String? invoiceNumber,
    String? warrantyPeriod,
    String? warrantyStartDate,
    String? warrantyEndDate,
    String? warrantyStatus,
    int? daysRemaining,
    bool? extendedWarranty,
    bool? hasAMC,
    String? imageUrl,
    CostBreakdown? costBreakdown,
    String? notes,
  }) {
    return ProductItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      modelNumber: modelNumber ?? this.modelNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      imeiNumber: imeiNumber ?? this.imeiNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellerName: sellerName ?? this.sellerName,
      sellerContact: sellerContact ?? this.sellerContact,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      warrantyPeriod: warrantyPeriod ?? this.warrantyPeriod,
      warrantyStartDate: warrantyStartDate ?? this.warrantyStartDate,
      warrantyEndDate: warrantyEndDate ?? this.warrantyEndDate,
      warrantyStatus: warrantyStatus ?? this.warrantyStatus,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      extendedWarranty: extendedWarranty ?? this.extendedWarranty,
      hasAMC: hasAMC ?? this.hasAMC,
      imageUrl: imageUrl ?? this.imageUrl,
      costBreakdown: costBreakdown ?? this.costBreakdown,
      notes: notes ?? this.notes,
    );
  }
}

class CostBreakdown {
  final double purchase;
  final double installation;
  final double maintenance;
  final double repair;
  final double accessories;
  final double amc;
  final double other;

  CostBreakdown({
    required this.purchase,
    this.installation = 0,
    this.maintenance = 0,
    this.repair = 0,
    this.accessories = 0,
    this.amc = 0,
    this.other = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'purchase': purchase,
      'installation': installation,
      'maintenance': maintenance,
      'repair': repair,
      'accessories': accessories,
      'amc': amc,
      'other': other,
    };
  }

  factory CostBreakdown.fromMap(Map<String, dynamic> map) {
    return CostBreakdown(
      purchase: (map['purchase'] as num?)?.toDouble() ?? 0.0,
      installation: (map['installation'] as num?)?.toDouble() ?? 0.0,
      maintenance: (map['maintenance'] as num?)?.toDouble() ?? 0.0,
      repair: (map['repair'] as num?)?.toDouble() ?? 0.0,
      accessories: (map['accessories'] as num?)?.toDouble() ?? 0.0,
      amc: (map['amc'] as num?)?.toDouble() ?? 0.0,
      other: (map['other'] as num?)?.toDouble() ?? 0.0,
    );
  }

  CostBreakdown copyWith({
    double? purchase,
    double? installation,
    double? maintenance,
    double? repair,
    double? accessories,
    double? amc,
    double? other,
  }) {
    return CostBreakdown(
      purchase: purchase ?? this.purchase,
      installation: installation ?? this.installation,
      maintenance: maintenance ?? this.maintenance,
      repair: repair ?? this.repair,
      accessories: accessories ?? this.accessories,
      amc: amc ?? this.amc,
      other: other ?? this.other,
    );
  }
}

class ExpenseRecord {
  final String id;
  final String productId;
  final String productName;
  final String category; // 'Service', 'Repair', 'Maintenance', 'AMC', 'Accessories', 'Other'
  final double amount;
  final String date;
  final String serviceProvider;
  final String? notes;
  final String? invoiceUrl;

  ExpenseRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.amount,
    required this.date,
    required this.serviceProvider,
    this.notes,
    this.invoiceUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'category': category,
      'amount': amount,
      'date': date,
      'serviceProvider': serviceProvider,
      'notes': notes,
      'invoiceUrl': invoiceUrl,
    };
  }

  factory ExpenseRecord.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ExpenseRecord(
      id: docId ?? map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      category: map['category'] ?? 'Maintenance',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] ?? '',
      serviceProvider: map['serviceProvider'] ?? '',
      notes: map['notes'],
      invoiceUrl: map['invoiceUrl'],
    );
  }
}

class ServiceRecord {
  final String id;
  final String productId;
  final String productName;
  final String date;
  final String serviceType;
  final double cost;
  final String technicianName;
  final String? serviceProvider;
  final String? description;
  final String? nextServiceDate;

  ServiceRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.date,
    required this.serviceType,
    required this.cost,
    required this.technicianName,
    this.serviceProvider,
    this.description,
    this.nextServiceDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'date': date,
      'serviceType': serviceType,
      'cost': cost,
      'technicianName': technicianName,
      'serviceProvider': serviceProvider,
      'description': description,
      'nextServiceDate': nextServiceDate,
    };
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ServiceRecord(
      id: docId ?? map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      date: map['date'] ?? '',
      serviceType: map['serviceType'] ?? '',
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      technicianName: map['technicianName'] ?? '',
      serviceProvider: map['serviceProvider'],
      description: map['description'],
      nextServiceDate: map['nextServiceDate'],
    );
  }
}

class DocumentRecord {
  final String id;
  final String productId;
  final String productName;
  final String name;
  final String type; // 'Invoice', 'Warranty Card', 'AMC Document', 'Insurance', 'Manual'
  final String size;
  final String uploadDate;
  final String? previewUrl;
  final bool isLocal;
  final String? mimeType;

  DocumentRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.name,
    required this.type,
    required this.size,
    required this.uploadDate,
    this.previewUrl,
    this.isLocal = false,
    this.mimeType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'name': name,
      'type': type,
      'size': size,
      'uploadDate': uploadDate,
      'previewUrl': previewUrl,
      'isLocal': isLocal,
      'mimeType': mimeType,
    };
  }

  factory DocumentRecord.fromMap(Map<String, dynamic> map, [String? docId]) {
    return DocumentRecord(
      id: docId ?? map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'Invoice',
      size: map['size'] ?? '',
      uploadDate: map['uploadDate'] ?? '',
      previewUrl: map['previewUrl'],
      isLocal: map['isLocal'] == true,
      mimeType: map['mimeType'],
    );
  }
}

class AMCRecord {
  final String id;
  final String productId;
  final String productName;
  final String provider;
  final String planName;
  final String startDate;
  final String endDate;
  final double cost;
  final String status; // 'Active', 'Expiring Soon', 'Expired'
  final String contactNumber;
  final int freeServicesRemaining;

  AMCRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.provider,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.cost,
    required this.status,
    required this.contactNumber,
    this.freeServicesRemaining = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'provider': provider,
      'planName': planName,
      'startDate': startDate,
      'endDate': endDate,
      'cost': cost,
      'status': status,
      'contactNumber': contactNumber,
      'freeServicesRemaining': freeServicesRemaining,
    };
  }

  factory AMCRecord.fromMap(Map<String, dynamic> map, [String? docId]) {
    return AMCRecord(
      id: docId ?? map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      provider: map['provider'] ?? '',
      planName: map['planName'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Active',
      contactNumber: map['contactNumber'] ?? '',
      freeServicesRemaining: (map['freeServicesRemaining'] as num?)?.toInt() ?? 2,
    );
  }
}

class InsurancePolicy {
  final String id;
  final String productId;
  final String productName;
  final String provider;
  final String policyNumber;
  final double premiumAmount;
  final double coverageAmount;
  final String startDate;
  final String expiryDate;
  final String status;

  InsurancePolicy({
    required this.id,
    required this.productId,
    required this.productName,
    required this.provider,
    required this.policyNumber,
    required this.premiumAmount,
    required this.coverageAmount,
    required this.startDate,
    required this.expiryDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'provider': provider,
      'policyNumber': policyNumber,
      'premiumAmount': premiumAmount,
      'coverageAmount': coverageAmount,
      'startDate': startDate,
      'expiryDate': expiryDate,
      'status': status,
    };
  }

  factory InsurancePolicy.fromMap(Map<String, dynamic> map, [String? docId]) {
    return InsurancePolicy(
      id: docId ?? map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      provider: map['provider'] ?? '',
      policyNumber: map['policyNumber'] ?? '',
      premiumAmount: (map['premiumAmount'] as num?)?.toDouble() ?? 0.0,
      coverageAmount: (map['coverageAmount'] as num?)?.toDouble() ?? 0.0,
      startDate: map['startDate'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      status: map['status'] ?? 'Active',
    );
  }
}

class WarrantyClaim {
  final String id;
  final String productId;
  final String productName;
  final String ticketNumber;
  final String claimDate;
  final String description;
  final String serviceCenter;
  final String status; // 'Submitted', 'Under Review', 'Approved', 'In Progress', 'Resolved', 'Rejected'
  final String technicianAssigned;
  final double claimAmount;

  WarrantyClaim({
    required this.id,
    required this.productId,
    required this.productName,
    required this.ticketNumber,
    required this.claimDate,
    required this.description,
    required this.serviceCenter,
    required this.status,
    this.technicianAssigned = 'Pending Allocation',
    this.claimAmount = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'ticketNumber': ticketNumber,
      'claimDate': claimDate,
      'description': description,
      'serviceCenter': serviceCenter,
      'status': status,
      'technicianAssigned': technicianAssigned,
      'claimAmount': claimAmount,
    };
  }

  factory WarrantyClaim.fromMap(Map<String, dynamic> map, [String? docId]) {
    return WarrantyClaim(
      id: docId ?? map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      ticketNumber: map['ticketNumber'] ?? '',
      claimDate: map['claimDate'] ?? '',
      description: map['description'] ?? '',
      serviceCenter: map['serviceCenter'] ?? '',
      status: map['status'] ?? 'Submitted',
      technicianAssigned: map['technicianAssigned'] ?? 'Pending Allocation',
      claimAmount: (map['claimAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String role;
  final String relation;
  final String email;
  final String permissions;

  FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    required this.relation,
    required this.email,
    required this.permissions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'relation': relation,
      'email': email,
      'permissions': permissions,
    };
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map, [String? docId]) {
    return FamilyMember(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      relation: map['relation'] ?? '',
      email: map['email'] ?? '',
      permissions: map['permissions'] ?? '',
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String date;
  final String type; // 'expiry', 'service', 'amc', 'claim', 'system'
  bool unread;
  final String? productId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.unread = true,
    this.productId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'date': date,
      'type': type,
      'unread': unread,
      'productId': productId,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, [String? docId]) {
    return AppNotification(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      date: map['date'] ?? '',
      type: map['type'] ?? 'system',
      unread: map['unread'] ?? true,
      productId: map['productId'],
    );
  }
}

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String? uid;
  final bool isPro;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.uid,
    this.isPro = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'uid': uid,
      'isPro': isPro,
      'lastActive': DateTime.now().toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, [String? uid]) {
    return UserProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      uid: uid ?? map['uid'],
      isPro: map['isPro'] ?? true,
    );
  }
}
