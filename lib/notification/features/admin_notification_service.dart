import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Admin Notification Service
///
/// Sends real-time push notifications to all admin devices when critical
/// user/data-level events occur. Powered by the `send-admin-notification`
/// Supabase Edge Function.
///
/// Events tracked:
/// - New user registrations
/// - Payments received
/// - Verification requests submitted
/// - User reports filed
/// - New matches created
/// - Account deletions
class AdminNotificationService {
  static final AdminNotificationService _instance =
      AdminNotificationService._internal();
  factory AdminNotificationService() => _instance;
  AdminNotificationService._internal();

  @visibleForTesting
  SupabaseClient? testClient;

  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Public API — One method per event type
  // ---------------------------------------------------------------------------

  /// 🔴 HIGH: New user registered via phone OTP
  Future<void> notifyNewRegistration({
    required String userId,
    String? name,
    String? phone,
  }) async {
    await _send(
      eventType: 'new_registration',
      title: 'New User Registered',
      body: '${name ?? 'A new user'} (${phone ?? 'unknown'}) just signed up!',
      triggeredByUserId: userId,
      data: {'phone': phone, 'name': name},
    );
  }

  /// 🔴 HIGH: Payment captured successfully
  Future<void> notifyPaymentReceived({
    required String userId,
    required int amountPaise,
    required String planType,
  }) async {
    final amountRupees = (amountPaise / 100).toStringAsFixed(0);
    await _send(
      eventType: 'payment_received',
      title: 'Payment Received 💰',
      body: '₹$amountRupees for $planType plan!',
      triggeredByUserId: userId,
      data: {'amount': amountPaise, 'plan_type': planType},
    );
  }

  /// 🟡 MEDIUM: User submitted a verification request
  Future<void> notifyVerificationSubmitted({
    required String userId,
    required String verificationType,
    String? userName,
  }) async {
    await _send(
      eventType: 'verification_submitted',
      title: 'Verification Request',
      body: '${userName ?? 'A user'} submitted ${verificationType.replaceAll('_', ' ')} verification.',
      triggeredByUserId: userId,
      data: {'verification_type': verificationType},
    );
  }

  /// 🟡 MEDIUM: A user reported another user
  Future<void> notifyUserReported({
    required String reporterId,
    required String reportedId,
    required String reason,
  }) async {
    await _send(
      eventType: 'user_reported',
      title: 'User Report Filed ⚠️',
      body: 'Reason: $reason',
      triggeredByUserId: reporterId,
      data: {'reported_user_id': reportedId, 'reason': reason},
    );
  }

  /// 🟢 LOW: Two users matched
  Future<void> notifyNewMatch({
    String? user1Name,
    String? user2Name,
  }) async {
    await _send(
      eventType: 'new_match',
      title: 'New Match Created 💕',
      body: '${user1Name ?? 'User'} and ${user2Name ?? 'User'} just matched!',
      data: {'user1': user1Name, 'user2': user2Name},
    );
  }

  /// 🔴 HIGH: User deleted their account
  Future<void> notifyAccountDeleted({
    required String userId,
    String? name,
    String? phone,
  }) async {
    await _send(
      eventType: 'account_deleted',
      title: 'Account Deleted 🚨',
      body: '${name ?? 'A user'} (${phone ?? userId}) deleted their account.',
      triggeredByUserId: userId,
      data: {'name': name, 'phone': phone},
    );
  }

  /// 🟢 LOW: App installed on a new device
  Future<void> notifyAppInstall({
    String? platform,
  }) async {
    await _send(
      eventType: 'app_installed',
      title: 'New App Install 📲',
      body: 'App installed on ${platform ?? 'unknown'} device.',
      data: {'platform': platform},
    );
  }

  /// 🔴 HIGH: User logged in for the first time
  Future<void> notifyFirstLogin({
    required String userId,
    String? phone,
    String? email,
  }) async {
    final identifier = phone ?? email ?? userId;
    await _send(
      eventType: 'first_login',
      title: 'First Login 🔑',
      body: '$identifier just logged in for the first time!',
      triggeredByUserId: userId,
      data: {'phone': phone, 'email': email},
    );
  }

  /// 🟡 MEDIUM: User completed profile creation
  Future<void> notifyProfileCreated({
    required String userId,
    required String name,
    String? gender,
  }) async {
    await _send(
      eventType: 'profile_created',
      title: 'New Profile Created 👤',
      body: '$name just created their profile${gender != null ? ' ($gender)' : ''}!',
      triggeredByUserId: userId,
      data: {'name': name, 'gender': gender},
    );
  }

  /// Generic catch-all for any high-value admin event
  Future<void> notifyHighValueAction({
    required String eventType,
    required String title,
    required String body,
    String? triggeredByUserId,
    Map<String, dynamic>? data,
    String targetRole = 'admin',
  }) async {
    await _send(
      eventType: eventType,
      title: title,
      body: body,
      triggeredByUserId: triggeredByUserId,
      data: data,
      targetRole: targetRole,
    );
  }

  // ---------------------------------------------------------------------------
  // Staff-Specific Notifications
  // ---------------------------------------------------------------------------

  /// 📋 Staff: Verification task assigned
  Future<void> notifyStaffVerificationAssigned({
    required String staffUserId,
    required String verificationType,
    String? userName,
    String? userId,
  }) async {
    await _send(
      eventType: 'verification_assigned',
      title: '📋 Verification Assigned',
      body: 'Review ${userName ?? 'a user'}\'s ${verificationType.replaceAll('_', ' ')} verification.',
      targetRole: 'staff',
      targetUserId: staffUserId,
      triggeredByUserId: userId,
      data: {
        'verification_type': verificationType,
        'user_name': userName,
        'assigned_to': staffUserId,
      },
    );
  }

  /// ⚠️ Staff: User report to review
  Future<void> notifyStaffReportReview({
    required String staffUserId,
    required String reporterId,
    required String reportedId,
    required String reason,
  }) async {
    await _send(
      eventType: 'report_review',
      title: '⚠️ Report Needs Review',
      body: 'Reason: $reason',
      targetRole: 'staff',
      targetUserId: staffUserId,
      triggeredByUserId: reporterId,
      data: {
        'reporter_id': reporterId,
        'reported_id': reportedId,
        'reason': reason,
      },
    );
  }

  /// 🚩 Staff: Profile flagged for manual review
  Future<void> notifyStaffProfileFlagged({
    required String userId,
    required String flagReason,
    String? userName,
  }) async {
    await _send(
      eventType: 'profile_flagged',
      title: '🚩 Profile Flagged',
      body: '${userName ?? 'A profile'} flagged: $flagReason',
      targetRole: 'staff',
      triggeredByUserId: userId,
      data: {'flag_reason': flagReason, 'user_name': userName},
    );
  }

  /// 💳 Staff: Payment dispute
  Future<void> notifyStaffPaymentDispute({
    required String userId,
    required int amountPaise,
    required String disputeReason,
  }) async {
    final amountRupees = (amountPaise / 100).toStringAsFixed(0);
    await _send(
      eventType: 'payment_dispute',
      title: '💳 Payment Dispute',
      body: '₹$amountRupees — $disputeReason',
      targetRole: 'staff',
      triggeredByUserId: userId,
      data: {'amount': amountPaise, 'reason': disputeReason},
    );
  }

  // ---------------------------------------------------------------------------
  // Private: Edge Function Caller
  // ---------------------------------------------------------------------------

  Future<void> _send({
    required String eventType,
    required String title,
    required String body,
    String? triggeredByUserId,
    String? targetUserId,
    String targetRole = 'admin',
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-admin-notification',
        body: {
          'event_type': eventType,
          'title': title,
          'body': body,
          'data': data ?? {},
          'triggered_by_user_id': triggeredByUserId,
          'target_role': targetRole,
          'target_user_id': targetUserId,
        },
      );

      if (response.status == 200) {
        AppLogger.debug('AdminNotificationService', '📢 [AdminNotify] $eventType → $targetRole sent successfully');
      } else if (response.status == 403) {
        // Expected for standard users on startup tasks
        AppLogger.warn('AdminNotificationService', '📢 [AdminNotify] Skip $eventType: Non-admin session');
      } else {
        debugPrint(
            '📢 [AdminNotify] $eventType failed (${response.status}): ${response.data}');
      }
    } catch (e) {
      // Fire-and-forget: admin notifications should never block user flows
      AppLogger.error('AdminNotificationService', '📢 [AdminNotify] Error sending $eventType: $e');
    }
  }
}

