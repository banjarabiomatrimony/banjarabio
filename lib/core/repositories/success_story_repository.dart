import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/success_story_model.dart';
import 'package:banjarabio/core/repositories/isolate_first_repository.dart';

class SuccessStoryRepository extends IsolateFirstRepository {
  static final SuccessStoryRepository _instance = SuccessStoryRepository._internal();
  factory SuccessStoryRepository() => _instance;
  SuccessStoryRepository._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<BackendResponse<void>> submitSuccessStory(SuccessStoryModel story) async {
    try {
      await _supabase.from('success_stories').insert(story.toJson());
      return BackendResponse.success(null);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  Future<BackendResponse<List<SuccessStoryModel>>> getMySubmissions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return BackendResponse.failure('Not authenticated');

      final response = await _supabase
          .from('success_stories')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = await mapListInBackground<SuccessStoryModel>(
        response as List,
        SuccessStoryModel.fromJson,
      );

      return BackendResponse.success(list);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }
}
