/// ===================================================================
/// User Model Unit Tests
/// ===================================================================
///
/// ## ไฟล์นี้สอนอะไร?
/// ทดสอบ Data Model class — เป็น unit test พื้นฐานที่สุด
///
/// ## แนวคิดที่ใช้
/// - **group()** — จัดกลุ่ม test ที่เกี่ยวข้อง เช่น Constructor, isAdult, toMap
/// - **setUp()** — สร้างข้อมูลทดสอบใหม่ก่อนทุก test → แต่ละ test ไม่กระทบกัน
/// - **AAA Pattern** — Arrange (เตรียม) → Act (ทำ) → Assert (ตรวจ)
/// - **Boundary Value Analysis** — ทดสอบค่าขอบ เช่น อายุ 17, 18, 19
/// - **Round-trip Test** — toMap → fromMap ต้องได้ข้อมูลเดิม
/// - **Equality Testing** — override == แล้วทดสอบว่าเปรียบเทียบ object ได้ถูก
///
/// ## Matcher ที่ใช้ในไฟล์นี้
/// - `equals()` — เปรียบเทียบค่า
/// - `isTrue` / `isFalse` — ตรวจ boolean
/// - `isNot(equals())` — ตรวจว่าไม่เท่ากัน
///
/// ## วิธีรัน
/// ```bash
/// flutter test test/models/user_test.dart
/// ```
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_unit_tests/models/user.dart';

void main() {
  group('User Model Tests', () {
    late User testUser;

    setUp(() {
      // จัดเตรียมข้อมูลทดสอบก่อนแต่ละ test case
      testUser = User(
        id: 1,
        name: 'สมชาย ใจดี',
        email: 'somchai@example.com',
        age: 25,
        isActive: true,
      );
    });

    group('Constructor Tests', () {
      test('should create user with all required fields', () {
        // Arrange & Act - การสร้าง object
        final user = User(
          id: 2,
          name: 'สมหญิง ดีใจ',
          email: 'somying@example.com',
          age: 22,
        );

        // Assert - ตรวจสอบผลลัพธ์
        expect(user.id, equals(2));
        expect(user.name, equals('สมหญิง ดีใจ'));
        expect(user.email, equals('somying@example.com'));
        expect(user.age, equals(22));
        expect(user.isActive, isTrue); // ค่า default
      });

      test('should create user with custom isActive value', () {
        // Arrange & Act
        final user = User(
          id: 3,
          name: 'สมศักดิ์ หาสุข',
          email: 'somsak@example.com',
          age: 30,
          isActive: false,
        );

        // Assert
        expect(user.isActive, isFalse);
      });
    });

    group('Getter Tests', () {
      test('isAdult should return true for age >= 18', () {
        // Arrange
        final adultUser = User(
          id: 1,
          name: 'Adult User',
          email: 'adult@example.com',
          age: 20,
        );

        // Act & Assert
        expect(adultUser.isAdult, isTrue);
      });

      test('isAdult should return false for age < 18', () {
        // Arrange
        final childUser = User(
          id: 2,
          name: 'Child User',
          email: 'child@example.com',
          age: 15,
        );

        // Act & Assert
        expect(childUser.isAdult, isFalse);
      });

      test('isAdult should return true for exactly age 18', () {
        // Arrange
        final eighteenUser = User(
          id: 3,
          name: 'Eighteen User',
          email: 'eighteen@example.com',
          age: 18,
        );

        // Act & Assert
        expect(eighteenUser.isAdult, isTrue);
      });

      test('isValidEmail should return true for valid email', () {
        // Arrange
        final validEmailUser = User(
          id: 1,
          name: 'Valid User',
          email: 'valid.email@example.com',
          age: 25,
        );

        // Act & Assert
        expect(validEmailUser.isValidEmail, isTrue);
      });

      test('isValidEmail should return false for invalid email', () {
        // Arrange
        final invalidEmailUser = User(
          id: 2,
          name: 'Invalid User',
          email: 'invalid-email',
          age: 25,
        );

        // Act & Assert
        expect(invalidEmailUser.isValidEmail, isFalse);
      });

      test('isAdult should return false for age 17 (boundary -1)', () {
        final user = User(
          id: 4,
          name: 'Boundary User',
          email: 'boundary@example.com',
          age: 17,
        );
        expect(user.isAdult, isFalse);
      });

      test('isValidEmail should handle various edge cases', () {
        final emailCases = {
          'user@sub.domain.com': true,
          'a@b.co': true,
          'user@domain': false,
          '@domain.com': false,
          'user@': false,
          '': false,
          'user@.com': false,
          'user name@domain.com': false,
        };

        for (final entry in emailCases.entries) {
          final user = User(id: 99, name: 'Test', email: entry.key, age: 20);
          expect(
            user.isValidEmail,
            entry.value,
            reason: 'Email "${entry.key}" should be ${entry.value}',
          );
        }
      });
    });

    group('Method Tests', () {
      test('toMap should convert user to Map correctly', () {
        // Act
        final userMap = testUser.toMap();

        // Assert
        expect(userMap, isA<Map<String, dynamic>>());
        expect(userMap['id'], equals(testUser.id));
        expect(userMap['name'], equals(testUser.name));
        expect(userMap['email'], equals(testUser.email));
        expect(userMap['age'], equals(testUser.age));
        expect(userMap['isActive'], equals(testUser.isActive));
      });

      test('fromMap should create user from Map correctly', () {
        // Arrange
        final userMap = {
          'id': 10,
          'name': 'Map User',
          'email': 'map@example.com',
          'age': 28,
          'isActive': false,
        };

        // Act
        final user = User.fromMap(userMap);

        // Assert
        expect(user.id, equals(10));
        expect(user.name, equals('Map User'));
        expect(user.email, equals('map@example.com'));
        expect(user.age, equals(28));
        expect(user.isActive, isFalse);
      });

      test('fromMap should handle missing fields with defaults', () {
        // Arrange - Map ที่ขาดบางฟิลด์
        final incompleteMap = {
          'name': 'Incomplete User',
          'email': 'incomplete@example.com',
        };

        // Act
        final user = User.fromMap(incompleteMap);

        // Assert
        expect(user.id, equals(0)); // ค่า default
        expect(user.name, equals('Incomplete User'));
        expect(user.email, equals('incomplete@example.com'));
        expect(user.age, equals(0)); // ค่า default
        expect(user.isActive, isTrue); // ค่า default
      });

      test('fromMap should handle empty Map', () {
        final user = User.fromMap({});

        expect(user.id, equals(0));
        expect(user.name, equals(''));
        expect(user.email, equals(''));
        expect(user.age, equals(0));
        expect(user.isActive, isTrue);
      });

      test('toMap and fromMap should be reversible (round-trip)', () {
        final original = User(
          id: 42,
          name: 'Round Trip',
          email: 'round@trip.com',
          age: 33,
          isActive: false,
        );

        final restored = User.fromMap(original.toMap());

        expect(restored, equals(original));
      });

      test('copyWith should create new user with modified fields', () {
        // Act
        final modifiedUser = testUser.copyWith(name: 'สมชาย แก้ไข', age: 26);

        // Assert
        expect(modifiedUser.id, equals(testUser.id)); // ไม่เปลี่ยน
        expect(modifiedUser.name, equals('สมชาย แก้ไข')); // เปลี่ยน
        expect(modifiedUser.email, equals(testUser.email)); // ไม่เปลี่ยน
        expect(modifiedUser.age, equals(26)); // เปลี่ยน
        expect(modifiedUser.isActive, equals(testUser.isActive)); // ไม่เปลี่ยน
      });

      test('copyWith should not modify original user', () {
        // Arrange
        final originalName = testUser.name;
        final originalAge = testUser.age;

        // Act
        testUser.copyWith(name: 'New Name', age: 99);

        // Assert - ตรวจสอบว่า object เดิมไม่เปลี่ยนแปลง
        expect(testUser.name, equals(originalName));
        expect(testUser.age, equals(originalAge));
      });

      test('copyWith should work when changing ALL fields at once', () {
        // Arrange & Act — เปลี่ยนทุก field พร้อมกัน เพื่อยืนยันว่าทุก parameter ทำงานอิสระ
        final fullyModified = testUser.copyWith(
          id: 999,
          name: 'Completely New',
          email: 'new@email.com',
          age: 50,
          isActive: false,
        );

        // Assert
        expect(fullyModified.id, equals(999));
        expect(fullyModified.name, equals('Completely New'));
        expect(fullyModified.email, equals('new@email.com'));
        expect(fullyModified.age, equals(50));
        expect(fullyModified.isActive, isFalse);
      });
    });

    group('Equality Tests', () {
      test('should be equal when all properties are same', () {
        // Arrange
        final user1 = User(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          age: 25,
          isActive: true,
        );

        final user2 = User(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          age: 25,
          isActive: true,
        );

        // Act & Assert
        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when any property is different', () {
        // Arrange
        final user1 = User(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          age: 25,
          isActive: true,
        );

        final user2 = User(
          id: 2, // แตกต่าง
          name: 'Test User',
          email: 'test@example.com',
          age: 25,
          isActive: true,
        );

        // Act & Assert
        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal to non-User object', () {
        expect(testUser == 'not a user', isFalse);
        expect(testUser == 42, isFalse);
      });

      test('hashCode should differ for different users', () {
        final user1 = User(id: 1, name: 'User A', email: 'a@test.com', age: 20);
        final user2 = User(id: 2, name: 'User B', email: 'b@test.com', age: 30);
        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });

      test('should be identical when same reference', () {
        // Act & Assert
        expect(identical(testUser, testUser), isTrue);
      });
    });

    group('toString Tests', () {
      test('toString should contain all user information', () {
        // Act
        final userString = testUser.toString();

        // Assert
        expect(userString, contains('User('));
        expect(userString, contains('id: ${testUser.id}'));
        expect(userString, contains('name: ${testUser.name}'));
        expect(userString, contains('email: ${testUser.email}'));
        expect(userString, contains('age: ${testUser.age}'));
        expect(userString, contains('isActive: ${testUser.isActive}'));
      });
    });
  });
}
