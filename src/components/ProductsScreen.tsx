import React, { useState } from 'react';
import { 
  Search, 
  SlidersHorizontal, 
  Plus, 
  ShieldCheck, 
  ChevronRight
} from 'lucide-react';
import { ProductItem } from '../types';
import { Language, TRANSLATIONS } from '../utils/translations';

interface ProductsScreenProps {
  products: ProductItem[];
  onSelectProduct: (product: ProductItem) => void;
  onOpenAddProduct: () => void;
  language: Language;
  isDark?: boolean;
}

export const ProductsScreen: React.FC<ProductsScreenProps> = ({
  products,
  onSelectProduct,
  onOpenAddProduct,
  language,
}) => {
  const t = TRANSLATIONS[language];

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('All');
  const [selectedStatusFilter, setSelectedStatusFilter] = useState<string>('All');
  const [showFilterModal, setShowFilterModal] = useState(false);

  const categories: { label: string; value: string }[] = [
    { label: t.categories.all, value: 'All' },
    { label: t.categories.electronics, value: 'Electronics' },
    { label: t.categories.appliances, value: 'Appliances' },
    { label: t.categories.vehicle, value: 'Vehicle' },
    { label: t.categories.furniture, value: 'Furniture' },
    { label: t.categories.other, value: 'Other' },
  ];

  // Filter products by search, category, and status
  const filteredProducts = products.filter((p) => {
    const matchesSearch = 
      p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.serialNumber.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.brand.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.category.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesCategory = selectedCategory === 'All' || p.category === selectedCategory;
    const matchesStatus = selectedStatusFilter === 'All' || p.warrantyStatus === selectedStatusFilter;

    return matchesSearch && matchesCategory && matchesStatus;
  });

  return (
    <div className="p-4 sm:p-6 space-y-4 pb-20 relative min-h-full">
      {/* 1. Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white font-['Outfit',sans-serif] tracking-tight">
            {t.myProducts}
          </h1>
          <p className="text-xs text-slate-500 dark:text-slate-400">
            {filteredProducts.length} of {products.length} products tracked
          </p>
        </div>

        <button
          id="products-filter-btn"
          onClick={() => setShowFilterModal(true)}
          className={`p-2.5 rounded-2xl border transition-all cursor-pointer ${
            selectedStatusFilter !== 'All' 
              ? 'bg-indigo-600 text-white border-indigo-600' 
              : 'bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200 border-slate-200 dark:border-slate-700'
          }`}
          title="Filter Products"
        >
          <SlidersHorizontal className="w-4 h-4" />
        </button>
      </div>

      {/* 2. Search Bar */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder={t.searchProducts}
          className="w-full pl-10 pr-4 py-2.5 rounded-2xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 text-xs font-medium text-slate-900 dark:text-white shadow-xs focus:outline-none focus:ring-2 focus:ring-indigo-500 transition-all placeholder:text-slate-400"
        />
        {searchQuery && (
          <button
            onClick={() => setSearchQuery('')}
            className="absolute right-3.5 top-1/2 -translate-y-1/2 text-xs font-bold text-slate-400 hover:text-slate-600"
          >
            ✕
          </button>
        )}
      </div>

      {/* 3. Category Filter Chips (Horizontal scrollable) */}
      <div className="flex items-center space-x-2 overflow-x-auto pb-1 scrollbar-none -mx-4 px-4 sm:mx-0 sm:px-0">
        {categories.map((cat) => (
          <button
            key={cat.value}
            id={`filter-cat-${cat.value.toLowerCase()}`}
            onClick={() => setSelectedCategory(cat.value)}
            className={`px-4 py-1.5 rounded-xl text-xs font-bold whitespace-nowrap transition-all cursor-pointer ${
              selectedCategory === cat.value
                ? 'bg-indigo-600 text-white shadow-sm shadow-indigo-600/30'
                : 'bg-white dark:bg-slate-850 text-slate-600 dark:text-slate-300 border border-slate-200 dark:border-slate-800 hover:bg-slate-100 dark:hover:bg-slate-800'
            }`}
          >
            {cat.label}
          </button>
        ))}
      </div>

      {/* 4. Products List */}
      <div className="space-y-3 pt-1">
        {filteredProducts.length === 0 ? (
          <div className="p-8 text-center bg-white dark:bg-slate-850 rounded-3xl border border-slate-200 dark:border-slate-800 space-y-3">
            <div className="w-12 h-12 rounded-2xl bg-indigo-50 dark:bg-indigo-950/80 text-indigo-500 mx-auto flex items-center justify-center">
              <ShieldCheck className="w-6 h-6" />
            </div>
            <h4 className="text-sm font-bold text-slate-800 dark:text-slate-200">No products found</h4>
            <p className="text-xs text-slate-500 dark:text-slate-400 max-w-xs mx-auto">
              Try adjusting your search filter or add a new product.
            </p>
            <button
              onClick={onOpenAddProduct}
              className="px-4 py-2 rounded-xl bg-indigo-600 text-white text-xs font-bold shadow-md shadow-indigo-600/30 cursor-pointer"
            >
              + Add Product
            </button>
          </div>
        ) : (
          filteredProducts.map((p) => {
            const isExpiring = p.warrantyStatus === 'Expiring Soon' || p.daysRemaining <= 30;
            const isExpired = p.warrantyStatus === 'Expired';

            return (
              <div
                key={p.id}
                id={`product-card-${p.id}`}
                onClick={() => onSelectProduct(p)}
                className="p-3.5 sm:p-4 rounded-3xl bg-white dark:bg-slate-850 border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between hover:border-indigo-400 dark:hover:border-indigo-600 transition-all cursor-pointer group"
              >
                <div className="flex items-center space-x-3 sm:space-x-4">
                  {/* Product Image Thumbnail */}
                  <div className="w-14 h-14 sm:w-16 sm:h-16 rounded-2xl bg-slate-100 dark:bg-slate-800 overflow-hidden shrink-0 border border-slate-200 dark:border-slate-700">
                    <img
                      src={p.imageUrl}
                      alt={p.name}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      referrerPolicy="no-referrer"
                    />
                  </div>

                  {/* Info */}
                  <div className="space-y-0.5">
                    <h3 className="text-xs sm:text-sm font-black text-slate-900 dark:text-white group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">
                      {p.name}
                    </h3>
                    <p className="text-[11px] text-slate-500 dark:text-slate-400">
                      {p.imeiNumber ? `IMEI: ${p.imeiNumber}` : `Serial: ${p.serialNumber}`}
                    </p>
                    <div className="text-[11px] font-medium text-slate-600 dark:text-slate-300 flex items-center space-x-1.5 pt-0.5">
                      <span className="text-slate-400">Warranty:</span>
                      <span className="font-semibold">{p.warrantyEndDate}</span>
                    </div>
                  </div>
                </div>

                {/* Right Status Badge & Arrow */}
                <div className="flex flex-col items-end space-y-2">
                  <span
                    className={`px-2.5 py-0.5 rounded-full text-[10px] font-extrabold capitalize ${
                      isExpired
                        ? 'bg-rose-50 dark:bg-rose-950/60 text-rose-600 dark:text-rose-400 border border-rose-200 dark:border-rose-800'
                        : isExpiring
                        ? 'bg-amber-50 dark:bg-amber-950/60 text-amber-600 dark:text-amber-400 border border-amber-200 dark:border-amber-800'
                        : 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800'
                    }`}
                  >
                    {isExpired ? 'Expired' : isExpiring ? 'Expiring' : 'Active'}
                  </span>
                  <ChevronRight className="w-4 h-4 text-slate-300 group-hover:text-indigo-500 group-hover:translate-x-0.5 transition-all" />
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* 5. Floating Action Button (+) */}
      <div className="fixed bottom-20 right-6 z-20 sm:absolute sm:bottom-6 sm:right-6">
        <button
          id="fab-add-product"
          onClick={onOpenAddProduct}
          className="w-13 h-13 rounded-full bg-gradient-to-tr from-indigo-600 via-indigo-600 to-purple-600 text-white flex items-center justify-center shadow-xl shadow-indigo-600/40 hover:scale-105 active:scale-95 transition-all ring-4 ring-white dark:ring-slate-900 cursor-pointer"
          title="Add New Product"
        >
          <Plus className="w-6 h-6 stroke-[2.5]" />
        </button>
      </div>

      {/* Filter Modal Drawer */}
      {showFilterModal && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-slate-950/60 backdrop-blur-xs p-0 sm:p-4 animate-in fade-in">
          <div className="w-full max-w-sm bg-white dark:bg-slate-900 rounded-t-3xl sm:rounded-3xl p-5 border border-slate-200 dark:border-slate-800 shadow-2xl">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 dark:border-slate-800">
              <h4 className="text-sm font-bold text-slate-900 dark:text-white">Filter Products</h4>
              <button
                onClick={() => setShowFilterModal(false)}
                className="text-xs font-bold text-slate-400 hover:text-slate-600"
              >
                Close
              </button>
            </div>

            <div className="space-y-4 py-4">
              <div>
                <label className="text-xs font-bold text-slate-700 dark:text-slate-300 block mb-2">Warranty Status</label>
                <div className="grid grid-cols-3 gap-2">
                  {['All', 'Active', 'Expiring Soon', 'Expired'].map((status) => (
                    <button
                      key={status}
                      onClick={() => setSelectedStatusFilter(status)}
                      className={`py-2 px-2.5 rounded-xl text-xs font-bold text-center border transition-all cursor-pointer ${
                        selectedStatusFilter === status
                          ? 'bg-indigo-600 text-white border-indigo-600'
                          : 'bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300 border-slate-200 dark:border-slate-700'
                      }`}
                    >
                      {status}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            <div className="pt-2">
              <button
                onClick={() => setShowFilterModal(false)}
                className="w-full py-2.5 rounded-xl bg-indigo-600 text-white font-bold text-xs shadow-md shadow-indigo-600/30 cursor-pointer"
              >
                Apply Filters
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
