import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import 'invoice_vault_screen.dart';
import 'amc_screen.dart';
import 'claims_screen.dart';
import 'analytics_reports_screen.dart';
import 'login_screen.dart';

class MoreSettingsScreen extends StatelessWidget {
  const MoreSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.tr('settings', lang),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      provider.userProfile.name.isNotEmpty ? provider.userProfile.name[0] : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              provider.userProfile.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          provider.userProfile.email,
                          style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                        ),
                        Text(
                          provider.userProfile.phone,
                          style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Family Sharing Section
            Text(
              AppTranslations.tr('familySharing', lang),
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  ...provider.familyMembers.map(
                    (fam) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.accent.withAlpha(50),
                            child: Text(fam.name[0], style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fam.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                Text('${fam.relation} • ${fam.permissions}', style: TextStyle(fontSize: 10.5, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(fam.role, style: const TextStyle(color: AppTheme.primary, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 12),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invite link copied to clipboard!')),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person_add_alt, size: 16, color: AppTheme.primary),
                          SizedBox(width: 6),
                          Text(
                            'Invite Family Member',
                            style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // App Modules & Features
            Text(
              'Features & Vaults',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _buildSettingsTile(
              icon: Icons.folder_shared_outlined,
              color: AppTheme.secondary,
              title: AppTranslations.tr('vault', lang),
              subtitle: 'Encrypted invoices, receipts & manuals',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceVaultScreen())),
              isDark: isDark,
            ),
            _buildSettingsTile(
              icon: Icons.shield_outlined,
              color: AppTheme.accent,
              title: AppTranslations.tr('amc', lang),
              subtitle: 'Annual maintenance contracts & insurance',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AMCScreen())),
              isDark: isDark,
            ),
            _buildSettingsTile(
              icon: Icons.assignment_late_outlined,
              color: const Color(0xFFEC4899),
              title: AppTranslations.tr('claims', lang),
              subtitle: 'Warranty claims & service tracking',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimsScreen())),
              isDark: isDark,
            ),
            _buildSettingsTile(
              icon: Icons.insights_rounded,
              color: AppTheme.primary,
              title: AppTranslations.tr('reports', lang),
              subtitle: 'Asset valuation & financial TCO',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsReportsScreen())),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Preferences
            Text(
              'Preferences',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        AppTranslations.tr('language', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: lang,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('🇬🇧 English', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'hi', child: Text('🇮🇳 हिंदी', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.setLanguage(val);
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: AppTheme.warning, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        isDark ? AppTranslations.tr('darkMode', lang) : AppTranslations.tr('lightMode', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  Switch(
                    value: provider.isDarkMode,
                    activeTrackColor: AppTheme.primary,
                    onChanged: (_) => provider.toggleTheme(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sign Out Button
            OutlinedButton.icon(
              onPressed: () {
                provider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, color: AppTheme.danger, size: 18),
              label: Text(
                AppTranslations.tr('logout', lang),
                style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: AppTheme.danger.withAlpha(80)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'MyDigi Mobile v1.0.0 (Pure Flutter & Dart)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Crafted for iOS & Android with Material 3',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ),
      ),
    );
  }
}
