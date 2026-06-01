import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewai/app.dart';

void main() {
  testWidgets('App smoke test - starts at login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pump(); // allow redirect to process
    // App now starts at /login — verify login-related UI exists
    expect(find.text('로그인'), findsWidgets);
  });
}
