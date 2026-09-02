import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';

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
    final now = DateTime.now();

    _nameController = TextEditingController(text: p?.name ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _modelController = TextEditingController(text: p?.modelNumber ?? '');
    _serialController = TextEditingController(text: p?.serialNumber ?? '');
    _priceController = TextEditingController(text: p != null ? p.purchasePrice.toInt().toString() : '');
    _sellerController = TextEditingController(text: p?.sellerName ?? '');
    _sellerContactController = TextEditingController(text: p?.sellerContact ?? '');
    _invoiceNoController = TextEditingController(text: p?.invoiceNumber ?? 'INV-${now.millisecondsSinceEpoch.toString().substring(7)}');
    _warrantyPeriodController = TextEditingController(text: p?.warrantyPeriod ?? '1 Year');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? _sampleImages.first);
    _notesController = TextEditingController(text: p?.notes ?? '');

    if (p != null) {
      _category = p.category;
      _purchaseDate = p.purchaseDate;
      _warrantyEndDate = p.warrantyEndDate;
      _extendedWarranty = p.extendedWarranty;
      _hasAMC = p.hasAMC;
    } else {
      _purchaseDate = '${now.day} ${_monthName(now.month)} ${now.year}';
      final nextYear = DateTime(now.year + 1, now.month, now.day);
      _warrantyEndDate = '${nextYear.day} ${_monthName(nextYear.month)} ${nextYear.year}';
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

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<WarrantyProvider>(context, listen: false);
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    int daysLeft = 365;
    try {
      final parts = _warrantyEndDate.split(' ');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final month = _monthIndex(parts[1]);
        final year = int.tryParse(parts[2]) ?? (DateTime.now().year + 1);
        final endDt = DateTime(year, month, day);
        daysLeft = endDt.difference(DateTime.now()).inDays;
      }
    } catch (_) {}

    final status = daysLeft < 0 ? 'Expired' : (daysLeft <= 30 ? 'Expiring Soon' : 'Active');

    final newProduct = ProductItem(
      id: widget.editingProduct?.id ?? 'prod-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _category,
      brand: _brandController.text.trim(),
      modelNumber: _modelController.text.trim().isNotEmpty ? _modelController.text.trim() : 'N/A',
      serialNumber: _serialController.text.trim().isNotEmpty ? _serialController.text.trim() : 'SRN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      purchaseDate: _purchaseDate,
      purchasePrice: price,
      sellerName: _sellerController.text.trim().isNotEmpty ? _sellerController.text.trim() : 'Retail Store',
      sellerContact: _sellerContactController.text.trim(),
      invoiceNumber: _invoiceNoController.text.trim(),
      warrantyPeriod: _warrantyPeriodController.text.trim(),
      warrantyStartDate: _purchaseDate,
      warrantyEndDate: _warrantyEndDate,
      warrantyStatus: status,
      daysRemaining: daysLeft < 0 ? 0 : daysLeft,
      extendedWarranty: _extendedWarranty,
      hasAMC: _hasAMC,
      imageUrl: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : _sampleImages.first,
      notes: _notesController.text.trim(),
      costBreakdown: widget.editingProduct?.costBreakdown ?? CostBreakdown(purchase: price),
    );

    if (widget.editingProduct != null) {
      provider.updateProduct(newProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Product updated successfully!'), backgroundColor: AppTheme.success),
      );
    } else {
      provider.addProduct(newProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✨ Product & Warranty added successfully!'), backgroundColor: AppTheme.success),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.editingProduct != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isEdit ? AppTranslations.tr('editProduct', lang) : AppTranslations.tr('addProduct', lang),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Basic Info Glass Card
                  GlassCard(
                    borderRadius: 22,
                    padding: const EdgeInsets.all(16),
                    opacity: 0.82,
                    blur: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product Information', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
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
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(14),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Purchase & Warranty Glass Card
                  GlassCard(
                    borderRadius: 22,
                    padding: const EdgeInsets.all(16),
                    opacity: 0.82,
                    blur: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Purchase & Warranty', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
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
                        const SizedBox(height: 8),

                        // Quick 1-Tap Warranty Presets
                        Wrap(
                          spacing: 8,
                          children: ['1 Year', '2 Years', '3 Years', '5 Years'].map((duration) {
                            final isSelected = _warrantyPeriodController.text == duration;
                            return ChoiceChip(
                              label: Text(duration, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              selected: isSelected,
                              selectedColor: AppTheme.primary,
                              showCheckmark: false,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _warrantyPeriodController.text = duration;
                                    final years = int.tryParse(duration.split(' ').first) ?? 1;
                                    final now = DateTime.now();
                                    final end = DateTime(now.year + years, now.month, now.day);
                                    _warrantyEndDate = '${end.day} ${_monthName(end.month)} ${end.year}';
                                  });
                                }
                              },
                            );
                          }).toList(),
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
                                hint: 'e.g. CR-99881',
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Image & Notes Glass Card
                  GlassCard(
                    borderRadius: 22,
                    padding: const EdgeInsets.all(16),
                    opacity: 0.82,
                    blur: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Photo & Extra Notes', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),

                        // Sample Images Horizontal Picker
                        const Text('Choose Product Image Preset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 64,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _sampleImages.length,
                            itemBuilder: (context, idx) {
                              final img = _sampleImages[idx];
                              final isSel = _imageUrlController.text == img;
                              return GestureDetector(
                                onTap: () => setState(() => _imageUrlController.text = img),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSel ? AppTheme.primary : Colors.transparent,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(img, fit: BoxFit.cover),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildTextField(
                          controller: _notesController,
                          label: 'Notes (Optional)',
                          hint: 'e.g. 5-star BEE rating, extended warranty included',
                          maxLines: 2,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      isEdit ? 'Save Changes' : 'Add to MyDigi Vault',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
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
    int maxLines = 1,
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
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  int _monthIndex(String name) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final idx = months.indexOf(name);
    return idx != -1 ? idx + 1 : 1;
  }
}
