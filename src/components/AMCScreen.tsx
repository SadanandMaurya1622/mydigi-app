import React, { useState } from 'react';
import { 
  ArrowLeft, 
  Plus, 
  PhoneCall 
} from 'lucide-react';
import { AMCRecord, InsuranceRecord, ProductItem } from '../types';
import { Language, TRANSLATIONS } from '../utils/translations';
import confetti from 'canvas-confetti';

interface AMCScreenProps {
  amcRecords: AMCRecord[];
  insuranceRecords: InsuranceRecord[];
  products: ProductItem[];
  onBack: () => void;
  language: Language;
}

export const AMCScreen: React.FC<AMCScreenProps> = ({
  amcRecords,
  insuranceRecords,
  onBack,
  language,
}) => {
  const t = TRANSLATIONS[language];
  const [activeTab, setActiveTab] = useState<'amc' | 'insurance'>('amc');
  const [showAddModal, setShowAddModal] = useState(false);

  return (
    <div className="p-4 sm:p-6 space-y-4 pb-24 relative min-h-full">
      {/* 1. Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <button
            onClick={onBack}
            className="p-2 rounded-2xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-200 cursor-pointer"
          >
            <ArrowLeft className="w-4 h-4" />
          </button>
          <div>
            <h1 className="text-xl font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
              {t.amcTracker}
            </h1>
            <p className="text-[11px] text-slate-500">Protect assets with maintenance contracts</p>
          </div>
        </div>

        <button
          onClick={() => setShowAddModal(true)}
          className="p-2.5 rounded-2xl bg-indigo-600 text-white font-bold text-xs shadow-md shadow-indigo-600/30 flex items-center space-x-1 cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Add Plan</span>
        </button>
      </div>

      {/* 2. Tab Selectors */}
      <div className="grid grid-cols-2 gap-2 bg-slate-200/70 dark:bg-slate-800/70 p-1 rounded-2xl text-xs font-bold">
        <button
          onClick={() => setActiveTab('amc')}
          className={`py-2 rounded-xl transition-all cursor-pointer ${
            activeTab === 'amc'
              ? 'bg-white dark:bg-slate-900 text-indigo-600 dark:text-indigo-400 shadow-xs'
              : 'text-slate-600 dark:text-slate-400'
          }`}
        >
          AMC Plans ({amcRecords.length})
        </button>
        <button
          onClick={() => setActiveTab('insurance')}
          className={`py-2 rounded-xl transition-all cursor-pointer ${
            activeTab === 'insurance'
              ? 'bg-white dark:bg-slate-900 text-teal-600 dark:text-teal-400 shadow-xs'
              : 'text-slate-600 dark:text-slate-400'
          }`}
        >
          Insurance Policies ({insuranceRecords.length})
        </button>
      </div>

      {/* 3. AMC List (Matching Screen 12) */}
      {activeTab === 'amc' && (
        <div className="space-y-3 animate-in fade-in">
          {amcRecords.map((item) => (
            <div
              key={item.id}
              className="p-5 rounded-3xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs space-y-3"
            >
              <div className="flex items-start justify-between">
                <div>
                  <span className="text-[10px] font-bold text-indigo-600 dark:text-indigo-400 uppercase tracking-wider">
                    {item.planName || 'Comprehensive AMC'}
                  </span>
                  <h3 className="text-sm font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                    {item.productName}
                  </h3>
                  <p className="text-[11px] text-slate-500">Provider: {item.provider}</p>
                </div>

                <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800">
                  {item.status}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-2 text-xs pt-1">
                <div className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800/80">
                  <span className="text-slate-400 block text-[10px]">Annual Cost</span>
                  <span className="font-black text-slate-900 dark:text-white">₹{item.cost.toLocaleString('en-IN')}/yr</span>
                </div>
                <div className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800/80">
                  <span className="text-slate-400 block text-[10px]">Next Scheduled Service</span>
                  <span className="font-bold text-indigo-600 dark:text-indigo-400">{item.nextServiceDate || 'Dec 2026'}</span>
                </div>
              </div>

              <div className="flex items-center justify-between text-xs text-slate-500 pt-1 border-t border-slate-100 dark:border-slate-800">
                <span>Free Services: <strong className="text-slate-900 dark:text-white">{item.freeServicesRemaining ?? 2} Left</strong></span>
                <span>Valid: {item.startDate} to {item.expiryDate || item.endDate}</span>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Insurance List */}
      {activeTab === 'insurance' && (
        <div className="space-y-3 animate-in fade-in">
          {insuranceRecords.map((item) => (
            <div
              key={item.id}
              className="p-5 rounded-3xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs space-y-3"
            >
              <div className="flex items-start justify-between">
                <div>
                  <span className="text-[10px] font-bold text-teal-600 dark:text-teal-400 uppercase tracking-wider">
                    {item.provider} • Policy #{item.policyNumber}
                  </span>
                  <h3 className="text-sm font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                    {item.productName}
                  </h3>
                  <p className="text-[11px] text-slate-500">Accidental & Theft Coverage</p>
                </div>

                <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-teal-50 dark:bg-teal-950/60 text-teal-600 dark:text-teal-400 border border-teal-200 dark:border-teal-800">
                  {item.status}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-2 text-xs pt-1">
                <div className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800/80">
                  <span className="text-slate-400 block text-[10px]">Sum Insured (IDV)</span>
                  <span className="font-black text-slate-900 dark:text-white">₹{item.coverageAmount.toLocaleString('en-IN')}</span>
                </div>
                <div className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800/80">
                  <span className="text-slate-400 block text-[10px]">Annual Premium</span>
                  <span className="font-bold text-teal-600 dark:text-teal-400">₹{item.premiumAmount.toLocaleString('en-IN')}/yr</span>
                </div>
              </div>

              <div className="flex items-center justify-between text-xs text-slate-500 pt-1 border-t border-slate-100 dark:border-slate-800">
                <span>Valid Till: <strong className="text-teal-600 dark:text-teal-400">{item.expiryDate}</strong></span>
                <button
                  onClick={() => alert(`Calling ${item.provider} Claim Helpline: 1800 258 5956`)}
                  className="text-xs font-bold text-indigo-600 dark:text-indigo-400 hover:underline flex items-center space-x-1 cursor-pointer"
                >
                  <PhoneCall className="w-3 h-3" />
                  <span>Call Helpline</span>
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add Plan Modal */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-xs">
          <div className="w-full max-w-sm bg-white dark:bg-slate-900 rounded-3xl p-5 border border-slate-200 dark:border-slate-800 space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-bold text-slate-900 dark:text-white">Add AMC / Insurance Plan</h3>
              <button onClick={() => setShowAddModal(false)} className="text-slate-400 hover:text-slate-600 cursor-pointer">✕</button>
            </div>
            <p className="text-xs text-slate-500">
              Link an AMC contract or insurance coverage policy with any registered product.
            </p>
            <button
              onClick={() => {
                confetti();
                setShowAddModal(false);
              }}
              className="w-full py-2.5 rounded-xl bg-indigo-600 text-white font-bold text-xs shadow-md shadow-indigo-600/30 cursor-pointer"
            >
              Save Protection Plan
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
