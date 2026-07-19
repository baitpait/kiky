import 'package:flutter_test/flutter_test.dart';
import 'package:kiddy_link/main.dart';

void main() {
  testWidgets('KiddyLinkApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const KiddyLinkApp());
    await tester.pump();
    expect(find.byType(KiddyLinkApp), findsOneWidget);
  });
}
