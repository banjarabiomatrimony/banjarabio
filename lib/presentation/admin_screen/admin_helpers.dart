import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Launches the phone dialer for the given [phone] number.
Future<void> launchCaller(BuildContext context, String phone) async {
  final Uri url = Uri.parse('tel:$phone');
  try {
    if (await url_launcher.canLaunchUrl(url)) {
      await url_launcher.launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  } catch (e) {
    AppLogger.error('AdminHelpers', 'Error launching caller: $e');
  }
}

/// Launches WhatsApp for the given [phone] number.
Future<void> launchWhatsApp(BuildContext context, String phone) async {
  final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
  final Uri url = Uri.parse('https://wa.me/$cleanPhone');
  try {
    await url_launcher.launchUrl(url, mode: url_launcher.LaunchMode.externalApplication);
  } catch (e) {
    AppLogger.error('AdminHelpers', 'Error launching WhatsApp: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }
}

/// Builds a compact contact action chip (Call / WhatsApp).
/// Used across Review, Creators, Payments, and Users tabs.
Widget buildAdminContactAction({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
  required ThemeData theme,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.labelMedium,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Formats a [DateTime] as a relative time string (e.g. "2d ago").
class TimeAgo {
  static String format(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
