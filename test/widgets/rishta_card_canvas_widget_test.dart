import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/presentation/home_screen/widgets/profile_share_card.dart';

void main() {
  testWidgets('ProfileShareCard renders Gor Banjara mantra and profile stats correctly', (WidgetTester tester) async {
    final mockProfile = ProfileModel(
      id: 'test-profile-123',
      userId: 'user-123',
      fullName: 'Rahul Rathod',
      surname: 'Rathod',
      age: 27,
      gender: 'Male',
      height: '5 ft 10 in',
      education: 'B.Tech Computer Science',
      profession: 'Software Engineer',
      permanentLocation: 'Pune, Maharashtra',
      state: 'Maharashtra',
      district: 'Pune',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProfileShareCard(profile: mockProfile),
          ),
        ),
      ),
    );

    // Verify Gor Banjara Mantra
    expect(find.text('॥ जय सेवालाल ॥'), findsOneWidget);

    // Verify BanjaraBio Branding
    expect(find.text('BANJARABIO'), findsOneWidget);

    // Verify Candidate Stats
    expect(find.text('Rahul Rathod, 27'), findsOneWidget);
    expect(find.text('Software Engineer'), findsOneWidget);
  });
}
