import React, { useState } from 'react';
import { 
  X, 
  Wrench, 
  Settings, 
  Headphones, 
  ShieldCheck, 
  ShieldAlert, 
  MoreHorizontal, 
  Camera, 
  Upload, 
  Check, 
  Receipt
} from 'lucide-react';
import { ProductItem, ExpenseCategory, ExpenseRecord } from '../types';
import { Language, TRANSLATIONS } from '../utils/translations';
import confetti from 'canvas-confetti';

interface AddExpenseModalProps {
  isOpen: boolean;
  onClose: () => void;
  products: ProductItem[];
  defaultProductId?: string;
  onSave?: (expense: ExpenseRecord) => void;
  onSaveExpense?: (expense: ExpenseRecord) => void;
  language: Language;
}

export const AddExpenseModal: React.FC<AddExpenseModalProps> = ({
  isOpen,
  onClose,
  products,
  defaultProductId,
  onSave,
  onSaveExpense,
  language,
}) => {
  const t = TRANSLATIONS[language];

  const [productId, setProductId] = useState(defaultProductId || products[0]?.id || '');
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState<ExpenseCategory>('Service');
  const [amount, setAmount] = useState<number | ''>('');
  const [date, setDate] = useState('2026-08-25');
  const [serviceCenter, setServiceCenter] = useState('Authorized Brand Service');
  const [technicianName, setTechnicianName] = useState('');
  const [technicianPhone, setTechnicianPhone] = useState('');
  const [notes, setNotes] = useState('');
  const [warrantyCovered, setWarrantyCovered] = useState(false);
  const [billImage, setBillImage] = useState<string | null>(null);

  if (!isOpen) return null;

  const categories: { label: ExpenseCategory; icon: any }[] = [
    { label: 'Service', icon: Wrench },
    { label: 'Repair', icon: Settings },
    { label: 'Installation', icon: ShieldCheck },
    { label: 'Accessories', icon: Headphones },
    { label: 'AMC', icon: ShieldAlert },
    { label: 'Other', icon: MoreHorizontal },
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!amount || amount <= 0) return;

    const selectedProduct = products.find((p) => p.id === productId) || products[0];

    const newExpense: ExpenseRecord = {
      id: `exp-${Date.now()}`,
      productId: selectedProduct?.id || 'prod-custom',
      productName: selectedProduct?.name || 'Custom Product',
      category,
      title: title || `${category} for ${selectedProduct?.name || 'Item'}`,
      amount: Number(amount),
      date,
      serviceCenter: serviceCenter || undefined,
      technicianName: technicianName || undefined,
      technicianPhone: technicianPhone || undefined,
      billUrl: billImage || 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
      notes: notes || undefined,
      isUnderWarranty: warrantyCovered,
    };

    confetti({ particleCount: 60, spread: 60 });
    if (onSave) onSave(newExpense);
    if (onSaveExpense) onSaveExpense(newExpense);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-xs animate-in fade-in">
      <div className="relative w-full max-w-md max-h-[90vh] flex flex-col bg-white dark:bg-slate-900 rounded-3xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-5 pb-3 border-b border-slate-100 dark:border-slate-800">
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 rounded-xl bg-purple-50 dark:bg-purple-950/80 text-purple-600 dark:text-purple-400 flex items-center justify-center">
              <Receipt className="w-4 h-4" />
            </div>
            <div>
              <h3 className="text-base font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                {t.addExpense}
              </h3>
              <p className="text-[11px] text-slate-500">Record maintenance, repair & part costs</p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-2 rounded-full text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 cursor-pointer"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Scrollable Form */}
        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-5 space-y-4 text-xs">
          {/* 1. Target Product Selector */}
          <div>
            <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Select Product *</label>
            <select
              value={productId}
              onChange={(e) => setProductId(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-bold"
              required
            >
              {products.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name} ({p.brand})
                </option>
              ))}
            </select>
          </div>

          {/* 2. Expense Category Pills */}
          <div>
            <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1.5">Expense Category</label>
            <div className="grid grid-cols-3 gap-2">
              {categories.map((cat) => {
                const IconComponent = cat.icon;
                const isSelected = category === cat.label;
                return (
                  <button
                    type="button"
                    key={cat.label}
                    onClick={() => setCategory(cat.label)}
                    className={`p-2 rounded-xl border flex flex-col items-center justify-center space-y-1 transition-all cursor-pointer ${
                      isSelected
                        ? 'border-indigo-600 bg-indigo-50 dark:bg-indigo-950/80 text-indigo-600 dark:text-indigo-400 font-black shadow-xs'
                        : 'border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/60 text-slate-600 dark:text-slate-400 font-medium'
                    }`}
                  >
                    <IconComponent className="w-4 h-4" />
                    <span className="text-[11px]">{cat.label}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* 3. Expense Title & Amount */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Expense Title</label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g. Filter change"
                className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
              />
            </div>

            <div>
              <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Amount (₹) *</label>
              <input
                type="number"
                value={amount}
                onChange={(e) => setAmount(e.target.value === '' ? '' : Number(e.target.value))}
                placeholder="₹ 1,500"
                className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white font-bold"
                required
              />
            </div>
          </div>

          {/* 4. Date & Service Center */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Date</label>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
              />
            </div>

            <div>
              <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Service Center</label>
              <input
                type="text"
                value={serviceCenter}
                onChange={(e) => setServiceCenter(e.target.value)}
                placeholder="Authorized Care"
                className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
              />
            </div>
          </div>

          {/* 5. Technician Contact info */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Technician Name</label>
              <input
                type="text"
                value={technicianName}
                onChange={(e) => setTechnicianName(e.target.value)}
                placeholder="Ramesh Kumar"
                className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
              />
            </div>

            <div>
              <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Phone Number</label>
              <input
                type="tel"
                value={technicianPhone}
                onChange={(e) => setTechnicianPhone(e.target.value)}
                placeholder="+91 98765 00000"
                className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
              />
            </div>
          </div>

          {/* 6. Under Warranty Checkbox */}
          <div className="flex items-center space-x-2 pt-1">
            <input
              type="checkbox"
              id="wtyCovered"
              checked={warrantyCovered}
              onChange={(e) => setWarrantyCovered(e.target.checked)}
              className="w-4 h-4 rounded text-indigo-600 focus:ring-indigo-500"
            />
            <label htmlFor="wtyCovered" className="font-semibold text-slate-700 dark:text-slate-300">
              Covered under Brand / Extended Warranty (Free of charge)
            </label>
          </div>

          {/* 7. Bill Upload Simulation */}
          <div>
            <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Attach Repair Bill / Slip</label>
            <div className="p-3 rounded-2xl border-2 border-dashed border-slate-200 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-800/40 flex items-center justify-between">
              <div className="flex items-center space-x-2 text-slate-500">
                <Upload className="w-4 h-4 text-indigo-500" />
                <span className="text-[11px]">{billImage ? 'Receipt attached (1.2 MB)' : 'Upload or snap bill photo'}</span>
              </div>
              <button
                type="button"
                onClick={() => setBillImage('https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80')}
                className="px-2.5 py-1 rounded-lg bg-indigo-600 text-white font-bold text-[10px] flex items-center space-x-1 cursor-pointer"
              >
                <Camera className="w-3 h-3" />
                <span>Snap Bill</span>
              </button>
            </div>
          </div>

          {/* 8. Additional Notes */}
          <div>
            <label className="block font-bold text-slate-700 dark:text-slate-300 mb-1">Service Notes / Remarks</label>
            <textarea
              rows={2}
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="e.g. Compressor gas refilled, 6 months warranty on replaced parts"
              className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white"
            />
          </div>

          {/* Submit */}
          <div className="pt-2">
            <button
              type="submit"
              className="w-full py-3 rounded-2xl bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white font-black text-xs shadow-lg shadow-indigo-600/30 flex items-center justify-center space-x-1.5 cursor-pointer"
            >
              <Check className="w-4 h-4" />
              <span>{t.saveExpense}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
