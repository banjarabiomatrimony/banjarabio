// Phase 12: PhotoUploadSection widget tests
// Verifies photo picking, removal, and premium limits using a mock service.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/photo_upload_section.dart';
import 'package:banjarabio/services/photo_picker_service.dart';
import '../../helpers/widget_test_helpers.dart';

class MockPhotoPickerService extends Mock implements PhotoPickerService {}

void main() {
  group('PhotoUploadSection Widget Tests', () {
    late List<String> photos;
    late List<String> updatedPhotos;
    late MockPhotoPickerService mockPhotoService;

    setUp(() {
      setupWidgetTestMocks();
      photos = [];
      updatedPhotos = [];
      mockPhotoService = MockPhotoPickerService();

      // Default mock behaviors
      when(() => mockPhotoService.cleanupAllTempFiles()).thenAnswer((_) async {});
    });

    tearDown(() {
      tearDownWidgetTestMocks();
    });

    Widget createTestWidget({bool isPremium = false}) {
      return createTestableWidget(
        Scaffold(
          body: PhotoUploadSection(
            photoPickerService: mockPhotoService,
            photos: photos,
            gender: 'Male',
            isPremium: isPremium,
            onPhotosUpdate: (newPhotos) {
              updatedPhotos = List.from(newPhotos);
            },
          ),
        ),
      );
    }

    testWidgets('renders empty state with add button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Profile Photos'), findsOneWidget);
      expect(find.text('No photos added'), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });

    testWidgets('successfully picks and adds a photo', (WidgetTester tester) async {
      const mockPath = 'compressed_image.jpg';
      
      when(() => mockPhotoService.pickFromGallery()).thenAnswer((_) async => const PhotoPickResult(
            filePath: mockPath,
            originalSizeKB: 1000,
            compressedSizeKB: 100,
          ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Add Photo
      await tester.tap(find.byIcon(Icons.add_a_photo));
      await tester.pumpAndSettle();

      // Tap Gallery
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pump(); // Start _pickImage

      // Should show processing indicator
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Processing Image'), findsOneWidget);

      // Wait for internal 500ms delay in _addPhotoToList
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle(); 
      
      expect(find.text('Processing Image'), findsNothing);
      expect(updatedPhotos, contains(mockPath));
    });

    testWidgets('removes a photo', (WidgetTester tester) async {
      photos = ['photo1.jpg'];
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(updatedPhotos, isEmpty);
      expect(find.text('No photos added'), findsOneWidget);
    });

    group('PhotoUploadSection Limits & Replacement', () {
      testWidgets('respects free user limit of 1 photo', (WidgetTester tester) async {
        photos = ['photo1.jpg'];
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Add button should be hidden
        expect(find.byIcon(Icons.add_a_photo), findsNothing);
      });

      testWidgets('allows premium user to upload up to 5 photos', (WidgetTester tester) async {
        photos = ['p1.jpg', 'p2.jpg', 'p3.jpg', 'p4.jpg'];
        await tester.pumpWidget(createTestWidget(isPremium: true));
        await tester.pumpAndSettle();

        // Add button should still be visible at 4 photos
        expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
        
        photos = ['p1.jpg', 'p2.jpg', 'p3.jpg', 'p4.jpg', 'p5.jpg'];
        await tester.pumpWidget(createTestWidget(isPremium: true));
        await tester.pumpAndSettle();
        
        // Add button hidden at 5 photos
        expect(find.byIcon(Icons.add_a_photo), findsNothing);
      });

      testWidgets('free user can remove photo and add another', (WidgetTester tester) async {
        photos = ['existing.jpg'];
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 1. Verify limit hit (no add icon)
        expect(find.byIcon(Icons.add_a_photo), findsNothing);

        // 2. Remove photo
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        
        // 3. Verify add button returned
        expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
        
        // 4. Mimic adding new photo
        when(() => mockPhotoService.pickFromGallery()).thenAnswer((_) async => const PhotoPickResult(
              filePath: 'new.jpg',
              originalSizeKB: 500,
              compressedSizeKB: 50,
            ));
        
        await tester.tap(find.byIcon(Icons.add_a_photo));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Choose from Gallery'));
        await tester.pump(const Duration(seconds: 1)); // Process image
        await tester.pumpAndSettle();

        expect(updatedPhotos, contains('new.jpg'));
      });
    });
  });
}
