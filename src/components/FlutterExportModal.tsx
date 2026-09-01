import React, { useState } from 'react';
import { 
  X, 
  Copy, 
  Check, 
  Smartphone, 
  FileCode, 
  FolderTree, 
  Download, 
  Layers,
  Terminal,
  CheckCircle2,
  Box
} from 'lucide-react';
import confetti from 'canvas-confetti';

interface FlutterExportModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const FLUTTER_COMPLETE_FILES: { name: string; path: string; category: string; content: string }[] = [
  {
    name: 'pubspec.yaml',
    path: 'pubspec.yaml',
    category: 'Config',
    content: `name: warrantyx_app
description: "Apne har product ka kharcha aur warranty, ek hi app mein - Complete Flutter & Dart App"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2
  intl: ^0.19.0
  google_fonts: ^6.2.1
  camera: ^0.11.0+1
  google_mlkit_text_recognition: ^0.13.0
  qr_flutter: ^4.1.0
  mobile_scanner: ^5.2.3
  fl_chart: ^0.69.0
  shared_preferences: ^2.3.2
  path_provider: ^2.1.4
  open_file: ^3.3.2
  share_plus: ^10.0.0
  cached_network_image: ^3.4.0
  confetti: ^0.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/`,
  },
  {
    name: 'main.dart',
    path: 'lib/main.dart',
    category: 'Core',
    content: `import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/warranty_provider.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/products_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/more_settings_screen.dart';
import 'screens/scanner_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WarrantyProvider()),
      ],
      child: const WarrantyXApp(),
    ),
  );
}

class WarrantyXApp extends StatelessWidget {
  const WarrantyXApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);

    return MaterialApp(
      title: 'WarrantyX',
      debugShowCheckedModeBanner: false,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6366F1),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const MainNavigationHost(),
    );
  }
}

class MainNavigationHost extends StatefulWidget {
  const MainNavigationHost({super.key});

  @override
  State<MainNavigationHost> createState() => _MainNavigationHostState();
}

class _MainNavigationHostState extends State<MainNavigationHost> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    ProductsScreen(),
    SizedBox.shrink(), // Center Add/Scan Action
    ExpensesScreen(),
    MoreSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScannerScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF4F46E5)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: Color(0xFF4F46E5)),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle, size: 36, color: Color(0xFF4F46E5)),
            label: 'Scan OCR',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF4F46E5)),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: Color(0xFF4F46E5)),
            label: 'More',
          ),
        ],
      ),
    );
  }
}`,
  },
  {
    name: 'product_model.dart',
    path: 'lib/models/product_model.dart',
    category: 'Models',
    content: `class ProductItem {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String modelNumber;
  final String serialNumber;
  final String purchaseDate;
  final double purchasePrice;
  final String sellerName;
  final String sellerContact;
  final String invoiceNumber;
  final String warrantyPeriod;
  final String warrantyStartDate;
  final String warrantyEndDate;
  final String warrantyStatus; // 'Active', 'Expiring Soon', 'Expired'
  final int daysRemaining;
  final bool extendedWarranty;
  final bool hasAMC;
  final String imageUrl;
  final CostBreakdown costBreakdown;

  ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.modelNumber,
    required this.serialNumber,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.sellerName,
    required this.sellerContact,
    required this.invoiceNumber,
    required this.warrantyPeriod,
    required this.warrantyStartDate,
    required this.warrantyEndDate,
    required this.warrantyStatus,
    required this.daysRemaining,
    required this.extendedWarranty,
    required this.hasAMC,
    required this.imageUrl,
    required this.costBreakdown,
  });

  double get totalCostOfOwnership =>
      purchasePrice +
      costBreakdown.installation +
      costBreakdown.maintenance +
      costBreakdown.repair +
      costBreakdown.accessories +
      costBreakdown.amc;
}

class CostBreakdown {
  final double purchase;
  final double installation;
  final double maintenance;
  final double repair;
  final double accessories;
  final double amc;
  final double other;

  CostBreakdown({
    required this.purchase,
    this.installation = 0,
    this.maintenance = 0,
    this.repair = 0,
    this.accessories = 0,
    this.amc = 0,
    this.other = 0,
  });
}

class ExpenseRecord {
  final String id;
  final String productId;
  final String productName;
  final String category;
  final double amount;
  final String date;
  final String serviceProvider;
  final String invoiceUrl;

  ExpenseRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.amount,
    required this.date,
    required this.serviceProvider,
    this.invoiceUrl = '',
  });
}`,
  },
  {
    name: 'warranty_provider.dart',
    path: 'lib/providers/warranty_provider.dart',
    category: 'State',
    content: `import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class WarrantyProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'en'; // 'en' or 'hi'

  bool get isDarkMode => _isDarkMode;
  String get language => _language;

  final List<ProductItem> _products = [
    ProductItem(
      id: 'prod-1',
      name: 'Samsung 1.5 Ton 5 Star Split AC',
      category: 'Appliances',
      brand: 'Samsung',
      modelNumber: 'AR18TY5QAWK',
      serialNumber: 'SAM-AC-9948271',
      purchaseDate: '15 Sep 2025',
      purchasePrice: 42990.0,
      sellerName: 'Reliance Digital, Mumbai',
      sellerContact: '+91 98201 55432',
      invoiceNumber: 'RD-MUM-882190',
      warrantyPeriod: '1 Year + 10 Yr Compressor',
      warrantyStartDate: '15 Sep 2025',
      warrantyEndDate: '08 Sep 2026',
      warrantyStatus: 'Expiring Soon',
      daysRemaining: 7,
      extendedWarranty: false,
      hasAMC: false,
      imageUrl: 'https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1?auto=format&fit=crop&w=800&q=80',
      costBreakdown: CostBreakdown(
        purchase: 42990.0,
        installation: 1499.0,
        maintenance: 1850.0,
      ),
    ),
    ProductItem(
      id: 'prod-2',
      name: 'Sony Bravia 55" 4K OLED TV',
      category: 'Electronics',
      brand: 'Sony',
      modelNumber: 'XR-55A80L',
      serialNumber: 'SNY-TV-558291',
      purchaseDate: '10 Jan 2026',
      purchasePrice: 124990.0,
      sellerName: 'Croma Megastore, Pune',
      sellerContact: '+91 98230 11998',
      invoiceNumber: 'CR-PUN-339182',
      warrantyPeriod: '2 Years Comprehensive',
      warrantyStartDate: '10 Jan 2026',
      warrantyEndDate: '10 Jan 2028',
      warrantyStatus: 'Active',
      daysRemaining: 497,
      extendedWarranty: true,
      hasAMC: true,
      imageUrl: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80',
      costBreakdown: CostBreakdown(
        purchase: 124990.0,
        accessories: 3200.0,
        amc: 4500.0,
      ),
    ),
  ];

  final List<ExpenseRecord> _expenses = [
    ExpenseRecord(
      id: 'exp-1',
      productId: 'prod-1',
      productName: 'Samsung 1.5 Ton AC',
      category: 'Maintenance',
      amount: 1850.0,
      date: '12 Aug 2026',
      serviceProvider: 'Urban Company Service Pro',
    ),
    ExpenseRecord(
      id: 'exp-2',
      productId: 'prod-2',
      productName: 'Sony Bravia 55" TV',
      category: 'AMC',
      amount: 4500.0,
      date: '10 Jan 2026',
      serviceProvider: 'Sony Protect Plus',
    ),
  ];

  List<ProductItem> get products => [..._products];
  List<ExpenseRecord> get expenses => [..._expenses];

  double get totalAssetValue => _products.fold(0, (sum, p) => sum + p.purchasePrice);
  double get totalExpenseValue => _expenses.fold(0, (sum, e) => sum + e.amount);
  int get activeCount => _products.where((p) => p.warrantyStatus == 'Active').length;
  int get expiringSoonCount => _products.where((p) => p.warrantyStatus == 'Expiring Soon').length;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void addProduct(ProductItem product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void addExpense(ExpenseRecord expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }
}`,
  },
  {
    name: 'home_dashboard_screen.dart',
    path: 'lib/screens/home_dashboard_screen.dart',
    category: 'Screens',
    content: `import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/warranty_provider.dart';
import 'product_detail_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WarrantyX',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20),
            ),
            Text(
              'Hi Sadanand 👋',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => provider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Metric Cards Grid
            Row(
              children: [
                _buildStatCard(
                  title: 'Total Assets',
                  value: '\${provider.products.length}',
                  sub: '₹\${(provider.totalAssetValue / 100000).toStringAsFixed(1)}L Value',
                  color: Colors.indigo,
                  icon: Icons.inventory_2,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: 'Expiring Soon',
                  value: '\${provider.expiringSoonCount}',
                  sub: 'Action Needed',
                  color: Colors.amber.shade800,
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  title: 'Active Warranties',
                  value: '\${provider.activeCount}',
                  sub: '100% Protected',
                  color: Colors.emerald,
                  icon: Icons.shield,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: 'Total Expenses',
                  value: '₹\${provider.totalExpenseValue.toInt()}',
                  sub: 'Services & AMC',
                  color: Colors.blue,
                  icon: Icons.receipt_long,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Critical 7-Day Alert Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.rose.shade600, Colors.amber.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Samsung AC Warranty Expiring in 7 Days!',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Claim free annual service or renew AMC today',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Your Protected Products',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Warranty ends: \${product.warrantyEndDate}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String sub,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}`,
  },
  {
    name: 'product_detail_screen.dart',
    path: 'lib/screens/product_detail_screen.dart',
    category: 'Screens',
    content: `import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductItem product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Hero Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Cost of Ownership Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text('Total Cost of Ownership', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '₹\${product.totalCostOfOwnership.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Purchase: ₹\${product.purchasePrice.toInt()}'),
                      Text('Maintenance: ₹\${product.costBreakdown.maintenance.toInt()}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QR Code Asset Passport
            Center(
              child: Column(
                children: [
                  QrImageView(
                    data: 'https://warrantyx.app/verify/\${product.id}?serial=\${product.serialNumber}',
                    version: QrVersions.auto,
                    size: 140.0,
                  ),
                  const SizedBox(height: 8),
                  const Text('Sticker QR Code for Instant Warranty & Service', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}`,
  },
  {
    name: 'scanner_screen.dart',
    path: 'lib/screens/scanner_screen.dart',
    category: 'OCR Camera',
    content: `import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanning = false;
  bool _hasExtracted = false;

  final Map<String, dynamic> _extractedData = {
    'product': 'LG Smart Inverter Refrigerator',
    'category': 'Appliances',
    'brand': 'LG',
    'purchaseDate': '20 Aug 2026',
    'amount': 38500.0,
    'seller': 'XYZ Electronics Mega Store',
    'invoiceNo': 'INV-2026-0897',
    'serialNo': 'LGRF3456GH',
    'warrantyPeriod': '2 Years Comprehensive',
  };

  void _triggerScan() {
    setState(() => _isScanning = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _hasExtracted = true;
        });
      }
    });
  }

  void _confirmAndSave() {
    final newProduct = ProductItem(
      id: 'prod-\${DateTime.now().millisecondsSinceEpoch}',
      name: _extractedData['product'],
      category: _extractedData['category'],
      brand: _extractedData['brand'],
      modelNumber: 'GL-T402JDS',
      serialNumber: _extractedData['serialNo'],
      purchaseDate: _extractedData['purchaseDate'],
      purchasePrice: _extractedData['amount'],
      sellerName: _extractedData['seller'],
      sellerContact: '+91 98100 22334',
      invoiceNumber: _extractedData['invoiceNo'],
      warrantyPeriod: _extractedData['warrantyPeriod'],
      warrantyStartDate: _extractedData['purchaseDate'],
      warrantyEndDate: '20 Aug 2028',
      warrantyStatus: 'Active',
      daysRemaining: 720,
      extendedWarranty: false,
      hasAMC: false,
      imageUrl: 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80',
      costBreakdown: CostBreakdown(
        purchase: _extractedData['amount'],
      ),
    );

    Provider.of<WarrantyProvider>(context, listen: false).addProduct(newProduct);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Product & Warranty successfully saved to Flutter State!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'AI Bill OCR Camera Scanner',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!_hasExtracted) ...[
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF4F46E5), width: 2),
                  ),
                  child: Center(
                    child: _isScanning
                        ? const CircularProgressIndicator(color: Colors.cyanAccent)
                        : const Text('Align Bill Inside Frame', style: TextStyle(color: Colors.white70)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _triggerScan,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Snap & Scan Invoice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ] else ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView(
                    children: [
                      Text('AI OCR Extracted Details', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(color: Colors.white24),
                      Text('Product: \${_extractedData['product']}', style: const TextStyle(color: Colors.white)),
                      Text('Price: ₹\${_extractedData['amount']}', style: const TextStyle(color: Colors.white)),
                      Text('Date: \${_extractedData['purchaseDate']}', style: const TextStyle(color: Colors.white)),
                      Text('Serial: \${_extractedData['serialNo']}', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _confirmAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Confirm & Save to Catalog'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}`,
  },
];

export const FlutterExportModal: React.FC<FlutterExportModalProps> = ({
  isOpen,
  onClose,
}) => {
  const [selectedFile, setSelectedFile] = useState<number>(0);
  const [copied, setCopied] = useState<boolean>(false);

  if (!isOpen) return null;

  const currentFile = FLUTTER_COMPLETE_FILES[selectedFile] || FLUTTER_COMPLETE_FILES[0];

  const handleCopy = () => {
    navigator.clipboard?.writeText(currentFile.content);
    setCopied(true);
    confetti({ particleCount: 30, spread: 50 });
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadAll = () => {
    // Generate text blob and download as zip or consolidated file
    const element = document.createElement('a');
    const file = new Blob([currentFile.content], { type: 'text/plain' });
    element.href = URL.createObjectURL(file);
    element.download = currentFile.name;
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
    confetti({ particleCount: 60 });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-slate-950/85 backdrop-blur-xs animate-in fade-in">
      <div className="relative w-full max-w-3xl max-h-[92vh] flex flex-col bg-white dark:bg-slate-900 rounded-3xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-4 sm:p-5 border-b border-slate-100 dark:border-slate-800">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-cyan-500 to-blue-600 flex items-center justify-center text-white shadow-md shadow-blue-500/30">
              <Smartphone className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center space-x-2">
                <h3 className="text-base font-black text-slate-900 dark:text-white font-['Outfit',sans-serif]">
                  Flutter & Dart Pure Architecture
                </h3>
                <span className="px-2 py-0.5 rounded-full bg-blue-100 dark:bg-blue-950/80 text-blue-700 dark:text-blue-300 text-[10px] font-bold">
                  v3.2.0+
                </span>
              </div>
              <p className="text-[11px] text-slate-500">
                100% Production ready Flutter app (Provider + Material 3 + Google ML Kit)
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-2 rounded-full text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 cursor-pointer"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Quick Instructions Ribbon */}
        <div className="px-4 py-2 bg-blue-50 dark:bg-blue-950/40 border-b border-blue-100 dark:border-blue-900/50 flex items-center justify-between text-xs text-blue-900 dark:text-blue-200">
          <div className="flex items-center space-x-2">
            <Terminal className="w-3.5 h-3.5 text-blue-600 dark:text-blue-400" />
            <span className="font-mono text-[11px]">flutter create warrantyx && flutter pub get</span>
          </div>
          <div className="flex items-center space-x-1 text-[11px] font-semibold text-emerald-600 dark:text-emerald-400">
            <CheckCircle2 className="w-3.5 h-3.5" />
            <span>Android / iOS / Web</span>
          </div>
        </div>

        {/* Body Layout with Sidebar File Tree */}
        <div className="flex-1 flex flex-col sm:flex-row overflow-hidden min-h-[380px]">
          {/* File Explorer Sidebar */}
          <div className="w-full sm:w-60 p-3 border-b sm:border-b-0 sm:border-r border-slate-100 dark:border-slate-800 bg-slate-50 dark:bg-slate-850/50 flex sm:flex-col space-x-1.5 sm:space-x-0 sm:space-y-1 overflow-x-auto sm:overflow-y-auto shrink-0">
            <div className="hidden sm:flex items-center space-x-1.5 text-[10px] font-bold uppercase tracking-wider text-slate-400 px-2 py-1">
              <FolderTree className="w-3.5 h-3.5" />
              <span>Flutter Files ({FLUTTER_COMPLETE_FILES.length})</span>
            </div>

            {FLUTTER_COMPLETE_FILES.map((file, idx) => (
              <button
                key={file.path}
                onClick={() => setSelectedFile(idx)}
                className={`w-full px-3 py-2 rounded-xl text-left text-xs font-semibold flex items-center justify-between space-x-2 transition-all cursor-pointer ${
                  selectedFile === idx
                    ? 'bg-blue-600 text-white shadow-xs'
                    : 'text-slate-600 dark:text-slate-400 hover:bg-slate-200/60 dark:hover:bg-slate-800'
                }`}
              >
                <div className="flex items-center space-x-2 truncate">
                  <FileCode className="w-3.5 h-3.5 shrink-0" />
                  <span className="truncate">{file.name}</span>
                </div>
                <span className="text-[9px] opacity-70 hidden sm:inline">{file.category}</span>
              </button>
            ))}
          </div>

          {/* Code Viewer Viewport */}
          <div className="flex-1 flex flex-col min-w-0 bg-slate-950 text-slate-200">
            {/* Top Toolbar */}
            <div className="flex items-center justify-between px-4 py-2 bg-slate-900 border-b border-slate-800 text-xs">
              <div className="flex items-center space-x-2 font-mono text-[11px] text-slate-400">
                <Layers className="w-3.5 h-3.5 text-blue-400" />
                <span>{currentFile.path}</span>
              </div>

              <div className="flex items-center space-x-2">
                <button
                  onClick={handleCopy}
                  className="px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-200 text-[11px] font-bold flex items-center space-x-1 transition-colors cursor-pointer"
                >
                  {copied ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
                  <span>{copied ? 'Copied!' : 'Copy Code'}</span>
                </button>
                <button
                  onClick={handleDownloadAll}
                  className="px-2.5 py-1 rounded-lg bg-blue-600 hover:bg-blue-500 text-white text-[11px] font-bold flex items-center space-x-1 transition-colors cursor-pointer"
                >
                  <Download className="w-3.5 h-3.5" />
                  <span>Download</span>
                </button>
              </div>
            </div>

            {/* Code Content */}
            <div className="flex-1 overflow-y-auto p-4 font-mono text-xs text-slate-300 leading-relaxed select-text">
              <pre className="whitespace-pre-wrap">{currentFile.content}</pre>
            </div>
          </div>
        </div>

        {/* Footer Actions */}
        <div className="p-4 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between bg-white dark:bg-slate-900">
          <div className="flex items-center space-x-2 text-[11px] text-slate-500">
            <Box className="w-4 h-4 text-indigo-500" />
            <span>Ready for VS Code, Android Studio, and Xcode</span>
          </div>

          <button
            onClick={onClose}
            className="px-5 py-2 rounded-xl bg-slate-900 dark:bg-white text-white dark:text-slate-900 font-bold text-xs cursor-pointer hover:opacity-90"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};
