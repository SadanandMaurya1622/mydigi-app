import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class MoreSettingsScreen extends StatefulWidget {
  const MoreSettingsScreen({super.key});

  @override
  State<MoreSettingsScreen> createState() => _MoreSettingsScreenState();
}

class _MoreSettingsScreenState extends State<MoreSettingsScreen> {
  bool _alertsEnabled = true;

  void _showSignOutDialog(BuildContext context, WarrantyProvider provider, bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isHindi ? 'लॉग आउट करना चाहते हैं?' : 'Sign Out Confirmation',
          style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          isHindi
              ? 'क्या आप वास्तव में MyDigi से लॉग आउट करना चाहते हैं? आपका डेटा Google Cloud पर सुरक्षित रहेगा।'
              : 'Are you sure you want to sign out? Your bills and items remain safe in the cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isHindi ? 'लॉग आउट' : 'Sign Out', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showHelpModal(BuildContext context, bool isHindi, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
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
              const SizedBox(height: 16),
              Text(
                isHindi ? 'मदद और सहायता' : 'Help & Customer Support',
                style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981), size: 22),
                ),
                title: const Text('WhatsApp Helpline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('+91 89319 21145 • Instant Support', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('💬 Opening WhatsApp support...'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.email_outlined, color: AppTheme.primary, size: 22),
                ),
                title: const Text('Email Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('support@mydigiapp.com', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📧 Opening email client...'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isHindi ? 'सेटिंग्स व मेनू' : 'More & Settings',
          style: AppTheme.font(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: GlassScaffoldBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SIMPLE PROFILE CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 25 : 6),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondary],
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
                                  provider.userProfile.name.isNotEmpty ? provider.userProfile.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.userProfile.name.isNotEmpty ? provider.userProfile.name : 'MyDigi User',
                              style: AppTheme.font(fontWeight: FontWeight.w800, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              provider.userProfile.email.isNotEmpty ? provider.userProfile.email : 'Google Account',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. MAIN SERVICES (CLEAR & EASY TO TAP)
                Text(
                  isHindi ? 'मुख्य सेवाएं' : 'Key Services',
                  style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),

                _buildGroupedCard(
                  isDark: isDark,
                  children: [
                    _buildSettingsTile(
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFF38BDF8),
                      title: isHindi ? 'बिल और इनवॉइस वॉल्ट' : 'Invoices & Documents',
                      subtitle: isHindi ? 'सभी सेव किए गए बिल व पर्चियां' : 'View all stored bills & receipts',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceVaultScreen())),
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      icon: Icons.assignment_turned_in_rounded,
                      iconColor: const Color(0xFFEC4899),
                      title: isHindi ? 'वारंटी क्लेम' : 'Warranty Claims',
                      subtitle: isHindi ? 'कंपनी सर्विस व क्लेम रिक्वेस्ट' : 'Track repair and claim requests',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimsScreen())),
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      icon: Icons.support_agent_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: isHindi ? 'AMC और मेंटेनेंस' : 'AMC & Helplines',
                      subtitle: isHindi ? 'वार्षिक सर्विस कॉन्ट्रैक्ट' : 'Annual maintenance & care',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AMCScreen())),
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      icon: Icons.pie_chart_outline_rounded,
                      iconColor: const Color(0xFF6366F1),
                      title: isHindi ? 'खर्च रिपोर्ट व विश्लेषण' : 'Expense Analytics',
                      subtitle: isHindi ? 'खर्चों का पूरा ब्यौरा' : 'Maintenance spending breakdown',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsReportsScreen())),
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 3. APP SETTINGS
                Text(
                  isHindi ? 'ऐप सेटिंग्स' : 'App Settings',
                  style: AppTheme.font(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),

                _buildGroupedCard(
                  isDark: isDark,
                  children: [
                    // Dark Mode Switch
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: const Color(0xFF8B5CF6),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        isHindi ? 'डार्क थीम (Dark Mode)' : 'Dark Theme',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        isDark ? (isHindi ? 'डार्क मोड चालू है' : 'Dark mode is on') : (isHindi ? 'लाइट मोड चालू है' : 'Light mode is on'),
                        style: TextStyle(fontSize: 11.5, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                      ),
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeTrackColor: AppTheme.primary,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          provider.toggleTheme();
                        },
                      ),
                    ),
                    _buildDivider(isDark),

                    // Language Selector
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.language_rounded, color: Color(0xFF3B82F6), size: 20),
                      ),
                      title: Text(
                        isHindi ? 'भाषा (Language)' : 'App Language',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        isHindi ? 'हिंदी चुनी हुई है' : 'English selected',
                        style: TextStyle(fontSize: 11.5, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          ),
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
                            if (val != null) {
                              HapticFeedback.selectionClick();
                              provider.setLanguage(val);
                            }
                          },
                        ),
                      ),
                    ),
                    _buildDivider(isDark),

                    // Push Notification Switch
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFF59E0B), size: 20),
                      ),
                      title: Text(
                        isHindi ? 'वारंटी रिमाइंडर' : 'Expiry Reminders',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        isHindi ? 'वारंटी खत्म होने से पहले सूचना' : 'Get alerts before warranty ends',
                        style: TextStyle(fontSize: 11.5, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                      ),
                      trailing: Switch.adaptive(
                        value: _alertsEnabled,
                        activeTrackColor: AppTheme.primary,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          setState(() => _alertsEnabled = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 4. HELP & SUPPORT
                _buildGroupedCard(
                  isDark: isDark,
                  children: [
                    _buildSettingsTile(
                      icon: Icons.headset_mic_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: isHindi ? 'मदद और कस्टमर सपोर्ट' : 'Help & Customer Support',
                      subtitle: isHindi ? 'व्हाट्सएप व ईमेल द्वारा संपर्क करें' : 'Contact WhatsApp helpline or email',
                      onTap: () => _showHelpModal(context, isHindi, isDark),
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 5. SIGN OUT BUTTON
                GestureDetector(
                  onTap: () => _showSignOutDialog(context, provider, isHindi),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withAlpha(isDark ? 25 : 15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE11D48).withAlpha(isDark ? 60 : 40),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE11D48)),
                        const SizedBox(width: 8),
                        Text(
                          isHindi ? 'लॉग आउट करें (Sign Out)' : 'Sign Out',
                          style: AppTheme.font(
                            color: const Color(0xFFE11D48),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 6. SIMPLE FOOTER
                Center(
                  child: Text(
                    'MyDigi App v1.0.0 • सुरक्षित एवं सरल',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedCard({required List<Widget> children, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 54,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11.5, color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
