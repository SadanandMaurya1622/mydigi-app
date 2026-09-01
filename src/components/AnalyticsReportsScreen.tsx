import React from 'react';
import { 
  ArrowLeft, 
  Download, 
  FileSpreadsheet, 
  FileText, 
  PieChart, 
  BarChart3 
} from 'lucide-react';
import { ProductItem, ExpenseRecord } from '../types';
import { Language } from '../utils/translations';
import confetti from 'canvas-confetti';

interface AnalyticsReportsScreenProps {
  products: ProductItem[];
  expenses: ExpenseRecord[];
  onBack: () => void;
  language: Language;
}

export const AnalyticsReportsScreen: React.FC<AnalyticsReportsScreenProps> = ({
  products,
  expenses,
  onBack,
}) => {
  const totalPurchaseValue = products.reduce((a, b) => a + b.purchasePrice, 0);
  const totalMaintenance = expenses.reduce((a, b) => a + b.amount, 0);

  const categoryBreakdown = [
    { name: 'Appliances', percentage: 45, color: 'bg-indigo-600' },
    { name: 'Electronics', percentage: 35, color: 'bg-purple-600' },
    { name: 'Vehicle', percentage: 15, color: 'bg-teal-500' },
    { name: 'Furniture', percentage: 5, color: 'bg-amber-500' },
  ];

  const handleDownloadReport = (type: 'pdf' | 'csv') => {
    confetti({ particleCount: 40 });
    alert(`Successfully generated WarrantyX ${type.toUpperCase()} Asset & Expense Report!`);
  };

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
              Reports & Analytics
            </h1>
            <p className="text-[11px] text-slate-500">Asset valuation & ownership cost breakdown</p>
          </div>
        </div>

        <button
          onClick={() => handleDownloadReport('pdf')}
          className="p-2.5 rounded-2xl bg-indigo-600 text-white font-bold text-xs shadow-md shadow-indigo-600/30 flex items-center space-x-1 cursor-pointer"
        >
          <Download className="w-4 h-4" />
          <span>Export</span>
        </button>
      </div>

      {/* 2. Top Summary Metrics Grid */}
      <div className="grid grid-cols-2 gap-2.5">
        <div className="p-4 rounded-3xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs space-y-1">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Asset Valuation</span>
          <div className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
            ₹{totalPurchaseValue.toLocaleString('en-IN')}
          </div>
          <span className="text-[10px] text-emerald-600 font-bold block">{products.length} registered items</span>
        </div>

        <div className="p-4 rounded-3xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs space-y-1">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Total Maintenance</span>
          <div className="text-xl sm:text-2xl font-black text-purple-600 dark:text-purple-400 font-['Outfit',sans-serif]">
            ₹{totalMaintenance.toLocaleString('en-IN')}
          </div>
          <span className="text-[10px] text-purple-500 font-bold block">{expenses.length} repair logs</span>
        </div>
      </div>

      {/* 3. Category Portfolio Distribution */}
      <div className="rounded-3xl bg-white dark:bg-slate-850 p-5 border border-slate-200 dark:border-slate-800 shadow-xs space-y-3">
        <div className="flex items-center justify-between">
          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
            Category Asset Distribution
          </span>
          <PieChart className="w-4 h-4 text-indigo-500" />
        </div>

        {/* Stacked Percentage Bar */}
        <div className="h-3 rounded-full overflow-hidden flex bg-slate-100 dark:bg-slate-800">
          {categoryBreakdown.map((cat) => (
            <div
              key={cat.name}
              className={`${cat.color} h-full transition-all`}
              style={{ width: `${cat.percentage}%` }}
              title={`${cat.name}: ${cat.percentage}%`}
            />
          ))}
        </div>

        {/* Legend */}
        <div className="grid grid-cols-2 gap-2 text-xs pt-1">
          {categoryBreakdown.map((cat) => (
            <div key={cat.name} className="flex items-center space-x-2">
              <span className={`w-2.5 h-2.5 rounded-full ${cat.color}`} />
              <span className="text-slate-600 dark:text-slate-300 font-medium">{cat.name}</span>
              <span className="font-bold text-slate-900 dark:text-white ml-auto">{cat.percentage}%</span>
            </div>
          ))}
        </div>
      </div>

      {/* 4. Monthly Expense Breakdown Graph (Matching Screen 14) */}
      <div className="rounded-3xl bg-white dark:bg-slate-850 p-5 border border-slate-200 dark:border-slate-800 shadow-xs space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
              Monthly Repair & Service Trend
            </span>
            <h4 className="text-sm font-black text-slate-900 dark:text-white">2026 Overview</h4>
          </div>
          <BarChart3 className="w-4 h-4 text-purple-500" />
        </div>

        {/* Bar chart representation */}
        <div className="h-36 flex items-end justify-between pt-4 pb-2 border-b border-slate-100 dark:border-slate-800">
          {[
            { month: 'Mar', val: 1200, height: '30%' },
            { month: 'Apr', val: 3750, height: '70%' },
            { month: 'May', val: 4200, height: '85%' },
            { month: 'Jun', val: 2400, height: '45%' },
            { month: 'Jul', val: 1800, height: '35%' },
            { month: 'Aug', val: 5100, height: '95%' },
          ].map((bar) => (
            <div key={bar.month} className="flex flex-col items-center flex-1 space-y-1">
              <span className="text-[9px] font-bold text-slate-400">₹{bar.val}</span>
              <div className="w-6 sm:w-8 bg-slate-100 dark:bg-slate-800 rounded-t-lg h-24 flex items-end overflow-hidden">
                <div
                  className="w-full bg-gradient-to-t from-indigo-600 to-purple-500 rounded-t-lg transition-all"
                  style={{ height: bar.height }}
                />
              </div>
              <span className="text-[10px] font-bold text-slate-600 dark:text-slate-300">{bar.month}</span>
            </div>
          ))}
        </div>
      </div>

      {/* 5. Report Export Options */}
      <div className="space-y-2 pt-1">
        <button
          onClick={() => handleDownloadReport('pdf')}
          className="w-full py-3 px-4 rounded-2xl bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-500 hover:to-purple-500 text-white font-bold text-xs shadow-md shadow-indigo-600/30 flex items-center justify-center space-x-2 cursor-pointer"
        >
          <FileText className="w-4 h-4" />
          <span>Download Official PDF Asset Ledger</span>
        </button>

        <button
          onClick={() => handleDownloadReport('csv')}
          className="w-full py-2.5 px-4 rounded-2xl bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-300 border border-slate-200 dark:border-slate-700 font-bold text-xs hover:bg-slate-50 flex items-center justify-center space-x-2 cursor-pointer"
        >
          <FileSpreadsheet className="w-4 h-4 text-emerald-600" />
          <span>Export Excel / CSV for Insurance & Tax</span>
        </button>
      </div>
    </div>
  );
};
