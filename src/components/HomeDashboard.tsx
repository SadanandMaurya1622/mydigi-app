import React from 'react';
import { 
  Bell, 
  Package, 
  ShieldCheck, 
  AlertTriangle, 
  ShieldAlert, 
  ArrowRight, 
  PlusCircle, 
  Receipt, 
  ScanLine, 
  BarChart3, 
  TrendingUp, 
  Wallet
} from 'lucide-react';
import { ProductItem, ExpenseRecord, AppNotification } from '../types';
import { Language, TRANSLATIONS } from '../utils/translations';

interface HomeDashboardProps {
  userName: string;
  products: ProductItem[];
  expenses: ExpenseRecord[];
  notifications: AppNotification[];
  onSelectProduct: (product: ProductItem) => void;
  onOpenAddProduct: () => void;
  onOpenAddExpense: () => void;
  onOpenScanner: () => void;
  onOpenReports: () => void;
  onOpenWarrantyList: () => void;
  onOpenExpensesList: () => void;
  onOpenNotifications: () => void;
  onOpenReminders: () => void;
  language: Language;
  isDark?: boolean;
}

export const HomeDashboard: React.FC<HomeDashboardProps> = ({
  userName,
  products,
  expenses,
  notifications,
  onSelectProduct,
  onOpenAddProduct,
  onOpenAddExpense,
  onOpenScanner,
  onOpenReports,
  onOpenWarrantyList,
  onOpenExpensesList,
  onOpenNotifications,
  onOpenReminders,
  language,
}) => {
  const t = TRANSLATIONS[language];

  // Calculated Metrics
  const totalProductsCount = products.length; // e.g. 24
  const activeWarrantiesCount = products.filter((p) => p.warrantyStatus === 'Active').length;
  const expiringSoonCount = products.filter((p) => p.warrantyStatus === 'Expiring Soon' || p.daysRemaining <= 30).length;
  const expiredCount = products.filter((p) => p.warrantyStatus === 'Expired').length;

  const totalPurchaseValue = products.reduce((acc, p) => acc + p.purchasePrice, 0);
  const thisMonthExpensesTotal = expenses
    .filter((e) => e.date.includes('Aug') || e.date.includes('Sep'))
    .reduce((acc, e) => acc + e.amount, 0) || 4250;

  const unreadNotifsCount = notifications.filter((n) => n.unread).length;

  // Upcoming Expiring Warranties (Sort by daysRemaining ascending)
  const upcomingWarranties = [...products]
    .filter((p) => p.warrantyStatus !== 'Expired')
    .sort((a, b) => a.daysRemaining - b.daysRemaining)
    .slice(0, 3);

  // Recent 3 expenses
  const recentExpenses = expenses.slice(0, 3);

  return (
    <div className="p-4 sm:p-6 space-y-5">
      {/* 1. Header Bar: Greeting & Notifications */}
      <div className="flex items-center justify-between">
        <div>
          <span className="text-xs font-semibold text-slate-500 dark:text-slate-400">
            {t.goodMorning}
          </span>
          <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white font-['Outfit',sans-serif] tracking-tight flex items-center space-x-1.5">
            <span>{userName}</span>
            <span className="text-lg">👋</span>
          </h1>
        </div>

        <button
          id="home-notifications-btn"
          onClick={onOpenNotifications}
          className="relative p-2.5 rounded-2xl bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200 border border-slate-200 dark:border-slate-700 shadow-sm hover:scale-105 active:scale-95 transition-all cursor-pointer"
          title="Notifications"
        >
          <Bell className="w-5 h-5 text-slate-700 dark:text-slate-200" />
          {unreadNotifsCount > 0 && (
            <span className="absolute -top-1 -right-1 w-5 h-5 rounded-full bg-rose-500 text-white text-[10px] font-bold flex items-center justify-center ring-2 ring-white dark:ring-slate-900 animate-pulse">
              {unreadNotifsCount}
            </span>
          )}
        </button>
      </div>

      {/* 2. Overview Section Header & 4 Stats Cards */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
            {t.overview}
          </span>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5 sm:gap-3">
          {/* Total Products */}
          <div 
            onClick={onOpenWarrantyList}
            className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex flex-col justify-between cursor-pointer hover:border-indigo-300 dark:hover:border-indigo-600 transition-colors"
          >
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold text-slate-500 dark:text-slate-400">Total Products</span>
              <div className="w-6 h-6 rounded-lg bg-indigo-50 dark:bg-indigo-950/80 text-indigo-600 dark:text-indigo-400 flex items-center justify-center">
                <Package className="w-3.5 h-3.5" />
              </div>
            </div>
            <div className="text-2xl font-black text-slate-900 dark:text-white font-['Outfit',sans-serif] mt-2">
              {totalProductsCount > 0 ? totalProductsCount : 24}
            </div>
          </div>

          {/* Active Warranties */}
          <div 
            onClick={onOpenWarrantyList}
            className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex flex-col justify-between cursor-pointer hover:border-emerald-300 dark:hover:border-emerald-600 transition-colors"
          >
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold text-slate-500 dark:text-slate-400">Active Warranties</span>
              <div className="w-6 h-6 rounded-lg bg-emerald-50 dark:bg-emerald-950/80 text-emerald-600 dark:text-emerald-400 flex items-center justify-center">
                <ShieldCheck className="w-3.5 h-3.5" />
              </div>
            </div>
            <div className="text-2xl font-black text-slate-900 dark:text-white font-['Outfit',sans-serif] mt-2">
              {activeWarrantiesCount > 0 ? activeWarrantiesCount : 17}
            </div>
          </div>

          {/* Expiring Soon */}
          <div 
            onClick={onOpenReminders}
            className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex flex-col justify-between cursor-pointer hover:border-amber-300 dark:hover:border-amber-600 transition-colors"
          >
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold text-slate-500 dark:text-slate-400">Expiring Soon</span>
              <div className="w-6 h-6 rounded-lg bg-amber-50 dark:bg-amber-950/80 text-amber-600 dark:text-amber-400 flex items-center justify-center">
                <AlertTriangle className="w-3.5 h-3.5" />
              </div>
            </div>
            <div className="text-2xl font-black text-amber-600 dark:text-amber-400 font-['Outfit',sans-serif] mt-2">
              {expiringSoonCount > 0 ? expiringSoonCount : 3}
            </div>
          </div>

          {/* Expired */}
          <div 
            onClick={onOpenWarrantyList}
            className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex flex-col justify-between cursor-pointer hover:border-rose-300 dark:hover:border-rose-600 transition-colors"
          >
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold text-slate-500 dark:text-slate-400">Expired</span>
              <div className="w-6 h-6 rounded-lg bg-rose-50 dark:bg-rose-950/80 text-rose-600 dark:text-rose-400 flex items-center justify-center">
                <ShieldAlert className="w-3.5 h-3.5" />
              </div>
            </div>
            <div className="text-2xl font-black text-rose-600 dark:text-rose-400 font-['Outfit',sans-serif] mt-2">
              {expiredCount > 0 ? expiredCount : 2}
            </div>
          </div>
        </div>
      </div>

      {/* 3. Hero Highlight Card: Total Purchase Value (Matching Screen 2) */}
      <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-indigo-700 via-indigo-600 to-purple-800 text-white p-5 sm:p-6 shadow-xl shadow-indigo-600/25">
        {/* Glow ambient background shape */}
        <div className="absolute top-0 right-0 -mr-10 -mt-10 w-44 h-44 rounded-full bg-white/10 blur-2xl pointer-events-none" />
        
        <div className="relative z-10 flex items-center justify-between">
          <div className="space-y-1">
            <span className="text-xs font-semibold uppercase tracking-wider text-indigo-200/90">
              {t.totalPurchaseValue}
            </span>
            <div className="text-3xl sm:text-4xl font-black font-['Outfit',sans-serif] tracking-tight text-white">
              ₹{(totalPurchaseValue || 245000).toLocaleString('en-IN')}
            </div>

            <button
              id="view-purchase-details-btn"
              onClick={onOpenReports}
              className="inline-flex items-center space-x-1.5 text-xs font-bold text-indigo-100 hover:text-white pt-2 group cursor-pointer"
            >
              <span>{t.viewDetails}</span>
              <ArrowRight className="w-3.5 h-3.5 group-hover:translate-x-1 transition-transform" />
            </button>
          </div>

          {/* 3D Wallet / Asset Badge */}
          <div className="w-16 h-16 sm:w-20 sm:h-20 rounded-2xl bg-white/10 backdrop-blur-md border border-white/20 flex items-center justify-center text-indigo-100 shadow-inner">
            <Wallet className="w-9 h-9 text-indigo-200" />
          </div>
        </div>
      </div>

      {/* 4. This Month Expense Card with Sparkline (Matching Screen 2) */}
      <div className="rounded-3xl bg-white dark:bg-slate-850 p-4 sm:p-5 border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between">
        <div className="space-y-1">
          <span className="text-xs font-bold text-slate-500 dark:text-slate-400">
            {t.thisMonthExpense}
          </span>
          <div className="text-2xl font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
            ₹{thisMonthExpensesTotal.toLocaleString('en-IN')}
          </div>
          <div className="flex items-center space-x-1 text-xs font-bold text-emerald-600 dark:text-emerald-400">
            <TrendingUp className="w-3.5 h-3.5" />
            <span>+12.5% {t.fromLastMonth}</span>
          </div>
        </div>

        {/* Mini SVG Sparkline */}
        <div className="w-28 h-12 flex items-center">
          <svg className="w-full h-full" viewBox="0 0 100 40">
            <path
              d="M 5,30 Q 25,35 40,18 T 75,22 T 95,8"
              fill="none"
              stroke="#6366f1"
              strokeWidth="3.5"
              strokeLinecap="round"
            />
            <circle cx="95" cy="8" r="3.5" fill="#6366f1" />
          </svg>
        </div>
      </div>

      {/* 5. Quick Actions Row (4 Action Buttons from image.png) */}
      <div className="space-y-2.5">
        <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
          {t.quickActions}
        </span>

        <div className="grid grid-cols-4 gap-2.5">
          {/* Add Product */}
          <button
            id="quick-add-product-btn"
            onClick={onOpenAddProduct}
            className="flex flex-col items-center justify-center p-3 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 hover:border-indigo-400 dark:hover:border-indigo-500 shadow-xs transition-all active:scale-95 cursor-pointer group"
          >
            <div className="w-10 h-10 rounded-xl bg-indigo-50 dark:bg-indigo-950/80 text-indigo-600 dark:text-indigo-400 flex items-center justify-center group-hover:scale-110 transition-transform">
              <PlusCircle className="w-5 h-5" />
            </div>
            <span className="text-[11px] font-bold text-slate-800 dark:text-slate-200 mt-2 text-center leading-tight">
              {t.addProduct}
            </span>
          </button>

          {/* Add Expense */}
          <button
            id="quick-add-expense-btn"
            onClick={onOpenAddExpense}
            className="flex flex-col items-center justify-center p-3 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 hover:border-purple-400 dark:hover:border-purple-500 shadow-xs transition-all active:scale-95 cursor-pointer group"
          >
            <div className="w-10 h-10 rounded-xl bg-purple-50 dark:bg-purple-950/80 text-purple-600 dark:text-purple-400 flex items-center justify-center group-hover:scale-110 transition-transform">
              <Receipt className="w-5 h-5" />
            </div>
            <span className="text-[11px] font-bold text-slate-800 dark:text-slate-200 mt-2 text-center leading-tight">
              {t.addExpense}
            </span>
          </button>

          {/* Scan Bill */}
          <button
            id="quick-scan-bill-btn"
            onClick={onOpenScanner}
            className="flex flex-col items-center justify-center p-3 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 hover:border-blue-400 dark:hover:border-blue-500 shadow-xs transition-all active:scale-95 cursor-pointer group"
          >
            <div className="w-10 h-10 rounded-xl bg-blue-50 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center group-hover:scale-110 transition-transform">
              <ScanLine className="w-5 h-5" />
            </div>
            <span className="text-[11px] font-bold text-slate-800 dark:text-slate-200 mt-2 text-center leading-tight">
              {t.scanBill}
            </span>
          </button>

          {/* Reports */}
          <button
            id="quick-reports-btn"
            onClick={onOpenReports}
            className="flex flex-col items-center justify-center p-3 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 hover:border-violet-400 dark:hover:border-violet-500 shadow-xs transition-all active:scale-95 cursor-pointer group"
          >
            <div className="w-10 h-10 rounded-xl bg-violet-50 dark:bg-violet-950/80 text-violet-600 dark:text-violet-400 flex items-center justify-center group-hover:scale-110 transition-transform">
              <BarChart3 className="w-5 h-5" />
            </div>
            <span className="text-[11px] font-bold text-slate-800 dark:text-slate-200 mt-2 text-center leading-tight">
              {t.reports}
            </span>
          </button>
        </div>
      </div>

      {/* 6. Upcoming Warranty Expiring Section (Matching Screen 2) */}
      <div className="space-y-2.5">
        <div className="flex items-center justify-between">
          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
            {t.warrantyExpiringSoon}
          </span>
          <button
            id="view-all-warranties-btn"
            onClick={onOpenWarrantyList}
            className="text-xs font-bold text-indigo-600 dark:text-indigo-400 hover:underline cursor-pointer"
          >
            {t.viewAll}
          </button>
        </div>

        <div className="space-y-2">
          {upcomingWarranties.map((item) => (
            <div
              key={item.id}
              onClick={() => onSelectProduct(item)}
              className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between hover:border-indigo-300 dark:hover:border-indigo-600 transition-colors cursor-pointer"
            >
              <div className="flex items-center space-x-3">
                <div className="w-11 h-11 rounded-xl bg-slate-100 dark:bg-slate-800 overflow-hidden shrink-0 border border-slate-200 dark:border-slate-700">
                  <img
                    src={item.imageUrl}
                    alt={item.name}
                    className="w-full h-full object-cover"
                    referrerPolicy="no-referrer"
                  />
                </div>
                <div>
                  <h4 className="text-xs sm:text-sm font-bold text-slate-900 dark:text-white">
                    {item.name}
                  </h4>
                  <p className="text-[11px] text-slate-500 dark:text-slate-400">
                    Serial: {item.serialNumber}
                  </p>
                </div>
              </div>

              {/* Status & Days Left Badge */}
              <div className="text-right">
                <span className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-extrabold ${
                  item.daysRemaining <= 7
                    ? 'bg-rose-50 dark:bg-rose-950/60 text-rose-600 dark:text-rose-400 border border-rose-200 dark:border-rose-800'
                    : item.daysRemaining <= 30
                    ? 'bg-amber-50 dark:bg-amber-950/60 text-amber-600 dark:text-amber-400 border border-amber-200 dark:border-amber-800'
                    : 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800'
                }`}>
                  {item.daysRemaining <= 30 
                    ? `${item.daysRemaining} ${t.daysLeft}` 
                    : `${Math.round(item.daysRemaining / 30)} ${t.monthsLeft}`}
                </span>
                <span className="block text-[10px] text-slate-400 mt-0.5 font-medium">
                  {item.warrantyEndDate}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* 7. Recent Expenses Section (Matching Screen 2) */}
      <div className="space-y-2.5">
        <div className="flex items-center justify-between">
          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
            {t.recentExpenses}
          </span>
          <button
            id="view-all-expenses-btn"
            onClick={onOpenExpensesList}
            className="text-xs font-bold text-indigo-600 dark:text-indigo-400 hover:underline cursor-pointer"
          >
            {t.viewAllExpenses}
          </button>
        </div>

        <div className="space-y-2">
          {recentExpenses.map((exp) => (
            <div
              key={exp.id}
              className="p-3.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between"
            >
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 rounded-xl bg-indigo-50 dark:bg-indigo-950/80 text-indigo-600 dark:text-indigo-400 flex items-center justify-center shrink-0">
                  <Receipt className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="text-xs sm:text-sm font-bold text-slate-900 dark:text-white">
                    {exp.productName}
                  </h4>
                  <p className="text-[11px] text-slate-500 dark:text-slate-400">
                    {exp.category} • {exp.date}
                  </p>
                </div>
              </div>

              <div className="text-right">
                <span className="text-sm font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                  ₹{exp.amount.toLocaleString('en-IN')}
                </span>
                <span className="block text-[10px] text-slate-400">
                  {exp.technicianOrVendor || 'Paid'}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
