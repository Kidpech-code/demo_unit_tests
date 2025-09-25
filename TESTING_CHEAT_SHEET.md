# 📚 Flutter Testing Cheat Sheet - สรุปสำหรับอ้างอิง

## 🏗️ โครงสร้าง Test พื้นฐาน

### Basic Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Description of test group', () {
    test('should do something', () {
      // Arrange - เตรียมข้อมูล
      final input = 'test data';

      // Act - ทำการทดสอบ
      final result = functionUnderTest(input);

      // Assert - ตรวจสอบผลลัพธ์
      expect(result, equals('expected output'));
    });
  });
}
```

### SetUp/TearDown Pattern

```dart
group('Service Tests', () {
  late MyService service;

  setUp(() {
    service = MyService();     // รันก่อนแต่ละ test
  });

  tearDown(() {
    service.cleanup();         // รันหลังแต่ละ test
  });

  test('should work', () {
    // test implementation
  });
});
```

## 🧪 Matchers ที่ใช้บ่อย

### Basic Matchers

```dart
// ความเท่ากัน
expect(actual, equals(expected));
expect(actual, expected);                // แบบสั้น

// Boolean checks
expect(value, isTrue);
expect(value, isFalse);
expect(value, isNull);
expect(value, isNotNull);

// Type checks
expect(object, isA<String>());
expect(object, isA<MyClass>());

// Numeric comparisons
expect(number, greaterThan(5));
expect(number, lessThan(10));
expect(number, closeTo(3.14, 0.01));    // สำหรับ floating point
```

### Collection Matchers

```dart
// Lists
expect(list, isEmpty);
expect(list, isNotEmpty);
expect(list, hasLength(3));
expect(list, contains('item'));
expect(list, containsAll(['item1', 'item2']));

// Maps
expect(map, containsPair('key', 'value'));
expect(map.keys, contains('key'));
```

### String Matchers

```dart
expect(string, startsWith('Hello'));
expect(string, endsWith('world'));
expect(string, contains('substring'));
expect(string, matches(r'\d+'));        // regex pattern
```

## 🚨 Exception Testing

### Testing Exceptions

```dart
// Synchronous exceptions
expect(() => riskyFunction(), throwsException);
expect(() => riskyFunction(), throwsA(isA<ArgumentError>()));

// Custom exception messages
expect(() => riskyFunction(),
    throwsA(predicate((e) => e.toString().contains('Expected message'))));

// Async exceptions
expect(asyncRiskyFunction(), throwsA(isA<HttpException>()));
```

## ⏰ Async Testing

### Future Testing

```dart
test('async test example', () async {
  // รอ Future เสร็จ
  final result = await asyncFunction();
  expect(result, equals('expected'));

  // หรือใช้ completion
  expect(asyncFunction(), completion('expected'));
});
```

### Stream Testing

```dart
test('stream test example', () {
  final stream = getDataStream();

  expect(stream, emitsInOrder([
    'first value',
    'second value',
    emitsDone,
  ]));
});
```

### Timeout Testing

```dart
test('should complete within time limit', () async {
  await expectLater(
    slowFunction(),
    completes,
    timeout: Duration(seconds: 5)
  );
});
```

## 🎭 Mocking with Mockito

### Basic Mock Setup

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// 1. สร้าง annotation
@GenerateMocks([HttpClient, Database])
void main() {}

// 2. รัน code generation
// dart run build_runner build

// 3. ใช้ mock ใน test
test('should mock properly', () {
  final mockClient = MockHttpClient();

  // Setup mock behavior
  when(mockClient.get(any)).thenAnswer(
    (_) async => Response('success', 200)
  );

  // Use in test
  final service = ApiService(mockClient);
  final result = await service.fetchData();

  // Verify
  expect(result, equals('success'));
  verify(mockClient.get(any)).called(1);
});
```

### Advanced Mocking

```dart
// Mock with specific parameters
when(mock.method('specific')).thenReturn('result');

// Mock with any parameters
when(mock.method(any)).thenReturn('result');

// Mock throwing exceptions
when(mock.method(any)).thenThrow(Exception('Error'));

// Mock async methods
when(mock.asyncMethod(any)).thenAnswer((_) async => 'result');

// Verify interactions
verify(mock.method('param')).called(1);
verify(mock.method(any)).called(greaterThan(0));
verifyNever(mock.dangerousMethod(any));
```

## 🎨 Widget Testing

### Basic Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

testWidgets('should display text', (WidgetTester tester) async {
  // Arrange - สร้าง widget
  await tester.pumpWidget(
    MaterialApp(
      home: MyWidget(text: 'Hello'),
    ),
  );

  // Assert - ตรวจสอบ UI
  expect(find.text('Hello'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsNothing);
});
```

### Widget Interaction

```dart
testWidgets('should handle tap', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  // Find และ tap button
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();        // rebuild หลัง state change

  // ตรวจสอบผลลัพธ์
  expect(find.text('Clicked!'), findsOneWidget);
});
```

### Common Finders

```dart
// หา widget ตาม type
find.byType(ElevatedButton)

// หา widget ตาม text
find.text('Button Label')

// หา widget ตาม key
find.byKey(ValueKey('my-key'))

// หา widget ตาม icon
find.byIcon(Icons.add)

// รวม finders
find.descendant(
  of: find.byType(AppBar),
  matching: find.text('Title')
)
```

## 🔧 Test Organization

### File Structure

```
test/
├── models/
│   └── user_test.dart
├── services/
│   ├── user_service_test.dart
│   └── api_service_test.dart
├── utils/
│   └── string_helper_test.dart
├── widgets/
│   └── custom_widgets_test.dart
└── integration_test/
    └── app_test.dart
```

### Naming Conventions

- **Files:** `[class_name]_test.dart`
- **Groups:** อธิบาย functionality ที่ทดสอบ
- **Tests:** เริ่มด้วย "should" + อธิบาย expected behavior

```dart
group('UserService', () {
  group('addUser', () {
    test('should add user successfully when valid data provided', () {});
    test('should throw ArgumentError when user ID already exists', () {});
    test('should throw ArgumentError when user data is invalid', () {});
  });
});
```

## 📊 Test Commands

### Basic Commands

```bash
# รัน tests ทั้งหมด
flutter test

# รัน test ไฟล์เฉพาะ
flutter test test/models/user_test.dart

# รัน tests ที่มี pattern
flutter test --name "UserService"

# ดู test coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Advanced Commands

```bash
# รัน test แบบ verbose
flutter test --reporter expanded

# รัน integration tests
flutter test integration_test/

# รัน tests บน device จริง
flutter test integration_test/ --device-id=<device-id>
```

## 🎯 Best Practices

### ✅ DO

- เขียน test names ที่อธิบายได้ชัดเจน
- ใช้ Arrange-Act-Assert pattern
- จัดกลุ่ม related tests
- Test edge cases และ error conditions
- ใช้ setUp/tearDown สำหรับ common initialization
- Mock external dependencies
- เป้าหมาย coverage ≥ 80%

### ❌ DON'T

- Test implementation details
- Test framework code (Flutter widgets)
- Copy-paste test code โดยไม่เปลี่ยน
- ละเลย test maintenance
- เขียน tests ที่ dependent กัน
- Hardcode values ที่ไม่จำเป็น

## 🐛 Debugging Tests

### Common Issues

```dart
// Problem: Test timeout
test('should complete', () async {
  // Solution: เพิ่ม timeout
  await asyncOperation();
}, timeout: Timeout(Duration(seconds: 30)));

// Problem: Widget not found
testWidgets('widget test', (tester) async {
  await tester.pumpWidget(MyWidget());
  // Solution: เพิ่ม pump หรือ pumpAndSettle
  await tester.pumpAndSettle();
  expect(find.text('Expected'), findsOneWidget);
});

// Problem: Mock not working
test('mock test', () {
  when(mock.method()).thenReturn('value');
  // Solution: ตรวจสอบ mock setup และ generation
  verify(mock.method()).called(1);
});
```

---

**📖 Quick Reference:** เก็บไฟล์นี้ไว้อ้างอิงขณะเขียน tests

**🔄 Updated:** สำหรับ Flutter 3.8.1+, Mockito 5.5.1+
