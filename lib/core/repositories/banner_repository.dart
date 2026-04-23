import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/banner_model.dart';

class BannerRepository {
  static final BannerRepository _instance = BannerRepository._internal();
  factory BannerRepository() => _instance;
  BannerRepository._internal();

  SupabaseClient? testClient;

  SupabaseClient get _client => testClient ?? Supabase.instance.client;

  Future<BackendResponse<List<BannerModel>>> getActiveBanners({
    String? gender,
    String? currentPlan,
  }) async {
    try {
      final response = await _client.rpc(
        'get_active_banners',
        params: {
          'p_gender': gender,
          'p_current_plan': currentPlan,
        },
      );

      return BackendResponse.fromRpc(
        response,
        mapper: (data) => (data as List).map((x) => BannerModel.fromJson(x as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }
}
