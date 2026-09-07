import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import 'add_product_screen.dart';

class ExpensesScreen extends StatefulWidget {
  final String? filterProductId;

  const ExpensesScreen({super.key, this.filterProductId});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'hi': 'सभी खर्च', 'icon': Icons.all_inclusive_rounded},
    {'name': 'Service', 'hi': 'सर्विसिंग', 'icon': Icons.cleaning_services_rounded},
    {'name': 'Repair', 'hi': 'मरम्मत (Repair)', 'icon': Icons.handyman_rounded},
    {'name': 'Maintenance', 'hi': 'मेंटेनेंस', 'icon': Icons.build_rounded},
    {'name': 'AMC', 'hi': 'एएमसी (AMC)', 'icon': Icons.verified_rounded},
    {'name': 'Other', 'hi': 'अन्य', 'icon': Icons.receipt_long_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDeleteExpense(BuildContext context, WarrantyProvider provider, ExpenseRecord expense, bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isHindi ? 'खर्च हटाएं?' : 'Delete Expense?',
          style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          isHindi
              ? 'क्या आप वास्तव में ₹${expense.amount.toInt()} का "${expense.productName}" खर्च रिकॉर्ड हटाना चाहते हैं?'
              : 'Are you sure you want to delete this ₹${expense.amount.toInt()} record for "${expense.productName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              provider.deleteExpense(expense.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isHindi ? 'खर्च हटा दिया गया' : 'Expense deleted'),
                  backgroundColor: AppTheme.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(isHindi ? 'हटाएं' : 'Delete', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context, WarrantyProvider provider, bool isHindi, bool isDark) {
    if (provider.products.isEmpty) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.primary),
                const SizedBox(height: 12),
                Text(
                  isHindi ? 'पहले एक सामान जोड़ें' : 'Add an Item First',
                  style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  isHindi
                      ? 'खर्च किसी सामान (जैसे AC, टीवी, फ्रिज) से जुड़ा होता है। कृपया पहले अपना सामान जोड़ें।'
                      : 'Expenses are linked to your items. Please add an item first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isHindi ? '+ नया सामान जोड़ें' : '+ Add Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    String selectedProdId = provider.products.first.id;
    String selectedCat = 'Service';
    final amountController = TextEditingController();
    final providerController = TextEditingController(text: 'Service Center');
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
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHindi ? 'नया खर्च जोड़ें' : 'Log New Expense',
                        style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Pick Product
                  Text(isHindi ? 'सामान चुनें' : 'Select Item', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                            .map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text('${p.name} (${p.brand})', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedProdId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Amount
                  Text(isHindi ? 'खर्च राशि (₹) *' : 'Amount (₹) *', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      hintText: '1500',
                      hintStyle: TextStyle(color: isDark ? AppTheme.textHintDark : AppTheme.textHintLight),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quick add chips
                  Row(
                    children: [500, 1000, 2000, 5000].map((amt) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            final cur = double.tryParse(amountController.text) ?? 0;
                            amountController.text = (cur + amt).toInt().toString();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            ),
                            child: Text('+₹$amt', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Category & Provider
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isHindi ? 'खर्च का प्रकार' : 'Expense Type', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedCat,
                                  isExpanded: true,
                                  items: ['Service', 'Repair', 'Maintenance', 'AMC', 'Other']
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isHindi ? 'दुकान / सर्विस सेंटर' : 'Center / Store', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: providerController,
                              decoration: InputDecoration(
                                hintText: 'Urban Company',
                                hintStyle: TextStyle(fontSize: 12, color: isDark ? AppTheme.textHintDark : AppTheme.textHintLight),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Notes
                  Text(isHindi ? 'विवरण (Notes)' : 'Notes / Remarks', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      hintText: isHindi ? 'उदा. फ़िल्टर बदला, गैस भरी' : 'e.g. Filter change, servicing',
                      hintStyle: TextStyle(fontSize: 12.5, color: isDark ? AppTheme.textHintDark : AppTheme.textHintLight),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                      if (amt <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isHindi ? 'कृपया सही राशि दर्ज करें' : 'Please enter valid amount')),
                        );
                        return;
                      }

                      final targetProduct = provider.products.firstWhere(
                        (p) => p.id == selectedProdId,
                        orElse: () => provider.products.first,
                      );

                      HapticFeedback.mediumImpact();
                      provider.addExpense(ExpenseRecord(
                        id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
                        productId: selectedProdId,
                        productName: targetProduct.name,
                        category: selectedCat,
                        amount: amt,
                        date: dateStr,
                        serviceProvider: providerController.text.trim().isNotEmpty
                            ? providerController.text.trim()
                            : 'Service Center',
                        notes: notesController.text.trim(),
                      ));

                      Navigator.pop(modalCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isHindi ? 'खर्च सेव हो गया!' : 'Expense saved successfully!'),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isHindi ? 'खर्च सेव करें' : 'Save Expense', style: const TextStyle(fontWeight: FontWeight.bold)),
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
    final isHindi = lang == 'hi';

    final allExpenses = provider.expenses;
    final totalSpent = allExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

    final filtered = allExpenses.where((e) {
      final matchesQuery = _searchQuery.isEmpty ||
          e.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.serviceProvider.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' || e.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isHindi ? 'खर्चों का हिसाब' : 'Service Expenses',
              style: AppTheme.font(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              '${allExpenses.length} ${isHindi ? 'खर्च रिकॉर्ड' : 'records logged'}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            ),
            tooltip: isHindi ? 'खर्च जोड़ें' : 'Add Expense',
            onPressed: () => _showAddExpenseModal(context, provider, isHindi, isDark),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. SIMPLE EXPENSE SUMMARY CARD
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withAlpha(70),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'कुल सर्विस व रिपेयरिंग खर्च' : 'Total Service & Repair Expense',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${totalSpent.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: AppTheme.font(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddExpenseModal(context, provider, isHindi, isDark),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: Text(
                            isHindi ? '+ नया खर्च दर्ज करें' : '+ Log New Expense',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6366F1),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontFamilyFallback: AppTheme.fontFallbacks,
                    ),
                    decoration: InputDecoration(
                      hintText: isHindi ? 'सामान या सर्विस सेंटर का नाम खोजें...' : 'Search item or service center...',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppTheme.textHintDark : AppTheme.textHintLight,
                        fontFamilyFallback: AppTheme.fontFallbacks,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // 3. CATEGORY HORIZONTAL CHIPS
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _categories.length,
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final catName = cat['name'] as String;
                    final isSel = _selectedCategory == catName;
                    final label = isHindi ? cat['hi'] as String : catName;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = catName);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFF6366F1)
                                : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                              color: isSel ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
                              fontFamilyFallback: AppTheme.fontFallbacks,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // 4. EXPENSE TRANSACTION LIST
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          isHindi ? 'कोई खर्च रिकॉर्ड नहीं मिला' : 'No expense records found',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 90),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final exp = filtered[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withAlpha(20),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF6366F1), size: 20),
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
                                              style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 14),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '-₹${exp.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                            style: AppTheme.font(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              color: const Color(0xFFE11D48),
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
                                        const SizedBox(height: 3),
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            exp.date,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _confirmDeleteExpense(context, provider, exp, isHindi),
                                            child: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                                          ),
                                        ],
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
    );
  }
}
