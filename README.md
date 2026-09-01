# MyDigi - Pure Flutter Mobile Application

> **“Apne har product ka kharcha aur warranty, ek hi app mein.”**
> All-in-one Product, Warranty, Expense, Service, AMC, Claims, Invoice Vault & Home Asset Management Mobile App built with **Flutter & Dart** (Material 3).

---

## 📱 Features

- **🏠 Home Dashboard**: KPI metric cards (Total Assets, Expiring Soon, Active Warranties, Total Expenses), Critical 7-day urgent expiry banner, Quick action tools hub, and real-time protected items list.
- **📦 Products Catalog**: Search by name, brand, model & serial number, filter by category (Appliances, Electronics, Vehicle, Gadgets, Furniture, Other) and warranty lifecycle status.
- **🔍 AI Invoice OCR Camera**: Simulated real-time camera scanner with visual laser animation that auto-extracts product names, brands, purchase dates, prices, serial numbers, and warranty durations.
- **🏷️ Product Details & TCO**: Deep dive with total cost of ownership (TCO) breakdown (Purchase + Maintenance + AMC + Repair + Accessories), instant dynamic QR Code Asset Passport, expense history, and attached PDF/image invoices.
- **🧾 Expenses & Service Logs**: Complete chronological log of maintenance expenses, repair costs, annual maintenance packages, and accessory purchases.
- **🔒 Encrypted Invoice Vault**: Private cloud document archiving for receipts, warranty cards, insurance policies, and user manuals.
- **🛡️ Warranty Claims Center**: File new OEM claims, generate claim tickets, and track repair status (Submitted -> Under Review -> Assigned -> Resolved).
- **📋 AMC & Insurance Tracker**: Manage annual maintenance contracts, count remaining free service visits, and direct-dial support helplines.
- **📊 Analytics & Financial Reports**: Asset valuation distribution, warranty health statistics, and downloadable TCO PDF audit summaries.
- **🌐 Bilingual Localization**: Instant one-tap toggle between **English** and **Hindi (हिंदी)**.
- **🌙 Dark & Light Themes**: Full Material 3 dynamic color scheme with dark mode support.
- **👥 Family Sharing Hub**: Invite family members with role-based permissions (Co-Owner, Member).

---

## 🚀 Quick Start (Flutter)

### 1. Prerequisites
Ensure Flutter SDK is installed:
```bash
flutter --version
```

### 2. Fetch Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
# Run on default connected device
flutter run

# Or target specific platform:
flutter run -d ios       # iOS Simulator (iPhone 16)
flutter run -d android   # Android Phone / Emulator
flutter run -d chrome    # Google Chrome Web
flutter run -d macos     # macOS Desktop
```

### 4. Tests & Analysis
```bash
# Run tests
flutter test

# Run code analysis
flutter analyze
```

---

## 📂 Architecture

```
mydigi-app/
├── pubspec.yaml                       # Dependencies & project metadata
├── analysis_options.yaml              # Lint rules
├── lib/
│   ├── main.dart                      # App entry point with MultiProvider & ThemeMode
│   ├── models/
│   │   └── product_model.dart         # Data models (Product, Expense, AMC, Claim, Document)
│   ├── providers/
│   │   └── warranty_provider.dart     # Central Provider state manager with full CRUD
│   ├── utils/
│   │   ├── app_theme.dart             # Material 3 Light & Dark themes
│   │   └── translations.dart          # English & Hindi bilingual dictionary
│   └── screens/
│       ├── main_navigation_host.dart  # Material 3 Bottom Navigation bar with badge counters
│       ├── home_dashboard_screen.dart # KPI cards, urgent expiry alert, quick action grid
│       ├── products_screen.dart       # Product catalog, category chips, status filters
│       ├── product_detail_screen.dart # Hero view, TCO progress, QR Passport, expenses & docs
│       ├── add_product_screen.dart    # Add/Edit product form with date & image pickers
│       ├── scanner_screen.dart        # AI Bill OCR Camera scanner with laser animation
│       ├── expenses_screen.dart       # Expense logs, category breakdown, Add Expense modal
│       ├── invoice_vault_screen.dart  # Encrypted document vault with categories
│       ├── claims_screen.dart         # Warranty claims tracker and submission
│       ├── amc_screen.dart            # AMC contracts & insurance policies
│       ├── analytics_reports_screen.dart # Asset valuation, charts, TCO export
│       ├── more_settings_screen.dart  # Profile, Family sharing, Theme & Language
│       └── notifications_sheet.dart   # Unread notifications center
├── test/
│   └── widget_test.dart               # Automated Flutter widget smoke tests
├── android/                           # Android native configuration
├── ios/                               # iOS native configuration
├── web/                               # Web build configuration
└── macos/                             # macOS native desktop configuration
```
