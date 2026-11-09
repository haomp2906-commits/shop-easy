// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shop_easy/home_page.dart';

void main() {
  testWidgets('AppBar actions show Vietnamese tooltips and snackbars', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    expect(find.byTooltip('Tìm kiếm'), findsOneWidget);
    expect(find.byTooltip('Thông báo'), findsOneWidget);
    expect(find.byTooltip('Cài đặt'), findsOneWidget);

    for (final action in [
      ('Tìm kiếm', 'Bạn vừa bấm Tìm kiếm'),
      ('Thông báo', 'Bạn vừa bấm Thông báo'),
      ('Cài đặt', 'Bạn vừa bấm Cài đặt'),
    ]) {
      await tester.tap(find.byTooltip(action.$1));
      await tester.pump();
      expect(find.text(action.$2), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    }

    final notificationIcon = tester.widget<Icon>(
      find.byIcon(Icons.notifications_outlined),
    );
    expect(notificationIcon.size, 30);
    expect(notificationIcon.color, Colors.deepOrange);
  });
}
