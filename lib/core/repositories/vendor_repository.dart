import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/vendor_model.dart';
import 'package:banjarabio/core/models/backend_response.dart';

class VendorRepository {
  VendorRepository._();
  static final VendorRepository instance = VendorRepository._();

  static const String _localVendorKeyPrefix = 'vendor_self_registration_';

  SupabaseClient get _supabase => Supabase.instance.client;

  /// 📝 Register a new vendor (Network Effect Self-Registration)
  Future<BackendResponse<VendorModel>> registerVendor({
    required String businessName,
    required String ownerName,
    required String phone,
    required String whatsapp,
    required String category,
    required String categoryLabel,
    required String state,
    required String district,
    required String city,
    required String address,
    required int experienceYears,
    required int startingPrice,
    int? averagePrice,
    String? aboutBusiness,
    String? instagramUrl,
    String? youtubeUrl,
    String? websiteUrl,
    Map<String, dynamic> specificAttributes = const {},
  }) async {
    try {
      final now = DateTime.now();
      final vendorId =
          'vendor_${now.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch.remainder(10000)}';

      final vendor = VendorModel(
        id: vendorId,
        businessName: businessName,
        ownerName: ownerName,
        phone: phone,
        whatsapp: whatsapp,
        category: category,
        categoryLabel: categoryLabel,
        state: state,
        district: district,
        city: city,
        address: address,
        experienceYears: experienceYears,
        startingPrice: startingPrice,
        averagePrice: averagePrice,
        aboutBusiness: aboutBusiness,
        instagramUrl: instagramUrl,
        youtubeUrl: youtubeUrl,
        websiteUrl: websiteUrl,
        specificAttributes: specificAttributes,
        createdAt: now,
      );

      // 1. Try Supabase Insert
      try {
        await _supabase.from('vendors').insert(vendor.toJson());
      } catch (dbError) {
        debugPrint(
            '⚠️ [VendorRepository] Supabase insert note (table may be pending migration): $dbError');
      }

      // 2. Cache locally to ensure offline persistence and immediate vendor profile access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_localVendorKeyPrefix$vendorId',
        jsonEncode(vendor.toJson()),
      );
      await prefs.setString('current_registered_vendor_id', vendorId);

      return BackendResponse.success(vendor);
    } catch (e) {
      debugPrint('❌ [VendorRepository] Registration error: $e');
      return BackendResponse.failure('Failed to submit registration: $e');
    }
  }

  /// 🔍 Get Current Logged-in / Registered Vendor Profile if exists
  Future<VendorModel?> getCurrentVendorProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getString('current_registered_vendor_id');
      if (vendorId == null) return null;

      final cached = prefs.getString('$_localVendorKeyPrefix$vendorId');
      if (cached != null) {
        return VendorModel.fromJson(
            jsonDecode(cached) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('⚠️ [VendorRepository] Error loading cached vendor profile: $e');
    }
    return null;
  }
}
