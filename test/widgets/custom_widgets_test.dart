/// ===================================================================
/// Custom Widgets Tests — สอน Widget Testing ทุกรูปแบบ
/// ===================================================================
///
/// ## ไฟล์นี้สอนอะไร?
/// ทดสอบ Flutter Widget ด้วย `testWidgets` — ครอบคลุมทุกแนวคิด:
///
/// ## แนวคิดที่ใช้
///
/// ### 1. Widget Testing Basics
/// ```dart
/// testWidgets('description', (WidgetTester tester) async {
///   await tester.pumpWidget(MaterialApp(home: MyWidget()));
///   expect(find.text('Hello'), findsOneWidget);
/// });
/// ```
///
/// ### 2. Finder Types
/// - `find.text('Hello')` — ค้นหาด้วยข้อความ
/// - `find.byType(ElevatedButton)` — ค้นหาด้วย type
/// - `find.byIcon(Icons.add)` — ค้นหาด้วย icon
/// - `find.byTooltip('Edit User')` — ค้นหาด้วย tooltip
///
/// ### 3. User Interactions
/// - `tester.tap(finder)` — จำลองการแตะ
/// - `tester.enterText(finder, 'text')` — จำลองการพิมพ์
/// - `tester.pump()` — rebuild widget 1 ครั้ง
/// - `tester.pump(Duration)` — rebuild หลังผ่าน duration
/// - `tester.pumpAndSettle()` — rebuild จนไม่มี animation ค้าง
///
/// ### 4. Matcher Types
/// - `findsOneWidget` — เจอ 1 ตัว
/// - `findsNothing` — ไม่เจอ
/// - `findsNWidgets(3)` — เจอ N ตัว
///
/// ### 5. Callback Testing
/// ```dart
/// bool tapped = false;
/// await tester.pumpWidget(Widget(onTap: () => tapped = true));
/// await tester.tap(find.byType(Widget));
/// expect(tapped, isTrue);
/// ```
///
/// ### 6. Form & Async Testing
/// - enterText → tap submit → pump (validation) → check error messages
/// - Async submit → pump(Duration) → check loading indicator
///
/// ## วิธีรัน
/// ```bash
/// flutter test test/widgets/custom_widgets_test.dart
/// ```
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_unit_tests/widgets/custom_widgets.dart';

void main() {
  group('Custom Widget Tests', () {
    group('UserCard Widget Tests', () {
      testWidgets('should display user information correctly', (tester) async {
        // Arrange
        const name = 'John Doe';
        const email = 'john@example.com';

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UserCard(name: name, email: email),
            ),
          ),
        );

        // Assert
        expect(find.text(name), findsOneWidget);
        expect(find.text(email), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('should show initial letter when no avatar URL', (
        tester,
      ) async {
        // Arrange
        const name = 'John Doe';

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UserCard(name: name, email: 'john@example.com'),
            ),
          ),
        );

        // Assert
        expect(find.text('J'), findsOneWidget); // First letter of name
      });

      testWidgets('should show action buttons when callbacks provided', (
        tester,
      ) async {
        // Arrange
        bool editPressed = false;
        bool deletePressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UserCard(
                name: 'John Doe',
                email: 'john@example.com',
                onEditPressed: () => editPressed = true,
                onDeletePressed: () => deletePressed = true,
              ),
            ),
          ),
        );

        // Assert - ตรวจสอบว่ามี action buttons
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);

        // Act - กดปุ่ม edit และ delete
        await tester.tap(find.byIcon(Icons.edit));
        await tester.tap(find.byIcon(Icons.delete));

        // Assert - ตรวจสอบว่า callback ถูกเรียก
        expect(editPressed, isTrue);
        expect(deletePressed, isTrue);
      });

      testWidgets('should handle tap gesture', (tester) async {
        // Arrange
        bool cardTapped = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UserCard(
                name: 'John Doe',
                email: 'john@example.com',
                onTap: () => cardTapped = true,
              ),
            ),
          ),
        );

        // Act - กด card
        await tester.tap(find.byType(UserCard));

        // Assert
        expect(cardTapped, isTrue);
      });

      testWidgets('should show selected state correctly', (tester) async {
        // Act - สร้าง card ในสถานะ selected
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UserCard(
                name: 'John Doe',
                email: 'john@example.com',
                isSelected: true,
              ),
            ),
          ),
        );

        // Assert - ตรวจสอบว่า card มี elevation สูงขึ้น
        final Card card = tester.widget(find.byType(Card));
        expect(card.elevation, equals(8.0));
      });

      testWidgets('should handle empty name gracefully', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UserCard(name: '', email: 'test@example.com'),
            ),
          ),
        );

        // Assert - ควรแสดง '?' ใน avatar
        expect(find.text('?'), findsOneWidget);
      });

      testWidgets('should not show action buttons when no callbacks', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UserCard(name: 'John Doe', email: 'john@example.com'),
            ),
          ),
        );

        // Assert - ไม่ควรแสดงปุ่ม edit/delete
        expect(find.byIcon(Icons.edit), findsNothing);
        expect(find.byIcon(Icons.delete), findsNothing);
      });
    });

    group('CounterWidget Tests', () {
      testWidgets('should display initial value correctly', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CounterWidget(initialValue: 5)),
          ),
        );

        // Assert
        expect(find.text('Counter: 5'), findsOneWidget);
        expect(find.text('Positive'), findsOneWidget);
      });

      testWidgets('should increment counter when plus button pressed', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CounterWidget(initialValue: 0)),
          ),
        );

        // Assert initial state
        expect(find.text('Counter: 0'), findsOneWidget);
        expect(find.text('Zero'), findsOneWidget);

        // Act - กดปุ่ม increment
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // Assert
        expect(find.text('Counter: 1'), findsOneWidget);
        expect(find.text('Positive'), findsOneWidget);
      });

      testWidgets('should decrement counter when minus button pressed', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CounterWidget(initialValue: 1)),
          ),
        );

        // Act - กดปุ่ม decrement
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        // Assert
        expect(find.text('Counter: 0'), findsOneWidget);
        expect(find.text('Zero'), findsOneWidget);
      });

      testWidgets('should respect max value limit', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CounterWidget(initialValue: 2, maxValue: 3)),
          ),
        );

        // Act - increment to max
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        expect(find.text('Counter: 3'), findsOneWidget);

        // Act - try to increment beyond max
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        // Assert - should still be at max value
        expect(find.text('Counter: 3'), findsOneWidget);
      });

      testWidgets('should respect min value limit', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CounterWidget(initialValue: -2, minValue: -3)),
          ),
        );

        // Act - decrement to min
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();
        expect(find.text('Counter: -3'), findsOneWidget);

        // Act - try to decrement below min
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        // Assert - should still be at min value
        expect(find.text('Counter: -3'), findsOneWidget);
      });

      testWidgets('should disable buttons when at limits', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CounterWidget(initialValue: 5, maxValue: 5, minValue: 5),
            ),
          ),
        );

        // Assert - both buttons should be disabled (onPressed should be null)
        final incrementButtons = find.byWidgetPredicate(
          (widget) =>
              widget is FloatingActionButton && widget.heroTag == 'increment',
        );
        final decrementButtons = find.byWidgetPredicate(
          (widget) =>
              widget is FloatingActionButton && widget.heroTag == 'decrement',
        );

        expect(incrementButtons, findsOneWidget);
        expect(decrementButtons, findsOneWidget);

        final incrementButton = tester.widget<FloatingActionButton>(
          incrementButtons,
        );
        final decrementButton = tester.widget<FloatingActionButton>(
          decrementButtons,
        );

        expect(incrementButton.onPressed, isNull);
        expect(decrementButton.onPressed, isNull);
      });

      testWidgets('should call onValueChanged when counter changes', (
        tester,
      ) async {
        // Arrange
        int? changedValue;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CounterWidget(
                initialValue: 0,
                onValueChanged: (value) => changedValue = value,
              ),
            ),
          ),
        );

        // Act - increment counter
        await tester.tap(find.byIcon(Icons.add));

        // Assert
        expect(changedValue, equals(1));
      });

      testWidgets('should show correct color for positive counter', (
        tester,
      ) async {
        // Test positive counter
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CounterWidget(initialValue: 5)),
          ),
        );
        await tester.pumpAndSettle();

        final positiveTextFinder = find.text('Positive');
        expect(positiveTextFinder, findsOneWidget);
        Text positiveText = tester.widget(positiveTextFinder);
        expect(positiveText.style?.color, equals(Colors.green));
      });

      testWidgets('should show correct color for zero counter', (tester) async {
        // Test zero counter
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CounterWidget(initialValue: 0)),
          ),
        );
        await tester.pumpAndSettle();

        final zeroTextFinder = find.text('Zero');
        expect(zeroTextFinder, findsOneWidget);
        Text zeroText = tester.widget(zeroTextFinder);
        expect(zeroText.style?.color, equals(Colors.grey));
      });

      testWidgets('should show correct color for negative counter', (
        tester,
      ) async {
        // Test negative counter
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CounterWidget(initialValue: -5)),
          ),
        );
        await tester.pumpAndSettle();

        final negativeTextFinder = find.text('Negative');
        expect(negativeTextFinder, findsOneWidget);
        Text negativeText = tester.widget(negativeTextFinder);
        expect(negativeText.style?.color, equals(Colors.red));
      });

      testWidgets('should handle transition from positive to negative', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CounterWidget(initialValue: 1)),
          ),
        );

        // Decrement twice: 1 -> 0 -> -1
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();
        expect(find.text('Counter: 0'), findsOneWidget);
        expect(find.text('Zero'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();
        expect(find.text('Counter: -1'), findsOneWidget);
        expect(find.text('Negative'), findsOneWidget);
      });
    });

    group('AddUserForm Tests', () {
      testWidgets('should display form fields correctly', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AddUserForm())),
        );

        // Assert
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('Name'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Add User'), findsOneWidget);
      });

      testWidgets('should validate required fields', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AddUserForm())),
        );

        // Act - กดปุ่ม submit โดยไม่กรอกข้อมูล
        await tester.tap(find.text('Add User'));
        await tester.pump();

        // Assert - ควรแสดง validation errors
        expect(find.text('Name is required'), findsOneWidget);
        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('should validate name length', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AddUserForm())),
        );

        // Act - กรอกชื่อสั้นเกินไป
        await tester.enterText(find.byType(TextFormField).first, 'A');
        await tester.tap(find.text('Add User'));
        await tester.pump();

        // Assert
        expect(find.text('Name must be at least 2 characters'), findsOneWidget);
      });

      testWidgets('should validate email format', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AddUserForm())),
        );

        // Act - กรอกอีเมลที่ไม่ถูกต้อง
        await tester.enterText(find.byType(TextFormField).first, 'Valid Name');
        await tester.enterText(
          find.byType(TextFormField).last,
          'invalid-email',
        );
        await tester.tap(find.text('Add User'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should submit form with valid data', (tester) async {
        // Arrange
        String? submittedName;
        String? submittedEmail;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AddUserForm(
                onSubmit: (name, email) {
                  submittedName = name;
                  submittedEmail = email;
                },
              ),
            ),
          ),
        );

        // Act - กรอกข้อมูลที่ถูกต้อง
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'john@example.com',
        );
        await tester.tap(find.text('Add User'));

        // รอให้ loading เสร็จ
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        // Assert
        expect(submittedName, equals('John Doe'));
        expect(submittedEmail, equals('john@example.com'));
      });

      testWidgets('should show loading state during submission', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AddUserForm(onSubmit: (name, email) {})),
          ),
        );

        // Act - submit form
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'john@example.com',
        );
        await tester.tap(find.text('Add User'));
        await tester.pump(); // Start the loading state

        // Assert - ควรแสดง loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for the async operation to complete
        await tester.pumpAndSettle();

        // Assert - loading should be gone
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('should clear form after successful submission', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AddUserForm(onSubmit: (name, email) {})),
          ),
        );

        // Act - กรอกและ submit
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).last,
          'john@example.com',
        );
        await tester.tap(find.text('Add User'));

        // รอให้ submission process เสร็จ
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        // Assert - form fields ควรถูก clear
        final nameField = tester.widget<TextFormField>(
          find.byType(TextFormField).first,
        );
        final emailField = tester.widget<TextFormField>(
          find.byType(TextFormField).last,
        );

        expect(nameField.controller?.text, isEmpty);
        expect(emailField.controller?.text, isEmpty);
      });

      testWidgets('should populate initial values correctly', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AddUserForm(
                initialName: 'Initial Name',
                initialEmail: 'initial@example.com',
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Initial Name'), findsOneWidget);
        expect(find.text('initial@example.com'), findsOneWidget);
      });
    });

    group('LoadingWidget Tests', () {
      testWidgets('should display circular loading indicator by default', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoadingWidget())),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display linear loading indicator', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: LoadingWidget(type: LoadingType.linear)),
          ),
        );

        // Assert
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('should display dots loading indicator', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: LoadingWidget(type: LoadingType.dots)),
          ),
        );

        // Assert
        // ตรวจสอบว่ามี 3 จุด (Container)
        expect(find.byType(Container), findsNWidgets(3));
      });

      testWidgets('should display message when provided', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: LoadingWidget(message: 'Loading data...')),
          ),
        );

        // Assert
        expect(find.text('Loading data...'), findsOneWidget);
      });

      testWidgets('should not display message when not provided', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LoadingWidget())),
        );

        // Assert - ควรมี widget น้อยกว่าเมื่อไม่มี message
        expect(find.byType(Text), findsNothing);
      });
    });

    group('SearchWidget Tests', () {
      testWidgets('should display search field with hint text', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: SearchWidget(hintText: 'Search users...')),
          ),
        );

        // Assert
        expect(find.text('Search users...'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should call onSearchChanged when text changes', (
        tester,
      ) async {
        // Arrange
        String? searchQuery;
        final completer = Completer<void>();

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchWidget(
                onSearchChanged: (query) {
                  searchQuery = query;
                  completer.complete();
                },
                debounceDelay: const Duration(milliseconds: 100),
              ),
            ),
          ),
        );

        // Act - พิมพ์ใน search field
        await tester.enterText(find.byType(TextField), 'test query');

        // รอให้ debounce delay ผ่านไป
        await tester.pump(const Duration(milliseconds: 150));
        await completer.future;

        // Assert
        expect(searchQuery, equals('test query'));
      });

      testWidgets('should show clear button when text is entered', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SearchWidget())),
        );

        // Act - พิมพ์ข้อความ
        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump(); // Rebuild after text change

        // Assert - ควรมีปุ่ม clear
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('should clear text when clear button is pressed', (
        tester,
      ) async {
        // Arrange
        String? searchQuery;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchWidget(
                onSearchChanged: (query) => searchQuery = query,
                debounceDelay: const Duration(milliseconds: 50),
              ),
            ),
          ),
        );

        // Act - พิมพ์และกดปุ่ม clear
        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump(const Duration(milliseconds: 100));

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
        expect(searchQuery, equals(''));
      });

      testWidgets('should debounce search calls', (tester) async {
        // Arrange
        int callCount = 0;
        String? finalQuery;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchWidget(
                onSearchChanged: (query) {
                  callCount++;
                  finalQuery = query;
                },
                debounceDelay: const Duration(milliseconds: 200),
              ),
            ),
          ),
        );

        // Act - พิมพ์หลายครั้งอย่างรวดเร็ว
        await tester.enterText(find.byType(TextField), 'a');
        await tester.pump(const Duration(milliseconds: 50));

        await tester.enterText(find.byType(TextField), 'ab');
        await tester.pump(const Duration(milliseconds: 50));

        await tester.enterText(find.byType(TextField), 'abc');

        // รอให้ debounce delay ผ่านไป
        await tester.pump(const Duration(milliseconds: 300));

        // Assert - ควรถูกเรียกแค่ครั้งเดียวเมื่อ debounce เสร็จ
        expect(callCount, equals(1));
        expect(finalQuery, equals('abc'));
      });
    });

    group('Widget Integration Tests', () {
      testWidgets('should handle multiple widgets interaction', (tester) async {
        // Arrange
        bool userCardTapped = false;
        int counterValue = 0;
        String? searchQuery;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  UserCard(
                    name: 'John Doe',
                    email: 'john@example.com',
                    onTap: () => userCardTapped = true,
                  ),
                  CounterWidget(
                    initialValue: 0,
                    onValueChanged: (value) => counterValue = value,
                  ),
                  SearchWidget(
                    onSearchChanged: (query) => searchQuery = query,
                    debounceDelay: const Duration(milliseconds: 50),
                  ),
                ],
              ),
            ),
          ),
        );

        // Act - interact กับ widgets ต่างๆ
        await tester.tap(find.byType(UserCard));
        await tester.tap(find.byIcon(Icons.add));
        await tester.enterText(find.byType(TextField), 'search test');

        // รอให้ interactions เสร็จ
        await tester.pump(const Duration(milliseconds: 100));

        // Assert
        expect(userCardTapped, isTrue);
        expect(counterValue, equals(1));
        expect(searchQuery, equals('search test'));
      });

      testWidgets('should handle widget state changes correctly', (
        tester,
      ) async {
        // Test การเปลี่ยนแปลง props ของ widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UserCard(
                name: 'Original Name',
                email: 'original@example.com',
                isSelected: false,
              ),
            ),
          ),
        );

        // Assert initial state
        expect(find.text('Original Name'), findsOneWidget);

        final Card initialCard = tester.widget(find.byType(Card));
        expect(initialCard.elevation, equals(2.0));

        // Act - เปลี่ยน props
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UserCard(
                name: 'Updated Name',
                email: 'updated@example.com',
                isSelected: true,
              ),
            ),
          ),
        );

        // Assert updated state
        expect(find.text('Updated Name'), findsOneWidget);
        expect(find.text('Original Name'), findsNothing);

        final Card updatedCard = tester.widget(find.byType(Card));
        expect(updatedCard.elevation, equals(8.0));
      });
    });

    group('Performance and Edge Cases', () {
      testWidgets('should handle rapid interactions gracefully', (
        tester,
      ) async {
        // Test การกดปุ่มอย่างรวดเร็ว
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CounterWidget(initialValue: 0)),
          ),
        );

        // Act - กดปุ่ม increment หลายครั้งอย่างรวดเร็ว
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byIcon(Icons.add));
        }
        await tester.pump();

        // Assert - ควรทำงานได้ถูกต้อง
        expect(find.text('Counter: 10'), findsOneWidget);
      });

      testWidgets('should handle widget disposal correctly', (tester) async {
        // Test การ dispose resources
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SearchWidget())),
        );

        // Act - พิมพ์ข้อความเพื่อสร้าง timer
        await tester.enterText(find.byType(TextField), 'test');

        // Act - เอา widget ออก
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: Text('Different Widget'))),
        );

        // Assert - ไม่ควรมี error หรือ memory leak
        expect(find.text('Different Widget'), findsOneWidget);
        expect(find.byType(SearchWidget), findsNothing);
      });
    });
  });
}
