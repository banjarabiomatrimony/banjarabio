import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// 📊 CSV EXPORT SERVICE
/// Converts domain models (Users, Payments) to CSV strings and triggers native file sharing.
class CsvExportService {
  /// Sanitize cell values for CSV compatibility (handle commas, quotes, newlines)
  static String _escapeCsv(dynamic value) {
    if (value == null) return '""';
    final str = value.toString().replaceAll('"', '""');
    return '"$str"';
  }

  /// Exports a list of user profiles to CSV and opens the native Share dialog.
  static Future<bool> exportUsersToCsv(
    BuildContext context,
    List<ProfileModel> profiles, {
    String filenamePrefix = 'banjarabio_users',
  }) async {
    try {
      if (profiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user profiles to export.')),
        );
        return false;
      }

      final StringBuffer csvBuffer = StringBuffer();
      // CSV Header
      csvBuffer.writeln(
        'ID,Full Name,Surname,Gender,Age,State,District,Taluka,Phone,Email,Is Verified,Is Premium,Created At',
      );

      // CSV Rows
      for (final p in profiles) {
        csvBuffer.writeln([
          _escapeCsv(p.id),
          _escapeCsv(p.fullName),
          _escapeCsv(p.surname),
          _escapeCsv(p.gender),
          _escapeCsv(p.age),
          _escapeCsv(p.state),
          _escapeCsv(p.district),
          _escapeCsv(p.taluka),
          _escapeCsv(p.phoneNumber),
          _escapeCsv(p.email),
          _escapeCsv(p.isVerified),
          _escapeCsv(p.isPremium),
          _escapeCsv(p.createdAt.toIso8601String()),
        ].join(','));
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/${filenamePrefix}_$timestamp.csv');

      await file.writeAsString(csvBuffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'BanjaraBio User Export',
        text: 'Exported ${profiles.length} user profiles.',
      );

      AppLogger.info('CsvExportService', 'Exported ${profiles.length} users to CSV: ${file.path}');
      return true;
    } catch (e) {
      AppLogger.error('CsvExportService', 'Failed to export users to CSV: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
      return false;
    }
  }

  /// Exports a list of payment records to CSV and opens the native Share dialog.
  static Future<bool> exportPaymentsToCsv(
    BuildContext context,
    List<Map<String, dynamic>> payments, {
    String filenamePrefix = 'banjarabio_payments',
  }) async {
    try {
      if (payments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No payment records to export.')),
        );
        return false;
      }

      final StringBuffer csvBuffer = StringBuffer();
      // CSV Header
      csvBuffer.writeln(
        'Payment ID,User ID,Amount,Currency,Status,Payment Method,Razorpay Order ID,Created At',
      );

      // CSV Rows
      for (final pay in payments) {
        csvBuffer.writeln([
          _escapeCsv(pay['id'] ?? pay['payment_id']),
          _escapeCsv(pay['user_id'] ?? pay['profile_id']),
          _escapeCsv(pay['amount']),
          _escapeCsv(pay['currency'] ?? 'INR'),
          _escapeCsv(pay['status']),
          _escapeCsv(pay['method'] ?? pay['payment_method']),
          _escapeCsv(pay['razorpay_order_id'] ?? pay['order_id']),
          _escapeCsv(pay['created_at']),
        ].join(','));
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/${filenamePrefix}_$timestamp.csv');

      await file.writeAsString(csvBuffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'BanjaraBio Payment Export',
        text: 'Exported ${payments.length} payment records.',
      );

      AppLogger.info('CsvExportService', 'Exported ${payments.length} payments to CSV: ${file.path}');
      return true;
    } catch (e) {
      AppLogger.error('CsvExportService', 'Failed to export payments to CSV: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
      return false;
    }
  }
}
