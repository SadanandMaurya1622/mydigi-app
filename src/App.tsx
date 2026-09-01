import React, { useState } from 'react';
import { 
  MOCK_PRODUCTS, 
  MOCK_EXPENSES, 
  MOCK_SERVICES, 
  MOCK_DOCUMENTS, 
  MOCK_AMC_RECORDS, 
  MOCK_INSURANCE_RECORDS, 
  MOCK_CLAIMS, 
  MOCK_FAMILY, 
  MOCK_NOTIFICATIONS 
} from './data/warrantyData';
import { 
  ProductItem, 
  ExpenseRecord, 
  ServiceRecord, 
  DocumentRecord, 
  AMCRecord, 
  InsuranceRecord, 
  WarrantyClaim, 
  FamilyMember, 
  AppNotification, 
  UserProfile 
} from './types';
import { Language } from './utils/translations';
import { MobileFrame } from './components/MobileFrame';
import { BottomNav, NavTab } from './components/BottomNav';
import { OnboardingFlow } from './components/OnboardingFlow';
import { AuthModal } from './components/AuthModal';
import { HomeDashboard } from './components/HomeDashboard';
import { ProductsScreen } from './components/ProductsScreen';
import { ProductDetailsScreen } from './components/ProductDetailsScreen';
import { AddProductModal } from './components/AddProductModal';
import { AddExpenseModal } from './components/AddExpenseModal';
import { AIScannerModal } from './components/AIScannerModal';
import { WarrantyReminderScreen } from './components/WarrantyReminderScreen';
import { ExpensesScreen } from './components/ExpensesScreen';
import { InvoiceVaultScreen } from './components/InvoiceVaultScreen';
import { ClaimsScreen } from './components/ClaimsScreen';
import { AMCScreen } from './components/AMCScreen';
import { QRCodeModal } from './components/QRCodeModal';
import { AnalyticsReportsScreen } from './components/AnalyticsReportsScreen';
import { MoreSettingsScreen } from './components/MoreSettingsScreen';
import { NotificationsModal } from './components/NotificationsModal';
import confetti from 'canvas-confetti';

export const App: React.FC = () => {
  // App Core State
  const [language, setLanguage] = useState<Language>('en');
  const [isDark, setIsDark] = useState<boolean>(false);

  // User & Auth State
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState<boolean>(true);
  const [showAuthModal, setShowAuthModal] = useState<boolean>(false);
  const [userProfile, setUserProfile] = useState<UserProfile>({
    name: 'Sadanand Gupta',
    email: 'sadanand@example.com',
    phone: '+91 98200 12345',
    isPro: true,
  });

  // Data Collections State
  const [products, setProducts] = useState<ProductItem[]>(MOCK_PRODUCTS);
  const [expenses, setExpenses] = useState<ExpenseRecord[]>(MOCK_EXPENSES);
  const [services] = useState<ServiceRecord[]>(MOCK_SERVICES);
  const [documents, setDocuments] = useState<DocumentRecord[]>(MOCK_DOCUMENTS);
  const [amcRecords] = useState<AMCRecord[]>(MOCK_AMC_RECORDS);
  const [insuranceRecords] = useState<InsuranceRecord[]>(MOCK_INSURANCE_RECORDS);
  const [claims, setClaims] = useState<WarrantyClaim[]>(MOCK_CLAIMS);
  const [familyMembers] = useState<FamilyMember[]>(MOCK_FAMILY);
  const [notifications, setNotifications] = useState<AppNotification[]>(MOCK_NOTIFICATIONS);

  // Navigation State
  const [currentTab, setCurrentTab] = useState<NavTab>('home');
  const [activeSubView, setActiveSubView] = useState<
    'none' | 'product-details' | 'reminders' | 'vault' | 'claims' | 'amc' | 'reports'
  >('none');
  const [selectedProduct, setSelectedProduct] = useState<ProductItem | null>(null);

  // Modals State
  const [isAddProductOpen, setIsAddProductOpen] = useState(false);
  const [isAddExpenseOpen, setIsAddExpenseOpen] = useState(false);
  const [isAIScannerOpen, setIsAIScannerOpen] = useState(false);
  const [isQRCodeOpen, setIsQRCodeOpen] = useState(false);
  const [isNotificationsOpen, setIsNotificationsOpen] = useState(false);
  const [qrProduct, setQrProduct] = useState<ProductItem | null>(null);
  const [defaultExpenseProductId, setDefaultExpenseProductId] = useState<string | undefined>();
  const [editingProduct, setEditingProduct] = useState<ProductItem | null>(null);

  // Notification badge calculation
  const unreadCount = notifications.filter((n) => n.unread).length;

  // Handlers for Navigation
  const handleTabChange = (tab: NavTab) => {
    if (tab === 'add') {
      setIsAddProductOpen(true);
      return;
    }
    setActiveSubView('none');
    setCurrentTab(tab);
  };

  const handleSelectProduct = (product: ProductItem) => {
    setSelectedProduct(product);
    setActiveSubView('product-details');
  };

  const handleSaveProduct = (newProd: ProductItem) => {
    if (editingProduct) {
      setProducts(products.map((p) => (p.id === newProd.id ? newProd : p)));
      setSelectedProduct(newProd);
      setEditingProduct(null);
    } else {
      setProducts([newProd, ...products]);
      const newDoc: DocumentRecord = {
        id: `doc-${Date.now()}`,
        productId: newProd.id,
        productName: newProd.name,
        name: `${newProd.brand}_Invoice.pdf`,
        type: 'Invoice',
        uploadDate: 'Just now',
        size: '1.4 MB',
      };
      setDocuments([newDoc, ...documents]);
    }
  };

  const handleSaveExpense = (newExp: ExpenseRecord) => {
    setExpenses([newExp, ...expenses]);
    setProducts((prev) =>
      prev.map((p) => {
        if (p.id === newExp.productId) {
          const breakdown = { ...p.costBreakdown };
          if (newExp.category === 'Service') breakdown.maintenance += newExp.amount;
          else if (newExp.category === 'Repair') breakdown.repair += newExp.amount;
          else if (newExp.category === 'Accessories') breakdown.accessories += newExp.amount;
          else if (newExp.category === 'AMC') breakdown.amc += newExp.amount;
          else breakdown.other += newExp.amount;
          return { ...p, costBreakdown: breakdown };
        }
        return p;
      })
    );
  };

  const handleAddClaim = (newClaim: WarrantyClaim) => {
    setClaims([newClaim, ...claims]);
  };

  const handleConfirmScan = (extracted: Partial<ProductItem>) => {
    const newProd: ProductItem = {
      id: `prod-${Date.now()}`,
      name: extracted.name || 'LG Refrigerator 360L',
      category: extracted.category || 'Appliances',
      brand: extracted.brand || 'LG',
      modelNumber: 'GL-T402JDS',
      serialNumber: extracted.serialNumber || `LGRF${Math.floor(1000 + Math.random() * 9000)}`,
      purchaseDate: extracted.purchaseDate || '20 Aug 2026',
      purchasePrice: extracted.purchasePrice || 38500,
      sellerName: extracted.sellerName || 'XYZ Electronics',
      sellerContact: '+91 98100 22334',
      invoiceNumber: extracted.invoiceNumber || 'INV-2026-0897',
      warrantyPeriod: extracted.warrantyPeriod || '2 Years Comprehensive',
      warrantyStartDate: extracted.warrantyStartDate || '20 Aug 2026',
      warrantyEndDate: extracted.warrantyEndDate || '20 Aug 2028',
      warrantyStatus: 'Active',
      daysRemaining: 720,
      extendedWarranty: false,
      hasAMC: false,
      imageUrl: extracted.imageUrl || 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80',
      costBreakdown: {
        purchase: extracted.purchasePrice || 38500,
        installation: 0,
        maintenance: 0,
        repair: 0,
        accessories: 0,
        amc: 0,
        other: 0,
      },
    };

    setProducts([newProd, ...products]);
    setSelectedProduct(newProd);
    setActiveSubView('product-details');
    confetti({ particleCount: 70, spread: 70 });
  };

  const handleMarkAllNotificationsRead = () => {
    setNotifications(notifications.map((n) => ({ ...n, unread: false })));
  };

  // Render Current Active Main or Sub-View
  const renderCurrentContent = () => {
    // 1. Sub-Views
    if (activeSubView === 'product-details' && selectedProduct) {
      return (
        <ProductDetailsScreen
          product={selectedProduct}
          expenses={expenses}
          services={services}
          documents={documents}
          onBack={() => setActiveSubView('none')}
          onOpenEdit={(prod) => {
            setEditingProduct(prod);
            setIsAddProductOpen(true);
          }}
          onOpenAddExpense={(productId) => {
            setDefaultExpenseProductId(productId);
            setIsAddExpenseOpen(true);
          }}
          onOpenAddService={(productId) => {
            setDefaultExpenseProductId(productId);
            setIsAddExpenseOpen(true);
          }}
          onOpenClaimWarranty={() => {
            setActiveSubView('claims');
          }}
          onOpenQRCode={(prod) => {
            setQrProduct(prod);
            setIsQRCodeOpen(true);
          }}
          onOpenDocuments={() => {
            setActiveSubView('vault');
          }}
          language={language}
          isDark={isDark}
        />
      );
    }

    if (activeSubView === 'reminders') {
      return (
        <WarrantyReminderScreen
          products={products}
          onBack={() => setActiveSubView('none')}
          onSelectProduct={handleSelectProduct}
          language={language}
        />
      );
    }

    if (activeSubView === 'vault') {
      return (
        <InvoiceVaultScreen
          documents={documents}
          products={products}
          onBack={() => setActiveSubView('none')}
          onOpenScanner={() => setIsAIScannerOpen(true)}
          language={language}
        />
      );
    }

    if (activeSubView === 'claims') {
      return (
        <ClaimsScreen
          claims={claims}
          products={products}
          onBack={() => setActiveSubView('none')}
          onSelectProduct={handleSelectProduct}
          onAddClaim={handleAddClaim}
          language={language}
        />
      );
    }

    if (activeSubView === 'amc') {
      return (
        <AMCScreen
          amcRecords={amcRecords}
          insuranceRecords={insuranceRecords}
          products={products}
          onBack={() => setActiveSubView('none')}
          language={language}
        />
      );
    }

    if (activeSubView === 'reports') {
      return (
        <AnalyticsReportsScreen
          products={products}
          expenses={expenses}
          onBack={() => setActiveSubView('none')}
          language={language}
        />
      );
    }

    // 2. Primary Tabs
    switch (currentTab) {
      case 'home':
        return (
          <HomeDashboard
            userName={userProfile.name}
            products={products}
            expenses={expenses}
            notifications={notifications}
            onSelectProduct={handleSelectProduct}
            onOpenAddProduct={() => setIsAddProductOpen(true)}
            onOpenAddExpense={() => {
              setDefaultExpenseProductId(undefined);
              setIsAddExpenseOpen(true);
            }}
            onOpenScanner={() => setIsAIScannerOpen(true)}
            onOpenReports={() => setActiveSubView('reports')}
            onOpenWarrantyList={() => setCurrentTab('products')}
            onOpenExpensesList={() => setCurrentTab('expenses')}
            onOpenNotifications={() => setIsNotificationsOpen(true)}
            onOpenReminders={() => setActiveSubView('reminders')}
            language={language}
            isDark={isDark}
          />
        );

      case 'products':
        return (
          <ProductsScreen
            products={products}
            onSelectProduct={handleSelectProduct}
            onOpenAddProduct={() => setIsAddProductOpen(true)}
            language={language}
            isDark={isDark}
          />
        );

      case 'expenses':
        return (
          <ExpensesScreen
            expenses={expenses}
            onOpenAddExpense={() => {
              setDefaultExpenseProductId(undefined);
              setIsAddExpenseOpen(true);
            }}
            language={language}
          />
        );

      case 'more':
        return (
          <MoreSettingsScreen
            userName={userProfile.name}
            userEmail={userProfile.email}
            familyMembers={familyMembers}
            language={language}
            onLanguageChange={setLanguage}
            isDark={isDark}
            onToggleTheme={() => setIsDark(!isDark)}
            onOpenVault={() => setActiveSubView('vault')}
            onOpenAMC={() => setActiveSubView('amc')}
            onOpenClaims={() => setActiveSubView('claims')}
            onOpenReports={() => setActiveSubView('reports')}
            onOpenReminders={() => setActiveSubView('reminders')}
            onLogout={() => {
              setShowAuthModal(true);
            }}
          />
        );

      default:
        return null;
    }
  };

  return (
    <div className={isDark ? 'dark' : ''}>
      <div className="min-h-screen bg-slate-950 flex flex-col items-center justify-center text-slate-900 dark:text-slate-100 font-['Plus_Jakarta_Sans',sans-serif]">
        {/* Top Floating App Bar / Controls */}
        <header className="w-full max-w-5xl py-2 px-4 flex items-center justify-between text-xs text-slate-400">
          <div className="flex items-center space-x-2">
            <div className="w-6 h-6 rounded-lg bg-gradient-to-tr from-indigo-600 to-purple-600 flex items-center justify-center text-white font-black text-xs">
              W
            </div>
            <span className="font-bold text-white font-['Outfit',sans-serif]">WarrantyX Mobile</span>
            <span className="hidden sm:inline-block text-[11px] text-slate-400">
              — “Apne har product ka kharcha aur warranty, ek hi app mein”
            </span>
          </div>

          <div className="flex items-center space-x-2">
            {/* Reset Onboarding Demo */}
            <button
              onClick={() => {
                setHasCompletedOnboarding(false);
              }}
              className="px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-[11px] font-semibold transition-colors cursor-pointer"
              title="Test Onboarding Flow"
            >
              Demo Onboarding
            </button>

            {/* Language Pill */}
            <button
              onClick={() => setLanguage(language === 'en' ? 'hi' : 'en')}
              className="px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-[11px] font-bold transition-colors cursor-pointer"
            >
              {language === 'en' ? '🇮🇳 हिंदी' : '🇬🇧 EN'}
            </button>

            {/* Dark Mode */}
            <button
              onClick={() => setIsDark(!isDark)}
              className="px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-[11px] font-semibold transition-colors cursor-pointer"
            >
              {isDark ? '☀️ Light' : '🌙 Dark'}
            </button>
          </div>
        </header>

        {/* Mobile Mockup Simulator Viewport */}
        <main className="w-full flex items-center justify-center py-1 sm:py-3">
          <MobileFrame isDark={isDark}>
            {/* If Onboarding is active */}
            {!hasCompletedOnboarding ? (
              <OnboardingFlow
                onComplete={() => {
                  setHasCompletedOnboarding(true);
                  confetti({ particleCount: 50 });
                }}
                onLoginClick={() => {
                  setHasCompletedOnboarding(true);
                  setShowAuthModal(true);
                }}
                language={language}
              />
            ) : (
              <div className="flex flex-col h-full bg-slate-50 dark:bg-slate-900 transition-colors">
                {/* Scrollable Viewport Screen */}
                <div className="flex-1 overflow-y-auto overflow-x-hidden relative">
                  {renderCurrentContent()}
                </div>

                {/* Bottom Navigation Dock */}
                <BottomNav
                  currentTab={activeSubView !== 'none' ? 'home' : currentTab}
                  onTabChange={handleTabChange}
                  notificationCount={unreadCount}
                  language={language}
                />
              </div>
            )}
          </MobileFrame>
        </main>

        {/* --- GLOBAL MODALS --- */}
        {/* 1. Auth Modal */}
        <AuthModal
          isOpen={showAuthModal}
          onClose={() => setShowAuthModal(false)}
          onSuccess={(name, email) => {
            setUserProfile({ ...userProfile, name, email: email || userProfile.email });
            setShowAuthModal(false);
          }}
          language={language}
        />

        {/* 2. Add / Edit Product Modal */}
        <AddProductModal
          isOpen={isAddProductOpen}
          onClose={() => {
            setIsAddProductOpen(false);
            setEditingProduct(null);
          }}
          onSave={handleSaveProduct}
          language={language}
          initialData={editingProduct || undefined}
        />

        {/* 3. Add Expense Modal */}
        <AddExpenseModal
          isOpen={isAddExpenseOpen}
          onClose={() => setIsAddExpenseOpen(false)}
          onSave={handleSaveExpense}
          products={products}
          defaultProductId={defaultExpenseProductId}
          language={language}
        />

        {/* 4. AI Scanner Modal */}
        <AIScannerModal
          isOpen={isAIScannerOpen}
          onClose={() => setIsAIScannerOpen(false)}
          onConfirmExtractedProduct={handleConfirmScan}
          language={language}
        />

        {/* 5. QR Code Modal */}
        <QRCodeModal
          isOpen={isQRCodeOpen}
          onClose={() => {
            setIsQRCodeOpen(false);
            setQrProduct(null);
          }}
          product={qrProduct}
          language={language}
        />

        {/* 6. Notifications Modal */}
        <NotificationsModal
          isOpen={isNotificationsOpen}
          onClose={() => setIsNotificationsOpen(false)}
          notifications={notifications}
          onMarkAllRead={handleMarkAllNotificationsRead}
          onSelectNotification={(productId) => {
            if (productId) {
              const p = products.find((prod) => prod.id === productId);
              if (p) handleSelectProduct(p);
            }
          }}
          language={language}
        />
      </div>
    </div>
  );
};

export default App;
