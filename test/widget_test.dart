import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/presentation/pages/todo_page.dart';

void main() {
  testWidgets('Task dialog saves entered text', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TaskDialog(initialText: ''))));
    await tester.enterText(find.byType(TextField), 'Study Flutter');
    expect(find.text('Study Flutter'), findsOneWidget);
  });
}
