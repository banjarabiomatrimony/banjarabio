import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/providers/home_tab_provider.dart';

void main() {
  group('HomeTabProvider Tests', () {
    test('initial tab is index 0 and updates correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(homeTabProvider), equals(0));

      container.read(homeTabProvider.notifier).state = 2;
      expect(container.read(homeTabProvider), equals(2));
    });
  });
}
