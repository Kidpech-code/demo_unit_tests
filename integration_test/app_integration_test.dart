import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_unit_tests/widgets/custom_widgets.dart';
import 'package:demo_unit_tests/services/user_service.dart';
import 'package:demo_unit_tests/pages/demo_pages.dart';

/// Integration Tests สำหรับ Flutter Application
///
/// Integration tests ทดสอบการทำงานของ components หลายๆ ตัวร่วมกัน
/// เพื่อให้แน่ใจว่าแอปทำงานถูกต้องใน end-to-end scenarios
void main() {
  group('Widget Integration Tests', () {
    testWidgets('CounterWidget should work correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CounterWidget(
                initialValue: 0,
                minValue: -10,
                maxValue: 10,
              ),
            ),
          ),
        ),
      );

      // Assert - ตรวจสอบสถานะเริ่มต้น
      expect(find.text('Counter: 0'), findsOneWidget);
      expect(find.text('Zero'), findsOneWidget);

      // Act - เพิ่มค่า
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Assert - ตรวจสอบค่าเปลี่ยนแปลง
      expect(find.text('Counter: 1'), findsOneWidget);
      expect(find.text('Positive'), findsOneWidget);
    });
  });

  group('Service Integration Tests', () {
    testWidgets('UserService with UserManagementPage should work', (
      tester,
    ) async {
      final userService = UserService();

      await tester.pumpWidget(
        MaterialApp(home: UserManagementPage(userService: userService)),
      );

      // Assert - ตรวจสอบสถานะเริ่มต้น
      expect(find.text('User Management'), findsOneWidget);
      expect(find.text('Total Users: 0'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('Basic App Structure Tests', () {
    testWidgets('should create simple Flutter app', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Demo App')),
            body: const Center(child: Text('Hello Flutter')),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Assert - ตรวจสอบองค์ประกอบพื้นฐาน
      expect(find.text('Demo App'), findsOneWidget);
      expect(find.text('Hello Flutter'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
