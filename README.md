# MyDigi - Pure Flutter Mobile Application

> **“Apne har product ka kharcha aur warranty, ek hi app mein.”**
> All-in-one Product, Warranty, Expense, Service, AMC, Claims, Invoice Vault & Home Asset Management Mobile App built with **Flutter & Dart** (Material 3).

---

## 📱 Features

- **🏠 Home Dashboard**: KPI metric cards (Total Assets, Expiring Soon, Active Warranties, Total Expenses), Critical 7-day urgent expiry banner, Quick action tools hub, and real-time protected items list.
- **📦 Products Catalog**: Search by name, brand, model & serial number, filter by category (Appliances, Electronics, Vehicle, Gadgets, Furniture, Other) and warranty lifecycle status.
- **🔍 Bill Scanner**: Opens the device camera or gallery and reads English/Latin bill text on Android and iOS using on-device ML Kit. After recognition, the editable form opens automatically with the detected product, brand, model, serial number, invoice number, seller, purchase date, and amount. The bill photo is available in an expandable preview. Missing or unreadable fields need manual entry. A bill total is explicitly marked for review when the bill contains multiple products. Go back to save just the photo to the vault, or save the form to attach it to the product.
- **🏷️ Product Details & TCO**: Deep dive with total cost of ownership (TCO) breakdown (Purchase + Maintenance + AMC + Repair + Accessories), instant dynamic QR Code Asset Passport, expense history, and attached PDF/image invoices.
- **🧾 Expenses & Service Logs**: Complete chronological log of maintenance expenses, repair costs, annual maintenance packages, and accessory purchases.
- **📁 Invoice Vault**: Captured bill photos and attachment metadata are stored together on the device and remain available after restarting the app. Tap a bill to view and zoom the original photo. Photos are scoped to the active account (or guest profile); they are not backed up to the cloud and are removed if app data is cleared or the app is uninstalled. Older cloud records without a file display an unavailable-file message.
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

iOS bill recognition requires iOS 15.5 or newer and CocoaPods for ML Kit;
other supported plugins continue to use Swift Package Manager. On desktop and
web, bill photos can still be saved and details entered manually. The bundled
recognizer currently reads Latin text; Hindi script recognition is not enabled.

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

# Run native OCR against a synthetic receipt on a connected phone:
flutter test integration_test/bill_scanner_device_test.dart -d <device-id>
# Then restore the normal application entry point:
flutter run -d <device-id>
```

---

## App icon

The source artwork is stored in `assets/branding/app_icon.png`. After replacing
it, regenerate the Android, iOS, web, Windows, and macOS icons with:

```bash
flutter pub get
dart run tool/generate_app_icons.dart
```

Icon settings are in `flutter_launcher_icons.yaml`. The script prepares opaque
iOS artwork and padded web icons, then generates the platform assets. It also
preserves the Xcode Swift asset symbol setting affected by the icon generator.
Rebuild and reinstall the app to see launcher icon changes; hot reload does not
update native icons.

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
│       ├── scanner_screen.dart        # Camera, native bill OCR, and editable review
│       ├── expenses_screen.dart       # Expense logs, category breakdown, Add Expense modal
│       ├── invoice_vault_screen.dart  # Persisted bill photos with categories
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
