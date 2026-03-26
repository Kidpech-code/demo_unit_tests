// Smoke test สำหรับแอปหลัก — ทดสอบว่าแอปเปิดได้ถูกต้อง

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo_unit_tests/main.dart';

void main() {
  testWidgets('App should launch and display UserManagementPage', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // ตรวจสอบว่าแอปเริ่มต้นได้ — หน้า UserManagementPage ควรแสดง
    expect(find.text('User Management'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
