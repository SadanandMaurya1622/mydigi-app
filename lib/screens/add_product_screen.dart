import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../models/scanned_bill.dart';
import '../providers/warranty_provider.dart';
import '../services/bill_details_parser.dart';
import '../services/local_bill_vault.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';

class AddProductScreen extends StatefulWidget {
  final ProductItem? editingProduct;
  final Uint8List? billPhoto;
  final String? billDocumentId;
  final ScannedBill? scannedBill;

  const AddProductScreen({
    super.key,
    this.editingProduct,
    this.billPhoto,
    this.billDocumentId,
    this.scannedBill,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  late final String _productId;
  late final String _billDocumentId;

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
    final scanned = widget.scannedBill;
    final now = DateTime.now();
    _productId = p?.id ?? 'prod-${now.microsecondsSinceEpoch}';
    _billDocumentId = widget.billDocumentId ?? LocalBillVault.newId();

    _nameController = TextEditingController(
      text: p?.name ?? scanned?.productName ?? '',
    );
    _brandController = TextEditingController(
      text: p?.brand ?? scanned?.brand ?? '',
    );
    _modelController = TextEditingController(
      text: p?.modelNumber ?? scanned?.modelNumber ?? '',
    );
    _serialController = TextEditingController(
      text: p?.serialNumber ?? scanned?.serialNumber ?? '',
    );
    _priceController = TextEditingController(
      text: (p?.purchasePrice ?? scanned?.amount)?.toStringAsFixed(2) ?? '',
    );
    _sellerController = TextEditingController(
      text: p?.sellerName ?? scanned?.sellerName ?? '',
    );
    _sellerContactController = TextEditingController(
      text: p?.sellerContact ?? '',
    );
    _invoiceNoController = TextEditingController(
      text:
          p?.invoiceNumber ??
          scanned?.invoiceNumber ??
          (widget.billPhoto != null
              ? ''
              : 'INV-${now.millisecondsSinceEpoch.toString().substring(7)}'),
    );
    _warrantyPeriodController = TextEditingController(
      text: p?.warrantyPeriod ?? '1 Year',
    );
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
    } else {
      final purchase = scanned?.purchaseDate ?? now;
      _purchaseDate =
          '${purchase.day} ${_monthName(purchase.month)} ${purchase.year}';
      final nextYear = DateTime(
        purchase.year + 1,
        purchase.month,
        purchase.day,
      );
      _warrantyEndDate =
          '${nextYear.day} ${_monthName(nextYear.month)} ${nextYear.year}';
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

  Future<void> _handleSave() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final provider = Provider.of<WarrantyProvider>(context, listen: false);
    final price = BillDetailsParser.parseAmount(_priceController.text.trim())!;

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

    final status = daysLeft < 0
        ? 'Expired'
        : (daysLeft <= 30 ? 'Expiring Soon' : 'Active');

    final newProduct = ProductItem(
      id: _productId,
      name: _nameController.text.trim(),
      category: _category,
      brand: _brandController.text.trim(),
      modelNumber: _modelController.text.trim().isNotEmpty
          ? _modelController.text.trim()
          : 'N/A',
      serialNumber: _serialController.text.trim().isNotEmpty
          ? _serialController.text.trim()
          : 'N/A',
      purchaseDate: _purchaseDate,
      purchasePrice: price,
      sellerName: _sellerController.text.trim().isNotEmpty
          ? _sellerController.text.trim()
          : 'Retail Store',
      sellerContact: _sellerContactController.text.trim(),
      invoiceNumber: _invoiceNoController.text.trim(),
      warrantyPeriod: _warrantyPeriodController.text.trim(),
      warrantyStartDate: _purchaseDate,
      warrantyEndDate: _warrantyEndDate,
      warrantyStatus: status,
      daysRemaining: daysLeft < 0 ? 0 : daysLeft,
      extendedWarranty: _extendedWarranty,
      hasAMC: _hasAMC,
      imageUrl: _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : _sampleImages.first,
      notes: _notesController.text.trim(),
      costBreakdown:
          widget.editingProduct?.costBreakdown ??
          CostBreakdown(purchase: price),
    );

    setState(() => _isSaving = true);
    try {
      if (widget.billPhoto != null) {
        await provider.saveBillPhoto(
          widget.billPhoto!,
          product: newProduct,
          documentId: _billDocumentId,
        );
      }
      if (!mounted) return;
      if (widget.editingProduct != null) {
        provider.updateProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Product updated successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
      } else {
        provider.addProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.billPhoto == null
                  ? '✨ Product & Warranty added successfully!'
                  : 'Product added and bill photo saved to your vault.',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.language == 'hi'
                ? 'बिल सेव नहीं हो सका। खाली जगह जाँचकर फिर कोशिश करें। आपकी जानकारी यहाँ सुरक्षित है।'
                : 'Could not save the bill. Check available storage and try again. Your details are still here.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.editingProduct != null;

    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            isEdit
                ? AppTranslations.tr('editProduct', lang)
                : AppTranslations.tr('addProduct', lang),
            style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: GlassScaffoldBackground(
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.billPhoto != null) ...[
                      GlassCard(
                        borderRadius: 22,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (widget.scannedBill?.fieldCount ?? 0) > 0
                                  ? (lang == 'hi'
                                        ? 'फोटो से जानकारी भर दी गई है'
                                        : 'Details filled from your photo')
                                  : (lang == 'hi'
                                        ? 'बिल की फोटो'
                                        : 'Bill reference photo'),
                              key: const ValueKey('bill-autofill-heading'),
                              style: AppTheme.font(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (widget.scannedBill?.fieldCount ?? 0) > 0
                                  ? (lang == 'hi'
                                        ? 'बिल से मिली जानकारी नीचे भरी गई है। जाँचें और बाकी जानकारी भरें। वारंटी अवधि की पुष्टि करें। सेव करने पर फोटो भी वॉल्ट में जुड़ जाएगी।'
                                        : 'Details found on the bill are filled below. Check them, complete any missing fields, and confirm the warranty period. Saving also attaches the photo to your vault.')
                                  : (lang == 'hi'
                                        ? 'फोटो देखकर जानकारी भरें। सेव करने पर फोटो भी वॉल्ट में जुड़ जाएगी।'
                                        : 'Use the bill photo to fill in the details. Saving also attaches the photo to your vault.'),
                              style: const TextStyle(fontSize: 12),
                            ),
                            ExpansionTile(
                              key: const ValueKey('bill-reference-photo'),
                              tilePadding: EdgeInsets.zero,
                              initiallyExpanded:
                                  (widget.scannedBill?.fieldCount ?? 0) == 0,
                              title: Text(
                                lang == 'hi'
                                    ? 'बिल की फोटो देखें'
                                    : 'View bill photo',
                              ),
                              children: [
                                SizedBox(
                                  height: 240,
                                  width: double.infinity,
                                  child: InteractiveViewer(
                                    child: Image.memory(
                                      widget.billPhoto!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.scannedBill?.amountIsBillTotal ==
                                true) ...[
                              const SizedBox(height: 8),
                              Text(
                                lang == 'hi'
                                    ? 'भरी गई राशि पूरे बिल का टोटल है। एक से अधिक सामान हों तो इस प्रोडक्ट की कीमत डालें।'
                                    : 'The filled amount is the whole bill total. For a bill with multiple items, enter this product’s price.',
                                key: const ValueKey('bill-total-notice'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (widget.scannedBill?.rawText.isNotEmpty == true)
                              ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: Text(
                                  lang == 'hi'
                                      ? 'बिल से पढ़ा गया टेक्स्ट देखें'
                                      : 'View text read from bill',
                                ),
                                children: [
                                  SelectableText(widget.scannedBill!.rawText),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // 1. Basic Info Glass Card
                    GlassCard(
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      opacity: 0.82,
                      blur: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Information',
                            style: AppTheme.font(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _nameController,
                            label: 'Product Title / Name *',
                            hint: 'e.g. Samsung 1.5 Ton Split AC',
                            isDark: isDark,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Product name is required'
                                : null,
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
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Brand is required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Category',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _category,
                                          isExpanded: true,
                                          items: _categories
                                              .map(
                                                (c) => DropdownMenuItem(
                                                  value: c,
                                                  child: Text(
                                                    c,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() => _category = val);
                                            }
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
                          Text(
                            'Purchase & Warranty',
                            style: AppTheme.font(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _priceController,
                                  label: 'Purchase Price (₹) *',
                                  hint: 'e.g. 42000',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  isDark: isDark,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Price is required'
                                      : (BillDetailsParser.parseAmount(
                                                  v.trim(),
                                                ) ==
                                                null
                                            ? 'Enter a valid amount, e.g. 1,250.50'
                                            : null),
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
                            children:
                                [
                                  '1 Year',
                                  '2 Years',
                                  '3 Years',
                                  '5 Years',
                                ].map((duration) {
                                  final isSelected =
                                      _warrantyPeriodController.text ==
                                      duration;
                                  return ChoiceChip(
                                    label: Text(
                                      duration,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppTheme.primary,
                                    showCheckmark: false,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.white70
                                                : Colors.black87),
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _warrantyPeriodController.text =
                                              duration;
                                          final years =
                                              int.tryParse(
                                                duration.split(' ').first,
                                              ) ??
                                              1;
                                          final parts = _purchaseDate.split(
                                            ' ',
                                          );
                                          final purchase = DateTime(
                                            int.parse(parts[2]),
                                            _monthIndex(parts[1]),
                                            int.parse(parts[0]),
                                          );
                                          final end = DateTime(
                                            purchase.year + years,
                                            purchase.month,
                                            purchase.day,
                                          );
                                          _warrantyEndDate =
                                              '${end.day} ${_monthName(end.month)} ${end.year}';
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
                                        _purchaseDate =
                                            '${picked.day} ${_monthName(picked.month)} ${picked.year}';
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
                                      initialDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                      firstDate: DateTime(2015),
                                      lastDate: DateTime(2040),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _warrantyEndDate =
                                            '${picked.day} ${_monthName(picked.month)} ${picked.year}';
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
                          Text(
                            'Photo & Extra Notes',
                            style: AppTheme.font(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Sample Images Horizontal Picker
                          const Text(
                            'Choose Product Image Preset',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                                  onTap: () => setState(
                                    () => _imageUrlController.text = img,
                                  ),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSel
                                            ? AppTheme.primary
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        img,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                          ),
                                        ),
                                      ),
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
                            hint:
                                'e.g. 5-star BEE rating, extended warranty included',
                            maxLines: 2,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton.icon(
                      key: const ValueKey('save-product'),
                      onPressed: _isSaving ? null : _handleSave,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _isSaving
                            ? 'Saving…'
                            : (isEdit ? 'Save Changes' : 'Add to MyDigi Vault'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: ValueKey('product-field-$label'),
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppTheme.textHintDark : AppTheme.textHintLight,
              fontSize: 13,
              fontFamilyFallback: AppTheme.fontFallbacks,
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
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
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  int _monthIndex(String name) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final idx = months.indexOf(name);
    return idx != -1 ? idx + 1 : 1;
  }
}
