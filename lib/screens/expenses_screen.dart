import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';
import 'add_product_screen.dart';

class ExpensesScreen extends StatefulWidget {
  final String? filterProductId;

  const ExpensesScreen({super.key, this.filterProductId});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Maintenance',
    'Service',
    'AMC',
    'Repair',
    'Accessories',
    'Other',
  ];

  void _showAddExpenseModal(BuildContext context, WarrantyProvider provider, String lang, bool isDark) {
    if (provider.products.isEmpty) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => SafeArea(
          child: GlassCard(
            borderRadius: 28,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.primary),
                const SizedBox(height: 14),
                Text(
                  lang == 'hi' ? 'पहले एक प्रोडक्ट जोड़ें' : 'Add a Product First',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  lang == 'hi'
                      ? 'खर्चा किसी प्रोडक्ट (जैसे AC, टीवी, फ्रिज) से जुड़ा होता है। कृपया पहले एक प्रोडक्ट जोड़ें।'
                      : 'Expenses are linked to products (AC, TV, Vehicle, etc.). Please add a product first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(lang == 'hi' ? '+ नया प्रोडक्ट जोड़ें' : '+ Add New Product', style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    final validProductIds = provider.products.map((p) => p.id).toSet();
    String selectedProdId = (widget.filterProductId != null && validProductIds.contains(widget.filterProductId))
        ? widget.filterProductId!
        : provider.products.first.id;
    String selectedCat = 'Maintenance';
    final amountController = TextEditingController();
    final providerController = TextEditingController(text: 'Authorized Service Center');
    final notesController = TextEditingController();
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => SafeArea(
          child: GlassCard(
            borderRadius: 28,
            opacity: 0.92,
            blur: 28,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
            ),
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lang == 'hi' ? 'नया खर्चा जोड़ें' : 'Log New Expense', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(modalCtx)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product Picker Dropdown
                  Text(lang == 'hi' ? 'प्रोडक्ट चुनें' : 'Select Product', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedProdId,
                        isExpanded: true,
                        items: provider.products
                            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedProdId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Amount & Date Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang == 'hi' ? 'राशि (₹) *' : 'Amount (₹) *', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'e.g. 1500',
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang == 'hi' ? 'खर्च का प्रकार' : 'Expense Type', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedCat,
                                  isExpanded: true,
                                  items: ['Maintenance', 'Service', 'AMC', 'Repair', 'Accessories', 'Other']
                                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => selectedCat = val);
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

                  // Service Provider
                  Text(lang == 'hi' ? 'सर्विस सेंटर / मैकेनिक' : 'Service Provider / Store', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: providerController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Urban Company, Local Technician',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Notes
                  Text(lang == 'hi' ? 'विवरण (Notes)' : 'Notes / Description', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Routine servicing & filter replacement',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Action Button
                  ElevatedButton(
                    onPressed: () {
                      final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                      if (amt <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(lang == 'hi' ? 'कृपया सही राशि दर्ज करें' : 'Please enter a valid amount')),
                        );
                        return;
                      }

                      final targetProduct = provider.products.firstWhere(
                        (p) => p.id == selectedProdId,
                        orElse: () => provider.products.first,
                      );

                      provider.addExpense(ExpenseRecord(
                        id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
                        productId: selectedProdId,
                        productName: targetProduct.name,
                        category: selectedCat,
                        amount: amt,
                        date: dateStr,
                        serviceProvider: providerController.text.trim().isNotEmpty ? providerController.text.trim() : 'Service Center',
                        notes: notesController.text.trim(),
                      ));

                      Navigator.pop(modalCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang == 'hi' ? '✅ खर्चा सफलतापूर्वक दर्ज हुआ!' : '✅ Expense logged successfully!'), backgroundColor: AppTheme.success),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(lang == 'hi' ? 'खर्चा सेव करें' : 'Save Expense Log', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var filteredExpenses = provider.expenses;
    if (widget.filterProductId != null) {
      filteredExpenses = filteredExpenses.where((e) => e.productId == widget.filterProductId).toList();
    }
    if (_selectedCategory != 'All') {
      filteredExpenses = filteredExpenses.where((e) => e.category == _selectedCategory).toList();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppTranslations.tr('expenses', lang),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              // KPI Glass Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  tintColor: const Color(0xFF6366F1),
                  opacity: 0.88,
                  blur: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Ownership Expense',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${provider.totalExpenseValue.toInt()}',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${provider.expenses.length} Total Logs',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Glass Chips
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _categories.length,
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: GlassCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          opacity: isSel ? 0.9 : 0.6,
                          tintColor: isSel ? AppTheme.primary : null,
                          border: Border.all(
                            color: isSel ? AppTheme.primary : Colors.white.withAlpha(isDark ? 20 : 180),
                            width: 1.2,
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? Colors.white : (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Expenses List
              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Text(
                          lang == 'en' ? 'No expense logs found' : 'कोई खर्च रिकॉर्ड नहीं मिला',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 100),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, idx) {
                          final exp = filteredExpenses[idx];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            borderRadius: 20,
                            padding: const EdgeInsets.all(14),
                            opacity: 0.82,
                            blur: 20,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.receipt_long, color: AppTheme.primary, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              exp.productName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '₹${exp.amount.toInt()}',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              color: AppTheme.danger,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${exp.category} • ${exp.serviceProvider}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        ),
                                      ),
                                      if (exp.notes != null && exp.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          exp.notes!,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontStyle: FontStyle.italic,
                                            color: isDark ? Colors.white60 : Colors.black54,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        exp.date,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_expenses',
        onPressed: () => _showAddExpenseModal(context, provider, lang, isDark),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          AppTranslations.tr('addExpense', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
