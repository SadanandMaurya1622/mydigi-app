import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/warranty_provider.dart';
import '../utils/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/glass_container.dart';
import 'product_detail_screen.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WarrantyProvider>(context);
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 28,
      padding: EdgeInsets.zero,
      opacity: 0.94,
      blur: 28,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        AppTranslations.tr('notifications', lang),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      if (provider.unreadNotificationsCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.danger,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${provider.unreadNotificationsCount} New',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Notifications List
            Expanded(
              child: provider.notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: provider.notifications.length,
                      itemBuilder: (context, index) {
                        final notif = provider.notifications[index];
                        final isUnread = notif.unread;

                        Color typeColor = AppTheme.primary;
                        IconData typeIcon = Icons.info_outline;
                        if (notif.type == 'critical') {
                          typeColor = AppTheme.danger;
                          typeIcon = Icons.error_outline;
                        } else if (notif.type == 'warning') {
                          typeColor = AppTheme.warning;
                          typeIcon = Icons.warning_amber_rounded;
                        } else if (notif.type == 'success') {
                          typeColor = AppTheme.success;
                          typeIcon = Icons.check_circle_outline;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isUnread
                                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF))
                                : (isDark ? const Color(0xFF0F172A).withAlpha(120) : Colors.white.withAlpha(160)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isUnread ? typeColor.withAlpha(80) : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              provider.markNotificationAsRead(notif.id);
                              if (notif.productId != null) {
                                final product = provider.products.firstWhere(
                                  (p) => p.id == notif.productId,
                                  orElse: () => provider.products.first,
                                );
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(product: product),
                                  ),
                                );
                              }
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: typeColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(typeIcon, color: typeColor, size: 20),
                            ),
                            title: Text(
                              notif.title,
                              style: TextStyle(
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  notif.message,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.date,
                                  style: const TextStyle(fontSize: 9.5, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: isUnread
                                ? Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
