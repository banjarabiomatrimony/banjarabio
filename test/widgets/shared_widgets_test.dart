import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:banjarabio/widgets/typing_indicator.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';

Widget wrapWithSizer(Widget child) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  ),
);

void main() {
  group('TypingIndicator', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const TypingIndicator(),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(TypingIndicator), findsOneWidget);
    });
  });

  group('SkeletonLoaders', () {
    testWidgets('ChatBubbleSkeleton renders', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const ChatBubbleSkeleton(),
      ));
      await tester.pump();

      expect(find.byType(ChatBubbleSkeleton), findsOneWidget);
    });

    testWidgets('ConversationListSkeleton renders', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const ConversationListSkeleton(),
      ));
      await tester.pump();

      expect(find.byType(ConversationListSkeleton), findsOneWidget);
    });

    testWidgets('FilterScreenSkeleton renders', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const FilterScreenSkeleton(),
      ));
      await tester.pump();

      expect(find.byType(FilterScreenSkeleton), findsOneWidget);
    });

    testWidgets('TrustScoreSkeleton renders', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const TrustScoreSkeleton(),
      ));
      await tester.pump();

      expect(find.byType(TrustScoreSkeleton), findsOneWidget);
    });

    testWidgets('GenericListSkeleton renders', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const GenericListSkeleton(),
      ));
      await tester.pump();

      expect(find.byType(GenericListSkeleton), findsOneWidget);
    });
  });

  group('CustomAppBar', () {
    testWidgets('renders with title', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(Sizer(
        builder: (context, orientation, deviceType) => const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: Scaffold(
            appBar: CustomAppBar(title: 'Test Title'),
            body: Text('Body'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
    });
  });
}
