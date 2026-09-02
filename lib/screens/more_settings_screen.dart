import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/warranty_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
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
    final isHindi = lang == 'hi';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isHindi ? 'सेटिंग्स व फीचर्स' : 'Settings & Services',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Sleek Frosted Glass Google Account Profile Card
                GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(16),
                  opacity: 0.84,
                  blur: 24,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.accent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              image: provider.userProfile.photoUrl != null && provider.userProfile.photoUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(provider.userProfile.photoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: provider.userProfile.photoUrl == null || provider.userProfile.photoUrl!.isEmpty
                                ? Center(
                                    child: Text(
                                      provider.userProfile.name.isNotEmpty ? provider.userProfile.name[0] : 'S',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),

                          // Name & Google Badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        provider.userProfile.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.success.withAlpha(30),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle, size: 10, color: AppTheme.success),
                                          SizedBox(width: 3),
                                          Text(
                                            'Google',
                                            style: TextStyle(
                                              color: AppTheme.success,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  provider.userProfile.email,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(
                        height: 1,
                        thickness: 0.8,
                        color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
                      ),
                      const SizedBox(height: 12),

                      // Account Quick Stats Strip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildProfileStat(
                            label: isHindi ? 'कुल प्रोडक्ट्स' : 'Products',
                            value: '${provider.products.length}',
                            color: AppTheme.primary,
                          ),
                          Container(width: 1, height: 24, color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15)),
                          _buildProfileStat(
                            label: isHindi ? 'कुल मूल्य' : 'Total Value',
                            value: '₹${(provider.totalAssetValue / 100000).toStringAsFixed(1)}L',
                            color: const Color(0xFF10B981),
                          ),
                          Container(width: 1, height: 24, color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15)),
                          _buildProfileStat(
                            label: isHindi ? 'सक्रिय वारंटी' : 'Active Safe',
                            value: '${provider.activeCount}',
                            color: const Color(0xFF6366F1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Core Services & Vault (Glassy Grouped Card)
                Text(
                  isHindi ? 'मुख्य सेवाएं (Key Services)' : 'Core Services',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),

                GlassCard(
                  borderRadius: 22,
                  padding: EdgeInsets.zero,
                  opacity: 0.82,
                  blur: 24,
                  child: Column(
                    children: [
                      _buildGroupedTile(
                        icon: Icons.folder_shared_rounded,
                        iconColor: const Color(0xFF38BDF8),
                        title: isHindi ? 'दस्तावेज़ वॉल्ट (Document Vault)' : 'Document Vault',
                        subtitle: isHindi ? 'सभी इनवॉइस और वारंटी रसीदें' : 'Encrypted invoices & warranty receipts',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceVaultScreen())),
                        isDark: isDark,
                        isFirst: true,
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10)),
                      _buildGroupedTile(
                        icon: Icons.shield_rounded,
                        iconColor: const Color(0xFFEC4899),
                        title: isHindi ? 'वारंटी क्लेम ट्रैकर (Claims)' : 'Claims Tracker',
                        subtitle: isHindi ? 'कंपनी सर्विस व क्लेम रिक्वेस्ट' : 'Warranty claims & service requests',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimsScreen())),
                        isDark: isDark,
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10)),
                      _buildGroupedTile(
                        icon: Icons.support_agent_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        title: isHindi ? 'AMC व बीमा (AMC & Care)' : 'AMC & Insurance',
                        subtitle: isHindi ? 'वार्षिक मेंटेनेंस व हेल्पलाइन्स' : 'Annual maintenance contracts & helplines',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AMCScreen())),
                        isDark: isDark,
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10)),
                      _buildGroupedTile(
                        icon: Icons.insights_rounded,
                        iconColor: const Color(0xFF6366F1),
                        title: isHindi ? 'TCO व फाइनेंशियल रिपोर्ट' : 'Reports & TCO Analytics',
                        subtitle: isHindi ? 'खर्चों का पूरा ब्यौरा व विश्लेषण' : 'Total cost of ownership & expense breakdown',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsReportsScreen())),
                        isDark: isDark,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. App Preferences (Glassy Grouped Card)
                Text(
                  isHindi ? 'पसंद और सेटिंग्स (Preferences)' : 'Preferences',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),

                GlassCard(
                  borderRadius: 22,
                  padding: EdgeInsets.zero,
                  opacity: 0.82,
                  blur: 24,
                  child: Column(
                    children: [
                      // Language Switcher Tile
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.language_rounded, color: Color(0xFF3B82F6), size: 20),
                        ),
                        title: Text(
                          isHindi ? 'भाषा (Language)' : 'App Language',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          isHindi ? 'हिंदी में सक्रिय' : 'English active',
                          style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<String>(
                            value: lang,
                            underline: const SizedBox.shrink(),
                            isDense: true,
                            icon: const Icon(Icons.arrow_drop_down, size: 18),
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('🇬🇧 English', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'hi', child: Text('🇮🇳 हिंदी', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                            ],
                            onChanged: (val) {
                              if (val != null) provider.setLanguage(val);
                            },
                          ),
                        ),
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10)),

                      // Notifications Alert Tile
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFF59E0B), size: 20),
                        ),
                        title: Text(
                          isHindi ? 'वारंटी अलर्ट्स' : 'Warranty Alerts',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          isHindi ? 'समय पर रिमाइंडर प्राप्त करें' : '30-day & 7-day expiry alerts',
                          style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                        ),
                        trailing: Switch.adaptive(
                          value: true,
                          activeTrackColor: AppTheme.primary,
                          onChanged: (val) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isHindi ? 'अलर्ट्स अपडेट हो गए' : 'Alert preferences updated')),
                            );
                          },
                        ),
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10)),

                      // Cloud Sync Status Tile
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF10B981), size: 20),
                        ),
                        title: Text(
                          isHindi ? 'क्लाउड बैकअप' : 'Cloud Backup',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          isHindi ? 'Google Cloud से सिंक है' : 'Synced with Google Cloud',
                          style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                        ),
                        trailing: const Icon(Icons.check_circle, size: 18, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Glassy Sign Out Button
                GlassCard(
                  borderRadius: 20,
                  padding: EdgeInsets.zero,
                  opacity: 0.85,
                  tintColor: const Color(0xFFE11D48),
                  onTap: () => _showSignOutDialog(context, provider, isHindi),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE11D48)),
                        const SizedBox(width: 8),
                        Text(
                          isHindi ? 'लॉग आउट (Sign Out)' : 'Sign Out',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFE11D48),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Minimal App Version Tag
                Center(
                  child: Column(
                    children: [
                      Text(
                        'MyDigi v1.0.0 • Pure Flutter & Dart',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '256-Bit End-to-End Encrypted Cloud Storage',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ),
                    ],
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

  Widget _buildProfileStat({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildGroupedTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(22) : Radius.zero,
          bottom: isLast ? const Radius.circular(22) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WarrantyProvider provider, bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isHindi ? 'लॉग आउट करना चाहते हैं?' : 'Sign Out Confirmation',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          isHindi
              ? 'क्या आप MyDigi से लॉग आउट करना चाहते हैं? आपका डेटा Google Cloud पर सुरक्षित रहेगा।'
              : 'Are you sure you want to sign out? Your bills and warranties remain safe in cloud.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().signOut();
              provider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isHindi ? 'लॉग आउट' : 'Sign Out'),
          ),
        ],
      ),
    );
  }
}
