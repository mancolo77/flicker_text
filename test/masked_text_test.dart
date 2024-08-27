import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flicker_text/src/flicker_text.dart';

void main() {
  testWidgets('SpoilerText reveals text on tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlickerText(
            text: 'Скрытый текст',
          ),
        ),
      ),
    );

    // Проверяем, что текст изначально не отображается
    expect(find.text('Скрытый текст'), findsNothing);

    // Имитируем нажатие
    await tester.tap(find.byType(FlickerText));
    await tester.pump();

    // Текст должен отображаться
    expect(find.text('Скрытый текст'), findsOneWidget);

    // Ждем окончания revealDuration
    await tester.pump(Duration(seconds: 1));

    // Текст снова должен быть скрыт
    expect(find.text('Скрытый текст'), findsNothing);
  });
}
