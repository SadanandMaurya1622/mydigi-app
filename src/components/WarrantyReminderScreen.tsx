import React, { useState } from 'react';
import { 
  ArrowLeft, 
  Bell, 
  ChevronRight, 
  Settings2
} from 'lucide-react';
import { ProductItem } from '../types';
import { Language } from '../utils/translations';

interface WarrantyReminderScreenProps {
  products: ProductItem[];
  onBack: () => void;
  onSelectProduct: (product: ProductItem) => void;
  language: Language;
}

export const WarrantyReminderScreen: React.FC<WarrantyReminderScreenProps> = ({
  products,
  onBack,
  onSelectProduct,
}) => {
  // Active reminders intervals state
  const [selectedIntervals, setSelectedIntervals] = useState<number[]>([180, 90, 30, 7, 1]);

  const toggleInterval = (days: number) => {
    if (selectedIntervals.includes(days)) {
      setSelectedIntervals(selectedIntervals.filter((d) => d !== days));
    } else {
      setSelectedIntervals([...selectedIntervals, days]);
    }
  };

  // Samsung AC is the critical 7-day reminder
  const criticalProduct = products.find((p) => p.name.includes('Samsung AC')) || products[0];

  const reminderList = products.filter((p) => p.warrantyStatus !== 'Expired');

  return (
    <div className="p-4 sm:p-6 space-y-5 pb-24 relative min-h-full">
      {/* 1. Header */}
      <div className="flex items-center justify-between">
        <button
          onClick={onBack}
          className="p-2 rounded-2xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors cursor-pointer"
        >
          <ArrowLeft className="w-4 h-4" />
        </button>

        <h2 className="text-base font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
          Warranty Reminder
        </h2>

        <div className="w-8" />
      </div>

      {/* 2. Highlighted Critical Alert Card (Matching Screen 8) */}
      <div className="rounded-3xl bg-gradient-to-br from-rose-500/10 via-amber-500/10 to-orange-500/15 dark:from-rose-950/40 dark:to-orange-950/40 border-2 border-rose-400/40 dark:border-rose-600/40 p-5 shadow-lg space-y-4">
        <div className="flex items-center space-x-3">
          <div className="w-12 h-12 rounded-2xl bg-rose-500 text-white flex items-center justify-center shadow-md shadow-rose-500/30 shrink-0 animate-bounce">
            <Bell className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xl sm:text-2xl font-black text-rose-600 dark:text-rose-400 font-['Outfit',sans-serif]">
              7 Days Left
            </div>
            <p className="text-xs font-bold text-slate-700 dark:text-slate-200">
              Warranty will expire soon!
            </p>
          </div>
        </div>

        {/* Product Details Inside Banner */}
        <div className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-rose-200 dark:border-rose-900/50 shadow-xs space-y-2">
          <div className="flex items-center justify-between">
            <h4 className="text-sm font-bold text-slate-900 dark:text-white">
              {criticalProduct.name}
            </h4>
            <span className="text-[10px] font-extrabold text-rose-600 dark:text-rose-400 bg-rose-50 dark:bg-rose-950/80 px-2 py-0.5 rounded-full border border-rose-200 dark:border-rose-800">
              7 Days Left
            </span>
          </div>

          <p className="text-[11px] text-slate-500 font-mono">
            Serial: {criticalProduct.serialNumber}
          </p>

          <div className="flex items-center justify-between text-xs pt-1 border-t border-slate-100 dark:border-slate-800">
            <span className="text-slate-400">Warranty End Date:</span>
            <span className="font-bold text-rose-600 dark:text-rose-400">{criticalProduct.warrantyEndDate}</span>
          </div>

          <button
            onClick={() => onSelectProduct(criticalProduct)}
            className="w-full py-2.5 rounded-xl bg-gradient-to-r from-rose-600 to-amber-600 hover:from-rose-500 hover:to-amber-500 text-white font-bold text-xs shadow-md shadow-rose-600/30 transition-all flex items-center justify-center cursor-pointer mt-2"
          >
            <span>View Product Details</span>
          </button>
        </div>
      </div>

      {/* 3. All Reminders List (Matching Screen 8) */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
            All Reminders
          </span>
          <span className="text-[11px] text-indigo-600 dark:text-indigo-400 font-semibold">
            {reminderList.length} Active Reminders
          </span>
        </div>

        <div className="space-y-2.5">
          {reminderList.map((item) => (
            <div
              key={item.id}
              onClick={() => onSelectProduct(item)}
              className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between hover:border-indigo-400 dark:hover:border-indigo-600 transition-all cursor-pointer"
            >
              <div>
                <h4 className="text-xs sm:text-sm font-bold text-slate-900 dark:text-white">
                  {item.name}
                </h4>
                <p className="text-[11px] text-slate-500 dark:text-slate-400">
                  {item.warrantyEndDate}
                </p>
              </div>

              <div className="flex items-center space-x-2">
                <span
                  className={`px-2.5 py-0.5 rounded-full text-[10px] font-extrabold ${
                    item.daysRemaining <= 7
                      ? 'bg-rose-50 dark:bg-rose-950/60 text-rose-600 dark:text-rose-400 border border-rose-200 dark:border-rose-800'
                      : item.daysRemaining <= 30
                      ? 'bg-amber-50 dark:bg-amber-950/60 text-amber-600 dark:text-amber-400 border border-amber-200 dark:border-amber-800'
                      : item.daysRemaining <= 180
                      ? 'bg-orange-50 dark:bg-orange-950/60 text-orange-600 dark:text-orange-400 border border-orange-200 dark:border-orange-800'
                      : 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800'
                  }`}
                >
                  {item.daysRemaining <= 30 
                    ? `${item.daysRemaining} Days Left`
                    : `${Math.round(item.daysRemaining / 30)} Months Left`}
                </span>
                <ChevronRight className="w-4 h-4 text-slate-300" />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* 4. Reminder Configuration Frequency Settings */}
      <div className="rounded-3xl bg-white dark:bg-slate-850 p-4 sm:p-5 border border-slate-200 dark:border-slate-800 shadow-xs space-y-3">
        <div className="flex items-center space-x-2">
          <Settings2 className="w-4 h-4 text-indigo-600 dark:text-indigo-400" />
          <span className="text-xs font-bold text-slate-900 dark:text-white">
            Smart Alert Triggers
          </span>
        </div>
        <p className="text-[11px] text-slate-500">
          Notify me in advance before warranty, AMC or insurance expiry:
        </p>

        <div className="grid grid-cols-3 sm:grid-cols-5 gap-2 pt-1">
          {[
            { days: 180, label: '180 Days' },
            { days: 90, label: '90 Days' },
            { days: 30, label: '30 Days' },
            { days: 7, label: '7 Days' },
            { days: 1, label: '1 Day' },
          ].map((item) => {
            const active = selectedIntervals.includes(item.days);
            return (
              <button
                key={item.days}
                onClick={() => toggleInterval(item.days)}
                className={`py-2 px-2 rounded-xl text-xs font-bold border transition-all cursor-pointer ${
                  active
                    ? 'bg-indigo-600 text-white border-indigo-600 shadow-xs'
                    : 'bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300 border-slate-200 dark:border-slate-700'
                }`}
              >
                {item.label}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};
