import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';

class AMCScreen extends StatefulWidget {
  const AMCScreen({super.key});

  @override
  State<AMCScreen> createState() => _AMCScreenState();
}

class _AMCScreenState extends State<AMCScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppTranslations.tr('amc', lang),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
          tabs: const [
            Tab(text: 'AMC Contracts'),
            Tab(text: 'Insurance Policies'),
          ],
        ),
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: AMC Records
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  ...provider.amcRecords.map((amc) => _buildAMCCard(amc, isDark, lang)),
                  const SizedBox(height: 100),
                ],
              ),

              // Tab 2: Insurance Policies
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  ...provider.insurancePolicies.map((ins) => _buildInsuranceCard(ins, isDark, lang)),
                  const SizedBox(height: 100),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAMCCard(AMCRecord amc, bool isDark, String lang) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      opacity: 0.82,
      blur: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amc.productName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: amc.status == 'Active' ? AppTheme.success.withAlpha(30) : AppTheme.warning.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  amc.status,
                  style: TextStyle(
                    color: amc.status == 'Active' ? AppTheme.success : AppTheme.warning,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${amc.planName} • ${amc.provider}',
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withAlpha(150) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Valid Until', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(amc.endDate, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Free Services Left', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('${amc.freeServicesRemaining} visits left', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.success)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Annual Fee', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('₹${amc.cost.toInt()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Helpline: ${amc.contactNumber}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Dialing ${amc.contactNumber}...')),
                  );
                },
                icon: const Icon(Icons.phone, size: 14),
                label: const Text('Call Support', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard(InsurancePolicy ins, bool isDark, String lang) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      opacity: 0.82,
      blur: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ins.productName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ins.status,
                  style: const TextStyle(
                    color: AppTheme.success,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${ins.provider} • Policy #${ins.policyNumber}',
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withAlpha(150) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sum Insured', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('₹${ins.coverageAmount.toInt()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Valid Until', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(ins.expiryDate, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Premium Paid', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('₹${ins.premiumAmount.toInt()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Provider: ${ins.provider}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contacting ${ins.provider} Claims Desk...')),
                  );
                },
                icon: const Icon(Icons.support_agent, size: 14),
                label: const Text('File Claim', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
