import React, { useState } from 'react';
import { 
  Receipt, 
  Search, 
  Plus
} from 'lucide-react';
import { ExpenseRecord } from '../types';
import { Language } from '../utils/translations';

interface ExpensesScreenProps {
  expenses: ExpenseRecord[];
  onOpenAddExpense: () => void;
  language: Language;
}

export const ExpensesScreen: React.FC<ExpensesScreenProps> = ({
  expenses,
  onOpenAddExpense,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('All');

  const totalExpenseAmount = expenses.reduce((acc, curr) => acc + curr.amount, 0);

  const categories = [
    { label: 'All', value: 'All' },
    { label: 'Repair', value: 'Repair' },
    { label: 'Maintenance', value: 'Maintenance' },
    { label: 'Service', value: 'Service' },
    { label: 'Accessories', value: 'Accessories' },
    { label: 'Installation', value: 'Installation' },
    { label: 'AMC', value: 'AMC' },
  ];

  const filteredExpenses = expenses.filter((e) => {
    const textDesc = e.description || e.title || '';
    const matchesSearch = 
      e.productName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      textDesc.toLowerCase().includes(searchQuery.toLowerCase()) ||
      e.category.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesCat = selectedCategory === 'All' || e.category === selectedCategory;

    return matchesSearch && matchesCat;
  });

  return (
    <div className="p-4 sm:p-6 space-y-4 pb-24 relative min-h-full">
      {/* 1. Header with Total (Matching Screen 9) */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white font-['Outfit',sans-serif] tracking-tight">
            Expenses
          </h1>
          <p className="text-xs text-slate-500 dark:text-slate-400">
            Total Tracked: <span className="font-black text-indigo-600 dark:text-indigo-400">₹{totalExpenseAmount.toLocaleString('en-IN')}</span>
          </p>
        </div>

        <button
          onClick={onOpenAddExpense}
          className="p-2.5 rounded-2xl bg-indigo-600 text-white font-bold text-xs shadow-md shadow-indigo-600/30 flex items-center space-x-1 hover:bg-indigo-700 cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Add Expense</span>
        </button>
      </div>

      {/* 2. Expense Summary Metric Banner */}
      <div className="rounded-3xl bg-gradient-to-r from-purple-700 to-indigo-800 text-white p-5 shadow-xl shadow-purple-700/20 flex items-center justify-between">
        <div className="space-y-1">
          <span className="text-xs uppercase tracking-wider text-purple-200">
            All-Time Maintenance & Repair
          </span>
          <div className="text-3xl font-black font-['Outfit',sans-serif]">
            ₹{totalExpenseAmount.toLocaleString('en-IN')}
          </div>
          <p className="text-[11px] text-purple-200/80">
            Across {expenses.length} recorded service events
          </p>
        </div>

        <div className="w-14 h-14 rounded-2xl bg-white/10 backdrop-blur-md flex items-center justify-center">
          <Receipt className="w-7 h-7 text-purple-200" />
        </div>
      </div>

      {/* 3. Search & Filter Bar */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search by product, repair, or vendor..."
          className="w-full pl-10 pr-4 py-2.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 text-xs font-medium text-slate-900 dark:text-white shadow-xs focus:outline-none focus:ring-2 focus:ring-indigo-500 placeholder:text-slate-400"
        />
      </div>

      {/* 4. Category Filter Chips */}
      <div className="flex items-center space-x-2 overflow-x-auto pb-1 scrollbar-none -mx-4 px-4 sm:mx-0 sm:px-0">
        {categories.map((cat) => (
          <button
            key={cat.value}
            onClick={() => setSelectedCategory(cat.value)}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold whitespace-nowrap transition-all cursor-pointer ${
              selectedCategory === cat.value
                ? 'bg-purple-600 text-white shadow-xs'
                : 'bg-white dark:bg-slate-850 text-slate-600 dark:text-slate-300 border border-slate-200 dark:border-slate-800'
            }`}
          >
            {cat.label}
          </button>
        ))}
      </div>

      {/* 5. Expense Items List (Matching Screen 9) */}
      <div className="space-y-2.5 pt-1">
        {filteredExpenses.length === 0 ? (
          <div className="p-8 text-center bg-white dark:bg-slate-850 rounded-3xl border border-slate-200 dark:border-slate-800 space-y-2">
            <Receipt className="w-10 h-10 text-slate-300 mx-auto" />
            <h4 className="text-xs font-bold text-slate-700 dark:text-slate-300">No expenses found</h4>
            <p className="text-[11px] text-slate-400">Click Add Expense to record maintenance costs.</p>
          </div>
        ) : (
          filteredExpenses.map((item) => (
            <div
              key={item.id}
              className="p-3.5 sm:p-4 rounded-3xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between hover:border-purple-300 dark:hover:border-purple-600 transition-colors"
            >
              <div className="flex items-center space-x-3">
                <div className="w-11 h-11 rounded-2xl bg-purple-50 dark:bg-purple-950/80 text-purple-600 dark:text-purple-400 flex items-center justify-center shrink-0">
                  <Receipt className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="text-xs sm:text-sm font-bold text-slate-900 dark:text-white">
                    {item.productName}
                  </h4>
                  <p className="text-[11px] text-slate-500 dark:text-slate-400">
                    <span className="font-semibold text-purple-600 dark:text-purple-400">{item.category}</span> • {item.description || item.title || 'Service charge'}
                  </p>
                  <div className="flex items-center space-x-2 text-[10px] text-slate-400 mt-0.5">
                    <span>{item.date}</span>
                    {(item.technicianOrVendor || item.technicianName) && (
                      <span>• Tech: {item.technicianOrVendor || item.technicianName}</span>
                    )}
                  </div>
                </div>
              </div>

              <div className="text-right">
                <span className="text-sm sm:text-base font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                  ₹{item.amount.toLocaleString('en-IN')}
                </span>
                <span className="block text-[10px] text-emerald-600 dark:text-emerald-400 font-bold">
                  Paid
                </span>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Floating Action Button (+) */}
      <div className="fixed bottom-20 right-6 z-20 sm:absolute sm:bottom-6 sm:right-6">
        <button
          onClick={onOpenAddExpense}
          className="w-13 h-13 rounded-full bg-gradient-to-tr from-purple-600 to-indigo-600 text-white flex items-center justify-center shadow-xl shadow-purple-600/40 hover:scale-105 active:scale-95 transition-all ring-4 ring-white dark:ring-slate-900 cursor-pointer"
          title="Add New Expense"
        >
          <Plus className="w-6 h-6 stroke-[2.5]" />
        </button>
      </div>
    </div>
  );
};
