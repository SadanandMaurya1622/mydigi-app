import React, { useState } from 'react';
import { 
  X, 
  ArrowLeft, 
  ArrowRight, 
  Check, 
  ShieldCheck, 
  Receipt
} from 'lucide-react';
import { ProductItem, ProductCategory } from '../types';
import { Language, TRANSLATIONS } from '../utils/translations';
import confetti from 'canvas-confetti';

interface AddProductModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (product: ProductItem) => void;
  language: Language;
  initialData?: Partial<ProductItem>;
}

export const AddProductModal: React.FC<AddProductModalProps> = ({
  isOpen,
  onClose,
  onSave,
  language,
  initialData,
}) => {
  const t = TRANSLATIONS[language];

  const [step, setStep] = useState<number>(1);

  // Step 1: Basic Info
  const [productName, setProductName] = useState(initialData?.name || '');
  const [category, setCategory] = useState<ProductCategory>(initialData?.category || 'Appliances');
  const [brand, setBrand] = useState(initialData?.brand || '');
  const [modelNumber, setModelNumber] = useState(initialData?.modelNumber || '');
  const [serialNumber, setSerialNumber] = useState(initialData?.serialNumber || '');
  const [imeiNumber, setImeiNumber] = useState(initialData?.imeiNumber || '');

  // Step 2: Purchase Info
  const [purchaseDate, setPurchaseDate] = useState(initialData?.purchaseDate || '2026-08-20');
  const [purchasePrice, setPurchasePrice] = useState<string>(initialData?.purchasePrice ? String(initialData.purchasePrice) : '38500');
  const [sellerName, setSellerName] = useState(initialData?.sellerName || 'XYZ Electronics');
  const [sellerContact, setSellerContact] = useState(initialData?.sellerContact || '+91 98111 88990');
  const [invoiceNumber, setInvoiceNumber] = useState(initialData?.invoiceNumber || 'INV-2026-0897');

  // Step 3: Warranty Info
  const [warrantyPeriod, setWarrantyPeriod] = useState(initialData?.warrantyPeriod || '2 Years');
  const [warrantyStartDate, setWarrantyStartDate] = useState(initialData?.warrantyStartDate || '2026-08-20');
  const [warrantyEndDate, setWarrantyEndDate] = useState(initialData?.warrantyEndDate || '2028-08-20');
  const [extendedWarranty, setExtendedWarranty] = useState(initialData?.extendedWarranty || false);
  const [hasAMC, setHasAMC] = useState(initialData?.hasAMC || false);

  // Step 4: Images & Docs
  const [imageUrl, setImageUrl] = useState(initialData?.imageUrl || 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80');
  const [invoiceAttached, setInvoiceAttached] = useState(true);
  const [warrantyCardAttached, setWarrantyCardAttached] = useState(true);

  if (!isOpen) return null;

  const handleNext = () => {
    if (step < 4) {
      setStep(step + 1);
    } else {
      // Save Product
      const newProd: ProductItem = {
        id: `prod-${Date.now()}`,
        name: productName || 'New Home Appliance',
        category,
        brand: brand || 'Brand',
        modelNumber: modelNumber || 'MD-01',
        serialNumber: serialNumber || `SER-${Math.floor(100000 + Math.random() * 900000)}`,
        imeiNumber: imeiNumber || undefined,
        purchaseDate,
        purchasePrice: parseFloat(purchasePrice) || 0,
        sellerName: sellerName || 'Authorized Dealer',
        sellerContact,
        invoiceNumber: invoiceNumber || `INV-${Date.now()}`,
        warrantyPeriod,
        warrantyStartDate,
        warrantyEndDate,
        warrantyStatus: 'Active',
        daysRemaining: 730,
        extendedWarranty,
        hasAMC,
        imageUrl: imageUrl || 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80',
        costBreakdown: {
          purchase: parseFloat(purchasePrice) || 0,
          installation: 0,
          maintenance: 0,
          repair: 0,
          accessories: 0,
          amc: hasAMC ? 1500 : 0,
          other: 0,
        },
      };

      confetti({ particleCount: 75, spread: 80, origin: { y: 0.6 } });
      onSave(newProd);
      onClose();
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-xs animate-in fade-in">
      <div className="relative w-full max-w-md max-h-[92vh] flex flex-col bg-white dark:bg-slate-900 rounded-3xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
        {/* Top Header */}
        <div className="flex items-center justify-between p-5 pb-3 border-b border-slate-100 dark:border-slate-800">
          <div className="flex items-center space-x-2">
            {step > 1 && (
              <button
                onClick={() => setStep(step - 1)}
                className="p-1.5 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-slate-200"
              >
                <ArrowLeft className="w-4 h-4" />
              </button>
            )}
            <div>
              <h3 className="text-base font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                Add Product
              </h3>
              <p className="text-[11px] text-slate-500">Step {step} of 4</p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-2 rounded-full text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Multi-step Progress Indicator */}
        <div className="flex items-center px-5 pt-3 pb-1 space-x-1.5">
          {[1, 2, 3, 4].map((i) => (
            <div
              key={i}
              className={`h-1.5 rounded-full flex-1 transition-all ${
                i <= step ? 'bg-indigo-600 shadow-xs' : 'bg-slate-200 dark:bg-slate-800'
              }`}
            />
          ))}
        </div>

        {/* Scrollable Form Content */}
        <div className="flex-1 overflow-y-auto p-5 space-y-4 text-xs">
          {/* STEP 1: Basic Information */}
          {step === 1 && (
            <div className="space-y-3.5 animate-in fade-in">
              <span className="font-bold text-slate-800 dark:text-slate-200 block text-sm">
                Basic Information
              </span>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Product Name</label>
                <input
                  type="text"
                  value={productName}
                  onChange={(e) => setProductName(e.target.value)}
                  placeholder="e.g. Samsung AC 1.5 Ton, LG Refrigerator..."
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-medium focus:ring-2 focus:ring-indigo-500"
                  required
                />
              </div>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Category</label>
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value as ProductCategory)}
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-medium focus:ring-2 focus:ring-indigo-500"
                >
                  <option value="Appliances">Appliances</option>
                  <option value="Electronics">Electronics</option>
                  <option value="Vehicle">Vehicle</option>
                  <option value="Furniture">Furniture</option>
                  <option value="Gadgets">Gadgets</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div className="grid grid-cols-2 gap-2.5">
                <div>
                  <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Brand</label>
                  <input
                    type="text"
                    value={brand}
                    onChange={(e) => setBrand(e.target.value)}
                    placeholder="e.g. Samsung, LG, Apple"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Model Number</label>
                  <input
                    type="text"
                    value={modelNumber}
                    onChange={(e) => setModelNumber(e.target.value)}
                    placeholder="e.g. AR18TYSYAWKN"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-mono"
                  />
                </div>
              </div>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Serial Number</label>
                <input
                  type="text"
                  value={serialNumber}
                  onChange={(e) => setSerialNumber(e.target.value)}
                  placeholder="e.g. XXXXXXXX1234"
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-mono"
                />
              </div>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">IMEI Number (Optional)</label>
                <input
                  type="text"
                  value={imeiNumber}
                  onChange={(e) => setImeiNumber(e.target.value)}
                  placeholder="For phones/tablets: 356789012345678"
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-mono"
                />
              </div>
            </div>
          )}

          {/* STEP 2: Purchase Information */}
          {step === 2 && (
            <div className="space-y-3.5 animate-in fade-in">
              <span className="font-bold text-slate-800 dark:text-slate-200 block text-sm">
                Purchase Information
              </span>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Purchase Date</label>
                <input
                  type="date"
                  value={purchaseDate}
                  onChange={(e) => setPurchaseDate(e.target.value)}
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
                />
              </div>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Purchase Price (₹)</label>
                <div className="relative">
                  <span className="absolute left-3.5 top-1/2 -translate-y-1/2 font-bold text-slate-400">₹</span>
                  <input
                    type="number"
                    value={purchasePrice}
                    onChange={(e) => setPurchasePrice(e.target.value)}
                    placeholder="0.00"
                    className="w-full pl-8 pr-4 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-black"
                  />
                </div>
              </div>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Seller / Shop Name</label>
                <input
                  type="text"
                  value={sellerName}
                  onChange={(e) => setSellerName(e.target.value)}
                  placeholder="e.g. Croma, Reliance Digital, Amazon"
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
                />
              </div>

              <div className="grid grid-cols-2 gap-2.5">
                <div>
                  <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Seller Contact</label>
                  <input
                    type="text"
                    value={sellerContact}
                    onChange={(e) => setSellerContact(e.target.value)}
                    placeholder="+91 98765 43210"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Invoice Number</label>
                  <input
                    type="text"
                    value={invoiceNumber}
                    onChange={(e) => setInvoiceNumber(e.target.value)}
                    placeholder="e.g. INV-2026-1025"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-mono"
                  />
                </div>
              </div>
            </div>
          )}

          {/* STEP 3: Warranty Details */}
          {step === 3 && (
            <div className="space-y-3.5 animate-in fade-in">
              <span className="font-bold text-slate-800 dark:text-slate-200 block text-sm">
                Warranty & Maintenance
              </span>

              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Warranty Period</label>
                <input
                  type="text"
                  value={warrantyPeriod}
                  onChange={(e) => setWarrantyPeriod(e.target.value)}
                  placeholder="e.g. 1 Year, 2 Years, 5 Years"
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-semibold"
                />
              </div>

              <div className="grid grid-cols-2 gap-2.5">
                <div>
                  <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Start Date</label>
                  <input
                    type="date"
                    value={warrantyStartDate}
                    onChange={(e) => setWarrantyStartDate(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white text-xs"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">End Date</label>
                  <input
                    type="date"
                    value={warrantyEndDate}
                    onChange={(e) => setWarrantyEndDate(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white text-xs"
                  />
                </div>
              </div>

              {/* Toggles */}
              <div className="space-y-2 pt-2">
                <label className="flex items-center justify-between p-3 rounded-xl bg-slate-50 dark:bg-slate-800/80 border border-slate-200 dark:border-slate-700 cursor-pointer">
                  <span className="font-bold text-slate-800 dark:text-slate-200">Extended Warranty Plan Active</span>
                  <input
                    type="checkbox"
                    checked={extendedWarranty}
                    onChange={(e) => setExtendedWarranty(e.target.checked)}
                    className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 w-4 h-4"
                  />
                </label>

                <label className="flex items-center justify-between p-3 rounded-xl bg-slate-50 dark:bg-slate-800/80 border border-slate-200 dark:border-slate-700 cursor-pointer">
                  <span className="font-bold text-slate-800 dark:text-slate-200">Include AMC (Annual Maintenance)</span>
                  <input
                    type="checkbox"
                    checked={hasAMC}
                    onChange={(e) => setHasAMC(e.target.checked)}
                    className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 w-4 h-4"
                  />
                </label>
              </div>
            </div>
          )}

          {/* STEP 4: Documents & Photo */}
          {step === 4 && (
            <div className="space-y-3.5 animate-in fade-in">
              <span className="font-bold text-slate-800 dark:text-slate-200 block text-sm">
                Product Image & Documents
              </span>

              {/* Image Preview & URL */}
              <div>
                <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Product Photo</label>
                <div className="flex items-center space-x-3">
                  <div className="w-16 h-16 rounded-2xl bg-slate-100 dark:bg-slate-800 overflow-hidden border border-slate-200 dark:border-slate-700 shrink-0">
                    <img src={imageUrl} alt="preview" className="w-full h-full object-cover" referrerPolicy="no-referrer" />
                  </div>
                  <div className="flex-1 space-y-1">
                    <input
                      type="text"
                      value={imageUrl}
                      onChange={(e) => setImageUrl(e.target.value)}
                      placeholder="Image URL or upload"
                      className="w-full px-3 py-1.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-xs"
                    />
                    <span className="text-[10px] text-slate-400">Default photo generated</span>
                  </div>
                </div>
              </div>

              {/* Upload Mockups */}
              <div className="grid grid-cols-2 gap-2.5 pt-2">
                <div
                  onClick={() => setInvoiceAttached(!invoiceAttached)}
                  className={`p-3 rounded-2xl border-2 border-dashed flex flex-col items-center justify-center text-center cursor-pointer transition-colors ${
                    invoiceAttached
                      ? 'border-indigo-500 bg-indigo-50/50 dark:bg-indigo-950/50'
                      : 'border-slate-300 dark:border-slate-700'
                  }`}
                >
                  <Receipt className="w-6 h-6 text-indigo-600 dark:text-indigo-400 mb-1" />
                  <span className="font-bold text-slate-800 dark:text-slate-200">Invoice Bill</span>
                  <span className="text-[10px] text-emerald-600 font-semibold mt-0.5">
                    {invoiceAttached ? '✓ Attached' : '+ Click to attach'}
                  </span>
                </div>

                <div
                  onClick={() => setWarrantyCardAttached(!warrantyCardAttached)}
                  className={`p-3 rounded-2xl border-2 border-dashed flex flex-col items-center justify-center text-center cursor-pointer transition-colors ${
                    warrantyCardAttached
                      ? 'border-emerald-500 bg-emerald-50/50 dark:bg-emerald-950/50'
                      : 'border-slate-300 dark:border-slate-700'
                  }`}
                >
                  <ShieldCheck className="w-6 h-6 text-emerald-600 dark:text-emerald-400 mb-1" />
                  <span className="font-bold text-slate-800 dark:text-slate-200">Warranty Card</span>
                  <span className="text-[10px] text-emerald-600 font-semibold mt-0.5">
                    {warrantyCardAttached ? '✓ Attached' : '+ Click to attach'}
                  </span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Footer Actions */}
        <div className="p-5 pt-3 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between">
          {step > 1 ? (
            <button
              onClick={() => setStep(step - 1)}
              className="px-4 py-2.5 rounded-xl text-slate-600 dark:text-slate-300 font-bold text-xs hover:bg-slate-100 dark:hover:bg-slate-800"
            >
              Previous
            </button>
          ) : (
            <button
              onClick={onClose}
              className="px-4 py-2.5 rounded-xl text-slate-600 dark:text-slate-300 font-bold text-xs hover:bg-slate-100 dark:hover:bg-slate-800"
            >
              Cancel
            </button>
          )}

          <button
            onClick={handleNext}
            className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white font-bold text-xs shadow-md shadow-indigo-600/30 flex items-center space-x-1.5 cursor-pointer"
          >
            <span>{step === 4 ? t.saveProduct : 'Next'}</span>
            {step < 4 ? <ArrowRight className="w-4 h-4" /> : <Check className="w-4 h-4" />}
          </button>
        </div>
      </div>
    </div>
  );
};
