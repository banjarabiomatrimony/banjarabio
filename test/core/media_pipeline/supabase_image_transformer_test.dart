import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/media_pipeline/layer3_cdn_transformations/supabase_image_transformer.dart';

void main() {
  group('SupabaseImageTransformer Tests', () {
    tearDown(() {
      SupabaseImageTransformer.clearCustomHosts();
    });

    test('isTransformable detects Supabase and CDN URLs correctly', () {
      expect(SupabaseImageTransformer.isTransformable(null), isFalse);
      expect(SupabaseImageTransformer.isTransformable(''), isFalse);
      expect(SupabaseImageTransformer.isTransformable('https://example.com/photo.jpg'), isFalse);
      expect(SupabaseImageTransformer.isTransformable('https://xyz.supabase.co/storage/v1/object/public/photos/avatar.jpg'), isTrue);
      expect(SupabaseImageTransformer.isTransformable('https://d12345.cloudfront.net/images/hero.webp'), isTrue);
      expect(SupabaseImageTransformer.isTransformable('https://res.cloudinary.com/demo/image/upload/sample.jpg'), isTrue);
      expect(SupabaseImageTransformer.isTransformable('https://mycustomcdn.com/storage/v1/object/public/profiles/1.png'), isTrue);
    });

    test('custom host whitelist management works', () {
      const customHost = 'media.customdomain.org';
      expect(SupabaseImageTransformer.isTransformable('https://$customHost/images/pic.png'), isFalse);

      SupabaseImageTransformer.addSupportedHost(customHost);
      expect(SupabaseImageTransformer.isTransformable('https://$customHost/images/pic.png'), isTrue);

      SupabaseImageTransformer.removeSupportedHost(customHost);
      expect(SupabaseImageTransformer.isTransformable('https://$customHost/images/pic.png'), isFalse);
    });

    test('transform appends width, height, quality, format, resize queries', () {
      const original = 'https://xyz.supabase.co/storage/v1/object/public/photos/user.jpg';
      final transformed = SupabaseImageTransformer.transform(
        original,
        width: 400,
        height: 600,
        quality: 85,
        format: 'webp',
        resize: 'contain',
      );

      expect(transformed, contains('width=400'));
      expect(transformed, contains('height=600'));
      expect(transformed, contains('quality=85'));
      expect(transformed, contains('format=webp'));
      expect(transformed, contains('resize=contain'));
    });

    test('transform preserves existing query parameters', () {
      const original = 'https://xyz.supabase.co/storage/v1/object/public/photos/user.jpg?v=1&token=abc';
      final transformed = SupabaseImageTransformer.transform(original, width: 300);

      expect(transformed, contains('v=1'));
      expect(transformed, contains('token=abc'));
      expect(transformed, contains('width=300'));
    });

    test('preset helper methods generate correct query configurations', () {
      const original = 'https://xyz.supabase.co/storage/v1/object/public/photos/user.jpg';

      final thumb = SupabaseImageTransformer.getThumbnailUrl(original);
      expect(thumb, contains('width=${SupabaseImageTransformer.thumbnailWidth}'));
      expect(thumb, contains('quality=75'));

      final card = SupabaseImageTransformer.getCardUrl(original);
      expect(card, contains('width=${SupabaseImageTransformer.cardWidth}'));
      expect(card, contains('quality=80'));

      final avatar = SupabaseImageTransformer.getAvatarUrl(original, size: 120);
      expect(avatar, contains('width=120'));
      expect(avatar, contains('height=120'));

      final fullRes = SupabaseImageTransformer.getFullResUrl(original);
      expect(fullRes, contains('width=${SupabaseImageTransformer.fullDetailWidth}'));
      expect(fullRes, contains('quality=85'));
    });

    test('transform handles empty or malformed strings gracefully', () {
      expect(SupabaseImageTransformer.transform(''), equals(''));
      expect(SupabaseImageTransformer.transform(':::not-a-valid-uri:::'), equals(':::not-a-valid-uri:::'));
    });
  });
}
