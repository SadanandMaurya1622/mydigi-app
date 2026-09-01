import React, { useState } from 'react';
import { 
  ArrowLeft, 
  Edit3, 
  Copy, 
  Check, 
  Calendar, 
  Tag, 
  Store, 
  Clock, 
  Receipt, 
  FileText, 
  ShieldCheck, 
  Wrench, 
  QrCode, 
  PlusCircle,
  FileCheck,
  TrendingUp,
  Download
} from 'lucide-react';
import { ProductItem, ExpenseRecord, ServiceRecord, DocumentRecord } from '../types';
import { Language, TRANSLATIONS } from '../utils/translations';

interface ProductDetailsScreenProps {
  product: ProductItem;
  expenses: ExpenseRecord[];
  services: ServiceRecord[];
  documents: DocumentRecord[];
  onBack: () => void;
  onOpenEdit: (product: ProductItem) => void;
  onOpenAddExpense: (productId: string) => void;
  onOpenAddService: (productId: string) => void;
  onOpenClaimWarranty: (productId: string) => void;
  onOpenQRCode: (product: ProductItem) => void;
  onOpenDocuments: (product: ProductItem) => void;
  language: Language;
  isDark?: boolean;
}

export const ProductDetailsScreen: React.FC<ProductDetailsScreenProps> = ({
  product,
  expenses,
  services,
  documents,
  onBack,
  onOpenEdit,
  onOpenAddExpense,
  onOpenAddService,
  onOpenClaimWarranty,
  onOpenQRCode,
  onOpenDocuments,
  language,
}) => {
  const t = TRANSLATIONS[language];
  const [activeTab, setActiveTab] = useState<'overview' | 'warranty' | 'expenses' | 'services' | 'documents'>('overview');
  const [copiedSerial, setCopiedSerial] = useState(false);

  // Filter expenses and services for this product
  const productExpenses = expenses.filter((e) => e.productId === product.id);
  const productServices = services.filter((s) => s.productId === product.id);
  const productDocuments = documents.filter((d) => d.productId === product.id);

  // Total Ownership Cost Calculation
  const additionalExpensesSum = productExpenses.reduce((acc, e) => acc + e.amount, 0);
  const totalCostOfOwnership = product.purchasePrice + (
    additionalExpensesSum > 0 
      ? additionalExpensesSum 
      : (product.costBreakdown.installation + product.costBreakdown.maintenance + product.costBreakdown.repair + product.costBreakdown.accessories + product.costBreakdown.amc)
  );

  const handleCopySerial = () => {
    navigator.clipboard?.writeText(product.serialNumber);
    setCopiedSerial(true);
    setTimeout(() => setCopiedSerial(false), 2000);
  };

  return (
    <div className="p-4 sm:p-6 space-y-5 pb-24 relative min-h-full">
      {/* 1. Navigation Top Bar */}
      <div className="flex items-center justify-between">
        <button
          id="product-detail-back-btn"
          onClick={onBack}
          className="p-2 rounded-2xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors cursor-pointer"
        >
          <ArrowLeft className="w-4 h-4" />
        </button>

        <h2 className="text-base font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
          {t.productDetails}
        </h2>

        <div className="flex items-center space-x-1.5">
          <button
            id="product-detail-qr-btn"
            onClick={() => onOpenQRCode(product)}
            className="p-2 rounded-2xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors cursor-pointer"
            title="Show QR Code"
          >
            <QrCode className="w-4 h-4 text-indigo-600 dark:text-indigo-400" />
          </button>

          <button
            id="product-detail-edit-btn"
            onClick={() => onOpenEdit(product)}
            className="p-2 rounded-2xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors cursor-pointer"
            title="Edit Product"
          >
            <Edit3 className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* 2. Hero Product Display (Matching Screen 4) */}
      <div className="rounded-3xl bg-white dark:bg-slate-850 p-4 border border-slate-200 dark:border-slate-800 shadow-sm space-y-4">
        {/* Product Image Container */}
        <div className="w-full h-48 sm:h-56 rounded-2xl bg-slate-100 dark:bg-slate-800 overflow-hidden relative border border-slate-200 dark:border-slate-700">
          <img
            src={product.imageUrl}
            alt={product.name}
            className="w-full h-full object-cover"
            referrerPolicy="no-referrer"
          />
          <div className="absolute top-3 right-3">
            <span className="px-3 py-1 rounded-full text-xs font-extrabold bg-emerald-500 text-white shadow-md shadow-emerald-500/30 flex items-center space-x-1">
              <Check className="w-3 h-3 stroke-[3]" />
              <span>{product.warrantyStatus}</span>
            </span>
          </div>
        </div>

        {/* Title & Serial Copy Row */}
        <div>
          <div className="flex items-center justify-between">
            <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
              {product.name}
            </h1>
          </div>

          <div className="flex items-center justify-between mt-1 text-xs text-slate-500 dark:text-slate-400">
            <span>Serial Number</span>
            <button
              onClick={handleCopySerial}
              className="flex items-center space-x-1 font-mono font-bold text-slate-700 dark:text-slate-300 hover:text-indigo-600 transition-colors cursor-pointer"
            >
              <span>{product.serialNumber}</span>
              {copiedSerial ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5 text-slate-400" />}
            </button>
          </div>
        </div>
      </div>

      {/* 3. Tab Selectors */}
      <div className="flex items-center space-x-1 bg-slate-200/70 dark:bg-slate-800/70 p-1 rounded-2xl overflow-x-auto scrollbar-none text-xs font-bold">
        {[
          { id: 'overview', label: 'Overview' },
          { id: 'warranty', label: 'Warranty' },
          { id: 'expenses', label: `Expenses (${productExpenses.length})` },
          { id: 'services', label: `Services (${productServices.length})` },
          { id: 'documents', label: `Docs (${productDocuments.length})` },
        ].map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as any)}
            className={`px-3 py-2 rounded-xl whitespace-nowrap transition-all cursor-pointer ${
              activeTab === tab.id
                ? 'bg-white dark:bg-slate-900 text-indigo-600 dark:text-indigo-400 shadow-xs'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* 4. Tab Content */}
      {activeTab === 'overview' && (
        <div className="space-y-4 animate-in fade-in">
          {/* Detailed Info Table (Matching Screen 4) */}
          <div className="rounded-3xl bg-white dark:bg-slate-850 p-4 border border-slate-200 dark:border-slate-800 shadow-xs divide-y divide-slate-100 dark:divide-slate-800 text-xs">
            <div className="py-2.5 flex items-center justify-between">
              <div className="flex items-center space-x-2.5 text-slate-500 dark:text-slate-400">
                <Tag className="w-4 h-4 text-indigo-500" />
                <span>Category</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white">{product.category}</span>
            </div>

            <div className="py-2.5 flex items-center justify-between">
              <div className="flex items-center space-x-2.5 text-slate-500 dark:text-slate-400">
                <Store className="w-4 h-4 text-purple-500" />
                <span>Brand</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white">{product.brand}</span>
            </div>

            <div className="py-2.5 flex items-center justify-between">
              <div className="flex items-center space-x-2.5 text-slate-500 dark:text-slate-400">
                <FileText className="w-4 h-4 text-blue-500" />
                <span>Model</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white font-mono">{product.modelNumber}</span>
            </div>

            <div className="py-2.5 flex items-center justify-between">
              <div className="flex items-center space-x-2.5 text-slate-500 dark:text-slate-400">
                <Calendar className="w-4 h-4 text-emerald-500" />
                <span>Purchase Date</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white">{product.purchaseDate}</span>
            </div>

            <div className="py-2.5 flex items-center justify-between">
              <div className="flex items-center space-x-2.5 text-slate-500 dark:text-slate-400">
                <Receipt className="w-4 h-4 text-amber-500" />
                <span>Purchase Price</span>
              </div>
              <span className="font-black text-slate-900 dark:text-white font-['Outfit',sans-serif] text-sm">
                ₹{product.purchasePrice.toLocaleString('en-IN')}
              </span>
            </div>

            <div className="py-2.5 flex items-center justify-between">
              <div className="flex items-center space-x-2.5 text-slate-500 dark:text-slate-400">
                <Store className="w-4 h-4 text-pink-500" />
                <span>Seller</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white">{product.sellerName}</span>
            </div>

            <div className="py-2.5 flex items-center justify-between">
              <div className="flex items-center space-x-2.5 text-slate-500 dark:text-slate-400">
                <Clock className="w-4 h-4 text-indigo-500" />
                <span>Warranty Period</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white">{product.warrantyPeriod}</span>
            </div>

            <div className="py-2.5 flex items-center justify-between">
              <div className="flex items-center space-x-2.5 text-slate-500 dark:text-slate-400">
                <ShieldCheck className="w-4 h-4 text-emerald-500" />
                <span>Warranty End Date</span>
              </div>
              <span className="font-black text-emerald-600 dark:text-emerald-400">{product.warrantyEndDate}</span>
            </div>

            <div className="py-2.5 flex items-center justify-between">
              <div className="flex items-center space-x-2.5 text-slate-500 dark:text-slate-400">
                <Receipt className="w-4 h-4 text-slate-400" />
                <span>Invoice Number</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white font-mono">{product.invoiceNumber}</span>
            </div>
          </div>

          {/* 5. Total Cost of Ownership Card (Section 29 of prompt) */}
          <div className="rounded-3xl bg-gradient-to-br from-slate-900 to-indigo-950 text-white p-5 border border-indigo-900/50 shadow-xl space-y-3">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <TrendingUp className="w-4 h-4 text-amber-400" />
                <span className="text-xs font-bold uppercase tracking-wider text-indigo-200">
                  Total Cost of Ownership (TCO)
                </span>
              </div>
              <span className="text-xl font-black text-amber-400 font-['Outfit',sans-serif]">
                ₹{totalCostOfOwnership.toLocaleString('en-IN')}
              </span>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-3 gap-2 pt-2 border-t border-slate-800 text-[11px]">
              <div className="p-2 rounded-xl bg-white/5">
                <span className="text-slate-400 block">Purchase</span>
                <span className="font-bold text-white">₹{product.purchasePrice.toLocaleString('en-IN')}</span>
              </div>
              <div className="p-2 rounded-xl bg-white/5">
                <span className="text-slate-400 block">Installation</span>
                <span className="font-bold text-white">₹{(product.costBreakdown.installation || 1500).toLocaleString('en-IN')}</span>
              </div>
              <div className="p-2 rounded-xl bg-white/5">
                <span className="text-slate-400 block">Maintenance</span>
                <span className="font-bold text-white">₹{(product.costBreakdown.maintenance || 6500).toLocaleString('en-IN')}</span>
              </div>
              <div className="p-2 rounded-xl bg-white/5">
                <span className="text-slate-400 block">Repair</span>
                <span className="font-bold text-white">₹{(product.costBreakdown.repair || 3000).toLocaleString('en-IN')}</span>
              </div>
              <div className="p-2 rounded-xl bg-white/5">
                <span className="text-slate-400 block">Accessories</span>
                <span className="font-bold text-white">₹{(product.costBreakdown.accessories || 2500).toLocaleString('en-IN')}</span>
              </div>
              <div className="p-2 rounded-xl bg-white/5">
                <span className="text-slate-400 block">AMC / Support</span>
                <span className="font-bold text-white">₹{(product.costBreakdown.amc || 2000).toLocaleString('en-IN')}</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Warranty Tab */}
      {activeTab === 'warranty' && (
        <div className="space-y-4 animate-in fade-in">
          <div className="rounded-3xl bg-white dark:bg-slate-850 p-5 border border-slate-200 dark:border-slate-800 shadow-xs space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">Warranty Status</span>
                <h3 className="text-lg font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                  {product.warrantyPeriod} Coverage
                </h3>
              </div>
              <span className="px-3 py-1 rounded-full text-xs font-extrabold bg-emerald-500 text-white">
                {product.warrantyStatus}
              </span>
            </div>

            <div className="p-4 rounded-2xl bg-indigo-50 dark:bg-indigo-950/50 border border-indigo-100 dark:border-indigo-900/50 space-y-2">
              <div className="flex justify-between text-xs">
                <span className="text-slate-500">Days Remaining</span>
                <span className="font-bold text-indigo-600 dark:text-indigo-400">{product.daysRemaining} Days</span>
              </div>
              <div className="w-full bg-slate-200 dark:bg-slate-700 h-2 rounded-full overflow-hidden">
                <div className="bg-indigo-600 h-full rounded-full" style={{ width: '85%' }} />
              </div>
              <div className="flex justify-between text-[11px] text-slate-400">
                <span>Start: {product.warrantyStartDate}</span>
                <span>End: {product.warrantyEndDate}</span>
              </div>
            </div>

            <div className="space-y-2 pt-2">
              <button
                onClick={() => onOpenClaimWarranty(product.id)}
                className="w-full py-3 rounded-2xl bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white font-bold text-xs shadow-md shadow-indigo-600/30 flex items-center justify-center space-x-1.5 cursor-pointer"
              >
                <ShieldCheck className="w-4 h-4" />
                <span>Claim Official Warranty</span>
              </button>

              <button
                onClick={() => onOpenQRCode(product)}
                className="w-full py-2.5 rounded-2xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 text-slate-700 dark:text-slate-300 font-bold text-xs transition-colors flex items-center justify-center space-x-1.5 cursor-pointer"
              >
                <QrCode className="w-4 h-4" />
                <span>Show QR Code Verification</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Expenses Tab */}
      {activeTab === 'expenses' && (
        <div className="space-y-3 animate-in fade-in">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 dark:text-slate-400">
              Total Expenses: ₹{productExpenses.reduce((a, b) => a + b.amount, 0).toLocaleString('en-IN')}
            </span>
            <button
              onClick={() => onOpenAddExpense(product.id)}
              className="px-3 py-1.5 rounded-xl bg-indigo-600 text-white text-xs font-bold shadow-xs cursor-pointer flex items-center space-x-1"
            >
              <PlusCircle className="w-3.5 h-3.5" />
              <span>Add Expense</span>
            </button>
          </div>

          {productExpenses.length === 0 ? (
            <div className="p-6 text-center bg-white dark:bg-slate-850 rounded-2xl border border-slate-200 dark:border-slate-800">
              <p className="text-xs text-slate-400">No additional expenses recorded yet.</p>
            </div>
          ) : (
            productExpenses.map((exp) => (
              <div key={exp.id} className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex justify-between items-center">
                <div>
                  <h4 className="text-xs font-bold text-slate-900 dark:text-white">{exp.description}</h4>
                  <p className="text-[11px] text-slate-500">{exp.category} • {exp.date}</p>
                </div>
                <span className="text-sm font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                  ₹{exp.amount.toLocaleString('en-IN')}
                </span>
              </div>
            ))
          )}
        </div>
      )}

      {/* Services Tab */}
      {activeTab === 'services' && (
        <div className="space-y-3 animate-in fade-in">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 dark:text-slate-400">
              Service History ({productServices.length})
            </span>
            <button
              onClick={() => onOpenAddService(product.id)}
              className="px-3 py-1.5 rounded-xl bg-indigo-600 text-white text-xs font-bold shadow-xs cursor-pointer flex items-center space-x-1"
            >
              <PlusCircle className="w-3.5 h-3.5" />
              <span>Add Service</span>
            </button>
          </div>

          <div className="space-y-2">
            {productServices.map((srv) => (
              <div key={srv.id} className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex justify-between items-center">
                <div>
                  <div className="flex items-center space-x-2">
                    <span className="text-xs font-bold text-slate-900 dark:text-white">{srv.serviceType}</span>
                    <span className="text-[10px] px-2 py-0.5 rounded-full bg-slate-100 dark:bg-slate-800 font-semibold">{srv.date}</span>
                  </div>
                  <p className="text-[11px] text-slate-500 mt-0.5">Tech: {srv.technicianName} ({srv.serviceProvider || 'Authorized'})</p>
                </div>
                <span className="text-xs font-black text-indigo-600 dark:text-indigo-400">
                  ₹{srv.cost}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Documents Tab */}
      {activeTab === 'documents' && (
        <div className="space-y-3 animate-in fade-in">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 dark:text-slate-400">
              Attached Documents ({productDocuments.length})
            </span>
            <button
              onClick={() => onOpenDocuments(product)}
              className="px-3 py-1.5 rounded-xl bg-indigo-600 text-white text-xs font-bold shadow-xs cursor-pointer"
            >
              View Vault
            </button>
          </div>

          <div className="space-y-2">
            {productDocuments.map((doc) => (
              <div key={doc.id} className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <div className="w-9 h-9 rounded-xl bg-indigo-50 dark:bg-indigo-950/80 text-indigo-600 dark:text-indigo-400 flex items-center justify-center">
                    <FileText className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-slate-900 dark:text-white">{doc.name}</h4>
                    <p className="text-[11px] text-slate-500">{doc.type} • {doc.size}</p>
                  </div>
                </div>
                <button
                  onClick={() => alert(`Opening ${doc.name}`)}
                  className="p-2 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 text-slate-600 dark:text-slate-300"
                >
                  <Download className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* 6. Quick Action Dock (Matching Screen 4) */}
      <div className="rounded-3xl bg-white dark:bg-slate-850 p-3 border border-slate-200 dark:border-slate-800 shadow-md grid grid-cols-4 gap-2">
        <button
          onClick={() => onOpenDocuments(product)}
          className="flex flex-col items-center justify-center p-2 rounded-2xl bg-slate-50 dark:bg-slate-800/80 hover:bg-indigo-50 dark:hover:bg-indigo-950/50 transition-colors cursor-pointer"
        >
          <Receipt className="w-5 h-5 text-indigo-600 dark:text-indigo-400" />
          <span className="text-[11px] font-bold text-slate-800 dark:text-slate-200 mt-1">Invoice</span>
        </button>

        <button
          onClick={() => setActiveTab('warranty')}
          className="flex flex-col items-center justify-center p-2 rounded-2xl bg-slate-50 dark:bg-slate-800/80 hover:bg-emerald-50 dark:hover:bg-emerald-950/50 transition-colors cursor-pointer"
        >
          <ShieldCheck className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
          <span className="text-[11px] font-bold text-slate-800 dark:text-slate-200 mt-1">Warranty</span>
        </button>

        <button
          onClick={() => onOpenAddService(product.id)}
          className="flex flex-col items-center justify-center p-2 rounded-2xl bg-slate-50 dark:bg-slate-800/80 hover:bg-blue-50 dark:hover:bg-blue-950/50 transition-colors cursor-pointer"
        >
          <Wrench className="w-5 h-5 text-blue-600 dark:text-blue-400" />
          <span className="text-[11px] font-bold text-slate-800 dark:text-slate-200 mt-1">Service</span>
        </button>

        <button
          onClick={() => onOpenClaimWarranty(product.id)}
          className="flex flex-col items-center justify-center p-2 rounded-2xl bg-slate-50 dark:bg-slate-800/80 hover:bg-purple-50 dark:hover:bg-purple-950/50 transition-colors cursor-pointer"
        >
          <FileCheck className="w-5 h-5 text-purple-600 dark:text-purple-400" />
          <span className="text-[11px] font-bold text-slate-800 dark:text-slate-200 mt-1">Claim</span>
        </button>
      </div>
    </div>
  );
};
