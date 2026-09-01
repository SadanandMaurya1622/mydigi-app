import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';

class AddProductScreen extends StatefulWidget {
  final ProductItem? editingProduct;

  const AddProductScreen({super.key, this.editingProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _serialController;
  late TextEditingController _priceController;
  late TextEditingController _sellerController;
  late TextEditingController _sellerContactController;
  late TextEditingController _invoiceNoController;
  late TextEditingController _warrantyPeriodController;
  late TextEditingController _imageUrlController;
  late TextEditingController _notesController;

  String _category = 'Appliances';
  String _purchaseDate = '15 May 2026';
  String _warrantyEndDate = '15 May 2027';
  bool _extendedWarranty = false;
  bool _hasAMC = false;

  final List<String> _categories = [
    'Appliances',
    'Electronics',
    'Vehicle',
    'Gadgets',
    'Furniture',
    'Other',
  ];

  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1628744448840-55bdb2497bd4?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1678685888221-cda773a3dcdb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.editingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _modelController = TextEditingController(text: p?.modelNumber ?? '');
    _serialController = TextEditingController(text: p?.serialNumber ?? '');
    _priceController = TextEditingController(text: p != null ? p.purchasePrice.toInt().toString() : '');
    _sellerController = TextEditingController(text: p?.sellerName ?? '');
    _sellerContactController = TextEditingController(text: p?.sellerContact ?? '');
    _invoiceNoController = TextEditingController(text: p?.invoiceNumber ?? '');
    _warrantyPeriodController = TextEditingController(text: p?.warrantyPeriod ?? '1 Year Comprehensive');
    _imageUrlController = TextEditingController(
      text: p?.imageUrl ?? _sampleImages.first,
    );
    _notesController = TextEditingController(text: p?.notes ?? '');

    if (p != null) {
      _category = p.category;
      _purchaseDate = p.purchaseDate;
      _warrantyEndDate = p.warrantyEndDate;
      _extendedWarranty = p.extendedWarranty;
      _hasAMC = p.hasAMC;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _priceController.dispose();
    _sellerController.dispose();
    _sellerContactController.dispose();
    _invoiceNoController.dispose();
    _warrantyPeriodController.dispose();
    _imageUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<WarrantyProvider>(context, listen: false);
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (widget.editingProduct != null) {
      // Update
      final updated = widget.editingProduct!.copyWith(
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        category: _category,
        modelNumber: _modelController.text.trim(),
        serialNumber: _serialController.text.trim(),
        purchasePrice: price,
        purchaseDate: _purchaseDate,
        warrantyPeriod: _warrantyPeriodController.text.trim(),
        warrantyEndDate: _warrantyEndDate,
        sellerName: _sellerController.text.trim(),
        sellerContact: _sellerContactController.text.trim(),
        invoiceNumber: _invoiceNoController.text.trim(),
        extendedWarranty: _extendedWarranty,
        hasAMC: _hasAMC,
        imageUrl: _imageUrlController.text.trim(),
        notes: _notesController.text.trim(),
      );
      provider.updateProduct(updated);
    } else {
      // Add new
      final newProd = ProductItem(
        id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        category: _category,
        brand: _brandController.text.trim(),
        modelNumber: _modelController.text.trim().isNotEmpty
            ? _modelController.text.trim()
            : 'MOD-${DateTime.now().millisecondsSinceEpoch % 1000}',
        serialNumber: _serialController.text.trim().isNotEmpty
            ? _serialController.text.trim()
            : 'SN-${DateTime.now().millisecondsSinceEpoch % 10000}',
        purchaseDate: _purchaseDate,
        purchasePrice: price,
        sellerName: _sellerController.text.trim().isNotEmpty
            ? _sellerController.text.trim()
            : 'Authorized Store',
        sellerContact: _sellerContactController.text.trim(),
        invoiceNumber: _invoiceNoController.text.trim().isNotEmpty
            ? _invoiceNoController.text.trim()
            : 'INV-${DateTime.now().millisecondsSinceEpoch % 10000}',
        warrantyPeriod: _warrantyPeriodController.text.trim(),
        warrantyStartDate: _purchaseDate,
        warrantyEndDate: _warrantyEndDate,
        warrantyStatus: 'Active',
        daysRemaining: 365,
        extendedWarranty: _extendedWarranty,
        hasAMC: _hasAMC,
        imageUrl: _imageUrlController.text.trim(),
        costBreakdown: CostBreakdown(
          purchase: price,
        ),
        notes: _notesController.text.trim(),
      );
      provider.addProduct(newProd);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editingProduct != null
              ? 'Product updated successfully!'
              : '✨ Product added to your digital vault!',
        ),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.editingProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? AppTranslations.tr('editProduct', lang) : AppTranslations.tr('addProduct', lang),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Section
              Text('Product Information', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _nameController,
                label: 'Product Title / Name *',
                hint: 'e.g. Samsung 1.5 Ton Split AC',
                isDark: isDark,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Product name is required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _brandController,
                      label: 'Brand *',
                      hint: 'e.g. Samsung, Apple, LG',
                      isDark: isDark,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Brand is required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _category,
                              isExpanded: true,
                              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _category = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _modelController,
                      label: 'Model Number',
                      hint: 'e.g. AR18TYSYAWKN',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _serialController,
                      label: 'Serial Number',
                      hint: 'e.g. SAM998844',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Purchase & Warranty Section
              Text('Purchase & Warranty', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Purchase Price (₹) *',
                      hint: 'e.g. 42000',
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Price is required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _warrantyPeriodController,
                      label: 'Warranty Period',
                      hint: 'e.g. 2 Years',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Purchase Date',
                      value: _purchaseDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2015),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setState(() {
                            _purchaseDate = '${picked.day} ${_monthName(picked.month)} ${picked.year}';
                          });
                        }
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Warranty End Date',
                      value: _warrantyEndDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime(2015),
                          lastDate: DateTime(2040),
                        );
                        if (picked != null) {
                          setState(() {
                            _warrantyEndDate = '${picked.day} ${_monthName(picked.month)} ${picked.year}';
                          });
                        }
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _sellerController,
                      label: 'Seller / Store Name',
                      hint: 'e.g. Croma, Reliance Digital',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _invoiceNoController,
                      label: 'Invoice / Bill No',
                      hint: 'e.g. INV-2026-90',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _sellerContactController,
                label: 'Seller Contact / Helpline',
                hint: 'e.g. 1800 200 4000',
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Toggles
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Extended Warranty Active', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Check if you purchased extra protection or AppleCare+', style: TextStyle(fontSize: 11)),
                value: _extendedWarranty,
                activeTrackColor: AppTheme.primary,
                onChanged: (val) => setState(() => _extendedWarranty = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Annual Maintenance Contract (AMC)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Check if product has active annual service package', style: TextStyle(fontSize: 11)),
                value: _hasAMC,
                activeTrackColor: AppTheme.primary,
                onChanged: (val) => setState(() => _hasAMC = val),
              ),
              const SizedBox(height: 16),

              // Image Selector
              Text('Product Photo / Thumbnail', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleImages.length,
                  itemBuilder: (context, idx) {
                    final img = _sampleImages[idx];
                    final isSelected = _imageUrlController.text == img;
                    return GestureDetector(
                      onTap: () => setState(() => _imageUrlController.text = img),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(img, width: 60, height: 60, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isEdit ? AppTranslations.tr('save', lang) : AppTranslations.tr('addProduct', lang),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            ),
            filled: true,
            fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const Icon(Icons.calendar_month, size: 16, color: AppTheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }
}
