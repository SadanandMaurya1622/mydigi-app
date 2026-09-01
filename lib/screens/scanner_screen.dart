import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _hasExtracted = false;
  late AnimationController _animController;

  // Sample invoices to scan
  int _selectedPreset = 0;
  final List<Map<String, dynamic>> _presets = [
    {
      'title': 'LG Refrigerator Invoice',
      'name': 'LG Frost-Free Double Door Refrigerator 360L',
      'category': 'Appliances',
      'brand': 'LG',
      'model': 'GL-T432APZY',
      'serial': 'LGRF998822KL',
      'price': 38500.0,
      'date': '20 Aug 2026',
      'seller': 'XYZ Mega Electronics, Mumbai',
      'invoice': 'INV-2026-0897',
      'warranty': '2 Years Comprehensive',
      'image': 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'MacBook Pro M3 Bill',
      'name': 'Apple MacBook Pro 14" M3 Pro 18GB/512GB',
      'category': 'Electronics',
      'brand': 'Apple',
      'model': 'MRX33HN/A',
      'serial': 'C02G8891KLPO',
      'price': 199900.0,
      'date': '25 Aug 2026',
      'seller': 'Imagine Apple Premium Reseller',
      'invoice': 'IMG-MUM-44912',
      'warranty': '1 Year Apple International Warranty',
      'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Dyson V12 Vacuum Receipt',
      'name': 'Dyson V12 Detect Slim Cordless Vacuum',
      'category': 'Appliances',
      'brand': 'Dyson',
      'model': 'SV20 V12',
      'serial': 'DYS-V12-99881',
      'price': 54900.0,
      'date': '15 Aug 2026',
      'seller': 'Dyson Demo Store High Street Phoenix',
      'invoice': 'DYS-2026-8819',
      'warranty': '2 Years Accidental & Motor Cover',
      'image': 'https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=800&q=80',
    },
  ];

  late TextEditingController _extractedName;
  late TextEditingController _extractedPrice;
  late TextEditingController _extractedBrand;
  late TextEditingController _extractedSerial;
  late TextEditingController _extractedSeller;
  late TextEditingController _extractedInvoice;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _extractedName = TextEditingController();
    _extractedPrice = TextEditingController();
    _extractedBrand = TextEditingController();
    _extractedSerial = TextEditingController();
    _extractedSeller = TextEditingController();
    _extractedInvoice = TextEditingController();
  }

  @override
  void dispose() {
    _animController.dispose();
    _extractedName.dispose();
    _extractedPrice.dispose();
    _extractedBrand.dispose();
    _extractedSerial.dispose();
    _extractedSeller.dispose();
    _extractedInvoice.dispose();
    super.dispose();
  }

  void _triggerScan() {
    setState(() => _isScanning = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        final data = _presets[_selectedPreset];
        _extractedName.text = data['name'];
        _extractedPrice.text = data['price'].toInt().toString();
        _extractedBrand.text = data['brand'];
        _extractedSerial.text = data['serial'];
        _extractedSeller.text = data['seller'];
        _extractedInvoice.text = data['invoice'];

        setState(() {
          _isScanning = false;
          _hasExtracted = true;
        });
      }
    });
  }

  void _confirmAndSave() {
    final provider = Provider.of<WarrantyProvider>(context, listen: false);
    final data = _presets[_selectedPreset];
    final price = double.tryParse(_extractedPrice.text.trim()) ?? (data['price'] as double);

    final newProduct = ProductItem(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      name: _extractedName.text.trim(),
      category: data['category'],
      brand: _extractedBrand.text.trim(),
      modelNumber: data['model'],
      serialNumber: _extractedSerial.text.trim(),
      purchaseDate: data['date'],
      purchasePrice: price,
      sellerName: _extractedSeller.text.trim(),
      sellerContact: '+91 98100 22334',
      invoiceNumber: _extractedInvoice.text.trim(),
      warrantyPeriod: data['warranty'],
      warrantyStartDate: data['date'],
      warrantyEndDate: '20 Aug 2028',
      warrantyStatus: 'Active',
      daysRemaining: 720,
      extendedWarranty: false,
      hasAMC: false,
      imageUrl: data['image'],
      costBreakdown: CostBreakdown(
        purchase: price,
      ),
    );

    provider.addProduct(newProduct);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Bill scanned & saved to your Warranty catalog!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppTranslations.tr('aiScannerTitle', lang),
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                if (!_hasExtracted) ...[
                  // Presets selector
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _presets.length,
                      itemBuilder: (context, idx) {
                        final isSel = _selectedPreset == idx;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              _presets[idx]['title'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                color: isSel ? Colors.white : Colors.white70,
                              ),
                            ),
                            selected: isSel,
                            selectedColor: AppTheme.primary,
                            backgroundColor: const Color(0xFF1E293B).withAlpha(160),
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedPreset = idx);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Camera Viewfinder Box with Glassy Frame
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withAlpha(180),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withAlpha(40), width: 1.5),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Bill Image Mock Preview
                            Image.network(
                              _presets[_selectedPreset]['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              opacity: const AlwaysStoppedAnimation(0.45),
                            ),

                            // Laser Scanner Animation Line
                            AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                return Positioned(
                                  top: MediaQuery.of(context).size.height * 0.15 * _animController.value + 60,
                                  left: 20,
                                  right: 20,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.transparent, Color(0xFF38BDF8), Color(0xFF818CF8), Colors.transparent],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF38BDF8).withAlpha(180),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Viewfinder Corners
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: AppTheme.secondary, width: 3),
                                    left: BorderSide(color: AppTheme.secondary, width: 3),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: AppTheme.secondary, width: 3),
                                    right: BorderSide(color: AppTheme.secondary, width: 3),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: AppTheme.secondary, width: 3),
                                    left: BorderSide(color: AppTheme.secondary, width: 3),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: AppTheme.secondary, width: 3),
                                    right: BorderSide(color: AppTheme.secondary, width: 3),
                                  ),
                                ),
                              ),
                            ),

                            // Center Message Glass Pill
                            if (!_isScanning)
                              GlassCard(
                                borderRadius: 20,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                opacity: 0.85,
                                child: const Text(
                                  'Align Bill or Invoice inside viewfinder',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Scan Action Button
                  ElevatedButton.icon(
                    onPressed: _isScanning ? null : _triggerScan,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt),
                    label: Text(
                      _isScanning ? 'Extracting with OCR AI...' : 'Snap & Auto-Extract Details',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  // Extracted Details Glass Review View
                  Expanded(
                    child: GlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(16),
                      opacity: 0.88,
                      blur: 24,
                      child: ListView(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'AI Extracted Data (Editable)',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildScanField('Product Name', _extractedName),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildScanField('Price (₹)', _extractedPrice)),
                              const SizedBox(width: 10),
                              Expanded(child: _buildScanField('Brand', _extractedBrand)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildScanField('Serial No', _extractedSerial)),
                              const SizedBox(width: 10),
                              Expanded(child: _buildScanField('Invoice No', _extractedInvoice)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildScanField('Seller Store', _extractedSeller),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _hasExtracted = false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white30),
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Scan Again'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _confirmAndSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Save to My Catalog', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E293B).withAlpha(160),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
