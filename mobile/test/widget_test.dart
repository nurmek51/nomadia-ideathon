import 'package:flutter_test/flutter_test.dart';

import 'package:nomadia_mobile/app.dart';

void main() {
  testWidgets('app boots to Nomadia role select', (WidgetTester tester) async {
    await tester.pumpWidget(const NomadiaApp());
    await tester.pumpAndSettle();

    expect(find.text('Nomadia'), findsOneWidget);
    expect(find.text('Житель'), findsOneWidget);
  });
}
