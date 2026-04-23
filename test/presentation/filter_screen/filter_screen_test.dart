import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:banjarabio/presentation/filter_screen/filter_screen.dart';

void main() {
  setUp(() => setupWidgetTestMocks());
  tearDown(() => tearDownWidgetTestMocks());

  testWidgets('pumps without hard crash', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const FilterScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(FilterScreen), findsOneWidget);
  });
}
