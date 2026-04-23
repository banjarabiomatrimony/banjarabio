// Phase 11: PhotoPickerService unit tests
// Tests image picking flow, permissions handling, and integration with ImageCompressionService.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banjarabio/services/photo_picker_service.dart';
import 'package:banjarabio/core/services/image_compression_service.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockImagePicker extends Mock implements ImagePicker {}
class MockImageCompressionService extends Mock implements ImageCompressionService {}

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }
  @override
  Future<String?> getApplicationDocumentsPath() async => null;
  @override
  Future<String?> getApplicationSupportPath() async => null;
  @override
  Future<String?> getLibraryPath() async => null;
  @override
  Future<String?> getExternalStoragePath() async => null;
  @override
  Future<List<String>?> getExternalCachePaths() async => null;
  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PhotoPickerService service;
  late MockImagePicker mockPicker;
  late MockImageCompressionService mockCompressor;
  const MethodChannel permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

  setUp(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    service = PhotoPickerService();
    mockPicker = MockImagePicker();
    mockCompressor = MockImageCompressionService();

    service.testPicker = mockPicker;
    service.testCompressionService = mockCompressor;

    // Default permission mock: Granted
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'requestPermissions') {
        return { for (var p in methodCall.arguments) p: 1 };
      }
      if (methodCall.method == 'checkPermissionStatus') {
        return 1; // granted
      }
      return null;
    });

    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(File(''));
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  group('PhotoPickerService', () {
    test('pickFromGallery returns error when permission denied', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(permissionChannel, (MethodCall methodCall) async {
        return { for (var p in methodCall.arguments) p: 0 };
      });

      final result = await service.pickFromGallery();
      expect(result.isSuccess, isFalse);
      expect(result.error, contains('Permission denied'));
    });

    test('pickFromGallery processes image on success', () async {
      final tempFile = File(p.join(Directory.systemTemp.path, 'picked.jpg'));
      try {
        await tempFile.writeAsBytes([0, 1, 2]);

        final xFile = XFile(tempFile.path);
        when(() => mockPicker.pickImage(
              source: ImageSource.gallery,
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenAnswer((_) async => xFile);

        when(() => mockCompressor.compressImageSafe(any()))
            .thenAnswer((invocation) async => invocation.positionalArguments[0] as File);

        final result = await service.pickFromGallery();
        
        expect(result.isSuccess, isTrue);
        expect(result.filePath, equals(tempFile.path));
        verify(() => mockCompressor.compressImageSafe(any())).called(1);
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });

    test('cleanupAllTempFiles handles directory listing and deletion', () async {
      final tempDir = Directory.systemTemp;
      final tempFile = File(p.join(tempDir.path, 'compressed_tester.jpg'));
      try {
        await tempFile.create();
        await service.cleanupAllTempFiles();
        // Since we mocked getTemporaryDirectory to return systemTemp, 
        // the service should have listed and deleted it.
        expect(tempFile.existsSync(), isFalse);
      } finally {
        if (tempFile.existsSync()) tempFile.deleteSync();
      }
    });

    test('processImage handles missing file gracefully', () async {
      final result = await service.processImage('/non/existent/path.jpg');
      expect(result.isSuccess, isFalse);
      expect(result.error, contains('Image file lost'));
    });
  });
}
