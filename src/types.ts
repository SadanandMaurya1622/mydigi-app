export type ProductCategory = 
  | 'Electronics' 
  | 'Appliances' 
  | 'Vehicle' 
  | 'Furniture' 
  | 'Gadgets' 
  | 'Other';

export type WarrantyStatus = 'Active' | 'Expiring Soon' | 'Expired';

export type ExpenseCategory = 
  | 'Purchase' 
  | 'Repair' 
  | 'Maintenance' 
  | 'Service' 
  | 'Installation' 
  | 'Accessories' 
  | 'AMC' 
  | 'Insurance' 
  | 'Other';

export interface ServiceRecord {
  id: string;
  productId: string;
  date: string;
  serviceType: string;
  cost: number;
  technicianName: string;
  serviceProvider?: string;
  description?: string;
  billUrl?: string;
  nextServiceDate?: string;
}

export interface ExpenseRecord {
  id: string;
  productId: string;
  productName: string;
  category: ExpenseCategory;
  date: string;
  amount: number;
  description?: string;
  title?: string;
  technicianOrVendor?: string;
  serviceCenter?: string;
  technicianName?: string;
  technicianPhone?: string;
  billUrl?: string;
  invoiceUrl?: string;
  notes?: string;
  isUnderWarranty?: boolean;
}

export interface DocumentRecord {
  id: string;
  productId: string;
  productName: string;
  name: string;
  type: 'Invoice' | 'Warranty Card' | 'Service Bill' | 'AMC Document' | 'Insurance' | 'Manual';
  fileType?: 'PDF' | 'JPG' | 'PNG';
  size: string;
  uploadDate: string;
  previewUrl?: string;
}

export interface AMCRecord {
  id: string;
  productId: string;
  productName: string;
  provider: string;
  planName?: string;
  startDate: string;
  expiryDate?: string;
  endDate?: string;
  cost: number;
  status: 'Active' | 'Expiring Soon' | 'Expired';
  contactNumber?: string;
  policyNo?: string;
  nextServiceDate?: string;
  freeServicesRemaining?: number;
}

export interface InsurancePolicy {
  id: string;
  productId: string;
  productName: string;
  provider: string;
  policyNumber: string;
  premiumAmount: number;
  coverageAmount: number;
  startDate: string;
  expiryDate: string;
  status: 'Active' | 'Expiring Soon' | 'Expired';
}

export type InsuranceRecord = InsurancePolicy;

export interface WarrantyClaim {
  id: string;
  productId: string;
  productName: string;
  ticketNumber: string;
  claimDate: string;
  claimType?: string;
  issueType?: string;
  description: string;
  issueDescription?: string;
  serviceCenter: string;
  status: 'Submitted' | 'Under Review' | 'Approved' | 'In Progress' | 'Resolved' | 'Rejected';
  technicianAssigned?: string;
  trackingSteps?: { title: string; date: string; status: 'done' | 'current' | 'upcoming'; description?: string }[];
  timeline?: { title: string; date: string; description: string; done: boolean }[];
}

export interface FamilyMember {
  id: string;
  name: string;
  role: 'Owner' | 'Admin' | 'Member';
  relation: string;
  email: string;
  avatar: string;
  permissions: 'View Only' | 'Add Expense' | 'Manage Products' | 'Admin';
}

export interface ProductItem {
  id: string;
  name: string;
  category: ProductCategory;
  brand: string;
  modelNumber: string;
  serialNumber: string;
  imeiNumber?: string;
  purchaseDate: string;
  purchasePrice: number;
  sellerName: string;
  sellerContact?: string;
  invoiceNumber: string;
  warrantyPeriod: string; // e.g. "5 Years", "1 Year"
  warrantyStartDate: string;
  warrantyEndDate: string;
  warrantyStatus: WarrantyStatus;
  daysRemaining: number;
  extendedWarranty?: boolean;
  hasAMC?: boolean;
  imageUrl: string;
  costBreakdown: {
    purchase: number;
    installation: number;
    maintenance: number;
    repair: number;
    accessories: number;
    amc: number;
    other: number;
  };
  notes?: string;
}

export interface AppNotification {
  id: string;
  title: string;
  message: string;
  time?: string;
  date?: string;
  type: 'warranty' | 'service' | 'invoice' | 'insurance' | 'system' | 'expiry_warning' | 'service_due';
  unread: boolean;
  productId?: string;
}

export type NavTab = 'home' | 'products' | 'add' | 'expenses' | 'more';
export type TabType = NavTab;

export interface UserProfile {
  name: string;
  email: string;
  phone?: string;
  isPro?: boolean;
}
