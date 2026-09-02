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

  DocumentRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.name,
    required this.type,
    required this.size,
    required this.uploadDate,
    this.previewUrl,
  });
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
}
