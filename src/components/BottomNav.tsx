import React from 'react';
import { Home, Package, Plus, Receipt, MoreHorizontal } from 'lucide-react';
import { NavTab, TabType } from '../types';
import { Language } from '../utils/translations';

export { type NavTab };

export interface BottomNavProps {
  activeTab?: TabType;
  currentTab?: TabType;
  onSelectTab?: (tab: TabType) => void;
  onTabChange?: (tab: TabType) => void;
  onOpenAddMenu?: () => void;
  notificationCount?: number;
  language?: Language;
  isDark?: boolean;
}

export const BottomNav: React.FC<BottomNavProps> = ({
  activeTab,
  currentTab,
  onSelectTab,
  onTabChange,
  onOpenAddMenu,
  notificationCount,
  isDark,
}) => {
  const current = currentTab || activeTab || 'home';
  const handleSelect = (tab: TabType) => {
    if (onTabChange) onTabChange(tab);
    if (onSelectTab) onSelectTab(tab);
  };

  const handleAdd = () => {
    if (onOpenAddMenu) onOpenAddMenu();
    else handleSelect('add');
  };

  return (
    <nav aria-label="Bottom Navigation" className={`sticky bottom-0 z-30 w-full px-3 py-2 border-t backdrop-blur-lg ${
      isDark ? 'bg-slate-900/95 border-slate-800 text-slate-400' : 'bg-white/95 border-slate-200 text-slate-500'
    } shadow-lg shrink-0`}>
      <div className="flex items-center justify-around max-w-md mx-auto relative">
        {/* 1. Home */}
        <button
          id="nav-tab-home"
          onClick={() => handleSelect('home')}
          className={`flex flex-col items-center justify-center w-14 py-1 rounded-xl transition-all cursor-pointer ${
            current === 'home'
              ? 'text-indigo-600 dark:text-indigo-400 font-bold scale-105'
              : 'hover:text-slate-800 dark:hover:text-slate-200'
          }`}
        >
          <Home className={`w-5 h-5 ${current === 'home' ? 'stroke-[2.5]' : 'stroke-[1.8]'}`} />
          <span className="text-[10px] mt-1 tracking-tight">Home</span>
        </button>

        {/* 2. Products */}
        <button
          id="nav-tab-products"
          onClick={() => handleSelect('products')}
          className={`flex flex-col items-center justify-center w-14 py-1 rounded-xl transition-all cursor-pointer ${
            current === 'products'
              ? 'text-indigo-600 dark:text-indigo-400 font-bold scale-105'
              : 'hover:text-slate-800 dark:hover:text-slate-200'
          }`}
        >
          <Package className={`w-5 h-5 ${current === 'products' ? 'stroke-[2.5]' : 'stroke-[1.8]'}`} />
          <span className="text-[10px] mt-1 tracking-tight">Products</span>
        </button>

        {/* 3. Center Prominent Add (+) Button */}
        <div className="relative -top-3 flex items-center justify-center">
          <button
            id="nav-tab-add-prominent"
            onClick={handleAdd}
            className="w-12 h-12 rounded-full bg-gradient-to-tr from-indigo-600 via-indigo-600 to-purple-600 text-white flex items-center justify-center shadow-lg shadow-indigo-600/40 hover:scale-105 active:scale-95 transition-all ring-4 ring-white dark:ring-slate-900 cursor-pointer"
            title="Add Product or Expense"
          >
            <Plus className="w-6 h-6 stroke-[2.8]" />
          </button>
        </div>

        {/* 4. Expenses */}
        <button
          id="nav-tab-expenses"
          onClick={() => handleSelect('expenses')}
          className={`flex flex-col items-center justify-center w-14 py-1 rounded-xl transition-all cursor-pointer ${
            current === 'expenses'
              ? 'text-indigo-600 dark:text-indigo-400 font-bold scale-105'
              : 'hover:text-slate-800 dark:hover:text-slate-200'
          }`}
        >
          <Receipt className={`w-5 h-5 ${current === 'expenses' ? 'stroke-[2.5]' : 'stroke-[1.8]'}`} />
          <span className="text-[10px] mt-1 tracking-tight">Expenses</span>
        </button>

        {/* 5. More */}
        <button
          id="nav-tab-more"
          onClick={() => handleSelect('more')}
          className={`flex flex-col items-center justify-center w-14 py-1 rounded-xl transition-all relative cursor-pointer ${
            current === 'more'
              ? 'text-indigo-600 dark:text-indigo-400 font-bold scale-105'
              : 'hover:text-slate-800 dark:hover:text-slate-200'
          }`}
        >
          {notificationCount && notificationCount > 0 ? (
            <span className="absolute top-0.5 right-3 w-2 h-2 rounded-full bg-rose-500 ring-2 ring-white dark:ring-slate-900" />
          ) : null}
          <MoreHorizontal className={`w-5 h-5 ${current === 'more' ? 'stroke-[2.5]' : 'stroke-[1.8]'}`} />
          <span className="text-[10px] mt-1 tracking-tight">More</span>
        </button>
      </div>
    </nav>
  );
};
