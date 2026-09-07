import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';

class AnalyticsReportsScreen extends StatelessWidget {
  const AnalyticsReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalAssets = provider.totalAssetValue;
    final totalExpenses = provider.totalExpenseValue;

    // Category breakdown
    final Map<String, double> categoryValues = {};
    for (var p in provider.products) {
      categoryValues[p.category] = (categoryValues[p.category] ?? 0.0) + p.purchasePrice;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppTranslations.tr('reports', lang),
          style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting Financial Report (PDF/Excel)...')),
              );
            },
          ),
        ],
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Net Worth / Total Asset Valuation Glass Banner
                GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(18),
                  tintColor: const Color(0xFF4F46E5),
                  isSolidGradient: true,
                  opacity: 0.88,
                  blur: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Insured Asset Valuation', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '₹${totalAssets.toInt()}',
                        style: AppTheme.font(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniStat('Maintenance & TCO', '₹${totalExpenses.toInt()}', Colors.white),
                          _buildMiniStat('Protected Products', '${provider.products.length} Units', Colors.white),
                          _buildMiniStat('Active Warranties', '${provider.activeCount}', AppTheme.success),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category Valuation Breakdown
                Text(
                  'Category Asset Distribution',
                  style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  opacity: 0.82,
                  blur: 24,
                  child: Column(
                    children: categoryValues.entries.map((entry) {
                      final percent = totalAssets > 0 ? (entry.value / totalAssets) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                Text('₹${entry.value.toInt()} (${(percent * 100).toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: percent,
                                minHeight: 8,
                                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Warranty Health Status Distribution
                Text(
                  'Warranty Lifecycle Health',
                  style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildHealthCard('Active', '${provider.activeCount}', AppTheme.success, isDark),
                    const SizedBox(width: 10),
                    _buildHealthCard('Expiring Soon', '${provider.expiringSoonCount}', AppTheme.warning, isDark),
                    const SizedBox(width: 10),
                    _buildHealthCard('Expired', '${provider.expiredCount}', AppTheme.danger, isDark),
                  ],
                ),
                const SizedBox(height: 20),

                // Download Report Button
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✨ Report generated: MyDigi_TCO_Summary_2026.pdf'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Full TCO Audit Report (PDF)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: col)),
      ],
    );
  }

  Widget _buildHealthCard(String title, String count, Color col, bool isDark) {
    return Expanded(
      child: GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        opacity: 0.82,
        tintColor: col,
        child: Column(
          children: [
            Text(
              count,
              style: AppTheme.font(fontSize: 22, fontWeight: FontWeight.w900, color: col),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
