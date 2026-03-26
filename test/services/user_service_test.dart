import 'package:flutter_test/flutter_test.dart';
import 'package:demo_unit_tests/services/user_service.dart';
import 'package:demo_unit_tests/models/user.dart';

void main() {
  group('UserService Tests', () {
    late UserService userService;
    late User testUser1;
    late User testUser2;
    late User testUser3;

    setUp(() {
      // จัดเตรียมข้อมูลทดสอบก่อนแต่ละ test case
      userService = UserService();

      testUser1 = User(
        id: 1,
        name: 'สมชาย ใจดี',
        email: 'somchai@example.com',
        age: 25,
        isActive: true,
      );

      testUser2 = User(
        id: 2,
        name: 'สมหญิง สุขใจ',
        email: 'somying@example.com',
        age: 17,
        isActive: true,
      );

      testUser3 = User(
        id: 3,
        name: 'สมศักดิ์ ร่วมงาน',
        email: 'somsak@example.com',
        age: 30,
        isActive: false,
      );
    });

    group('Add User Tests', () {
      test('should add user successfully', () {
        // Act
        userService.addUser(testUser1);

        // Assert
        expect(userService.getTotalUsers(), equals(1));
        expect(userService.findUserById(1), equals(testUser1));
      });

      test('should throw exception when adding duplicate user ID', () {
        // Arrange
        userService.addUser(testUser1);

        // Act & Assert
        expect(
          () => userService.addUser(testUser1),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => userService.addUser(testUser1),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message.contains('User with ID 1 already exists'),
            ),
          ),
        );
      });

      test('should allow adding multiple users with different IDs', () {
        // Act
        userService.addUser(testUser1);
        userService.addUser(testUser2);
        userService.addUser(testUser3);

        // Assert
        expect(userService.getTotalUsers(), equals(3));
      });
    });

    group('Find User Tests', () {
      setUp(() {
        userService.addUser(testUser1);
        userService.addUser(testUser2);
        userService.addUser(testUser3);
      });

      test('findUserById should return correct user', () {
        // Act
        final foundUser = userService.findUserById(2);

        // Assert
        expect(foundUser, isNotNull);
        expect(foundUser, equals(testUser2));
      });

      test('findUserById should return null for non-existent user', () {
        // Act
        final foundUser = userService.findUserById(999);

        // Assert
        expect(foundUser, isNull);
      });

      test('findUserByEmail should return correct user', () {
        // Act
        final foundUser = userService.findUserByEmail('somying@example.com');

        // Assert
        expect(foundUser, isNotNull);
        expect(foundUser, equals(testUser2));
      });

      test('findUserByEmail should return null for non-existent email', () {
        // Act
        final foundUser = userService.findUserByEmail('notfound@example.com');

        // Assert
        expect(foundUser, isNull);
      });
    });

    group('Remove User Tests', () {
      setUp(() {
        userService.addUser(testUser1);
        userService.addUser(testUser2);
        userService.addUser(testUser3);
      });

      test('removeUser should remove user successfully', () {
        // Act
        final removed = userService.removeUser(2);

        // Assert
        expect(removed, isTrue);
        expect(userService.getTotalUsers(), equals(2));
        expect(userService.findUserById(2), isNull);
      });

      test('removeUser should return false for non-existent user', () {
        // Act
        final removed = userService.removeUser(999);

        // Assert
        expect(removed, isFalse);
        expect(userService.getTotalUsers(), equals(3));
      });
    });

    group('Update User Tests', () {
      setUp(() {
        userService.addUser(testUser1);
        userService.addUser(testUser2);
      });

      test('updateUser should update existing user', () {
        // Arrange
        final updatedUser = testUser1.copyWith(name: 'สมชาย แก้ไข', age: 26);

        // Act
        final updated = userService.updateUser(1, updatedUser);

        // Assert
        expect(updated, isTrue);
        final foundUser = userService.findUserById(1);
        expect(foundUser?.name, equals('สมชาย แก้ไข'));
        expect(foundUser?.age, equals(26));
        expect(foundUser?.id, equals(1)); // ID ไม่เปลี่ยน
      });

      test('updateUser should return false for non-existent user', () {
        // Arrange
        final updatedUser = testUser1.copyWith(name: 'New Name');

        // Act
        final updated = userService.updateUser(999, updatedUser);

        // Assert
        expect(updated, isFalse);
      });
    });

    group('Get Users Tests', () {
      setUp(() {
        userService.addUser(testUser1); // age: 25, active: true
        userService.addUser(testUser2); // age: 17, active: true
        userService.addUser(testUser3); // age: 30, active: false
      });

      test('getAllUsers should return all users', () {
        // Act
        final allUsers = userService.getAllUsers();

        // Assert
        expect(allUsers.length, equals(3));
        expect(allUsers, contains(testUser1));
        expect(allUsers, contains(testUser2));
        expect(allUsers, contains(testUser3));
      });

      test('getAllUsers should return unmodifiable list', () {
        // Act
        final allUsers = userService.getAllUsers();

        // Assert - พยายามแก้ไข list ที่ได้มา
        expect(() => allUsers.add(testUser1), throwsA(isA<UnsupportedError>()));
      });

      test('getAdultUsers should return only users >= 18', () {
        // Act
        final adultUsers = userService.getAdultUsers();

        // Assert
        expect(adultUsers.length, equals(2));
        expect(adultUsers, contains(testUser1)); // age: 25
        expect(adultUsers, contains(testUser3)); // age: 30
        expect(adultUsers, isNot(contains(testUser2))); // age: 17
      });

      test('getActiveUsers should return only active users', () {
        // Act
        final activeUsers = userService.getActiveUsers();

        // Assert
        expect(activeUsers.length, equals(2));
        expect(activeUsers, contains(testUser1)); // active: true
        expect(activeUsers, contains(testUser2)); // active: true
        expect(activeUsers, isNot(contains(testUser3))); // active: false
      });

      test('getUsersByAgeRange should return users in age range', () {
        // Act
        final usersInRange = userService.getUsersByAgeRange(20, 27);

        // Assert
        expect(usersInRange.length, equals(1));
        expect(usersInRange, contains(testUser1)); // age: 25
      });

      test('getUsersByAgeRange should throw exception for invalid range', () {
        // Act & Assert
        expect(
          () => userService.getUsersByAgeRange(-1, 50),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => userService.getUsersByAgeRange(50, 20),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('getUsersByAgeRange should include exact boundary ages', () {
        // Act
        final usersInRange = userService.getUsersByAgeRange(25, 30);

        // Assert - testUser1 (age:25) and testUser3 (age:30) are on boundaries
        expect(usersInRange.length, equals(2));
        expect(usersInRange, contains(testUser1));
        expect(usersInRange, contains(testUser3));
      });

      test('getUsersByAgeRange should work when min equals max', () {
        // Act
        final usersInRange = userService.getUsersByAgeRange(25, 25);

        // Assert - only testUser1 (age:25) matches exactly
        expect(usersInRange.length, equals(1));
        expect(usersInRange.first, equals(testUser1));
      });
    });

    group('Utility Methods Tests', () {
      test('hasUsers should return false when empty', () {
        // Act & Assert
        expect(userService.hasUsers(), isFalse);
      });

      test('hasUsers should return true when has users', () {
        // Arrange
        userService.addUser(testUser1);

        // Act & Assert
        expect(userService.hasUsers(), isTrue);
      });

      test('getTotalUsers should return correct count', () {
        // Act & Assert
        expect(userService.getTotalUsers(), equals(0));

        userService.addUser(testUser1);
        expect(userService.getTotalUsers(), equals(1));

        userService.addUser(testUser2);
        expect(userService.getTotalUsers(), equals(2));
      });

      test('clearAllUsers should remove all users', () {
        // Arrange
        userService.addUser(testUser1);
        userService.addUser(testUser2);
        expect(userService.getTotalUsers(), equals(2));

        // Act
        userService.clearAllUsers();

        // Assert
        expect(userService.getTotalUsers(), equals(0));
        expect(userService.hasUsers(), isFalse);
      });

      test('toggleUserStatus should change user active status', () {
        // Arrange
        userService.addUser(testUser1);
        expect(testUser1.isActive, isTrue);

        // Act
        final toggled = userService.toggleUserStatus(1);

        // Assert
        expect(toggled, isTrue);
        final updatedUser = userService.findUserById(1);
        expect(updatedUser?.isActive, isFalse);
      });

      test('toggleUserStatus should return false for non-existent user', () {
        // Act
        final toggled = userService.toggleUserStatus(999);

        // Assert
        expect(toggled, isFalse);
      });

      test('toggleUserStatus should toggle back to original status', () {
        // Arrange
        userService.addUser(testUser1);
        expect(userService.findUserById(1)?.isActive, isTrue);

        // Act - toggle twice
        userService.toggleUserStatus(1);
        expect(userService.findUserById(1)?.isActive, isFalse);

        userService.toggleUserStatus(1);
        expect(userService.findUserById(1)?.isActive, isTrue);
      });
    });

    group('Integration Tests', () {
      test('should handle complete user lifecycle', () {
        // 1. เริ่มต้นด้วย service ว่าง
        expect(userService.getTotalUsers(), equals(0));
        expect(userService.hasUsers(), isFalse);

        // 2. เพิ่มผู้ใช้
        userService.addUser(testUser1);
        expect(userService.getTotalUsers(), equals(1));
        expect(userService.hasUsers(), isTrue);

        // 3. ค้นหาผู้ใช้
        final foundUser = userService.findUserById(1);
        expect(foundUser, isNotNull);
        expect(foundUser?.name, equals('สมชาย ใจดี'));

        // 4. อัปเดตผู้ใช้
        final updatedUser = testUser1.copyWith(name: 'สมชาย อัปเดต');
        final updated = userService.updateUser(1, updatedUser);
        expect(updated, isTrue);

        // 5. ตรวจสอบการอัปเดต
        final afterUpdate = userService.findUserById(1);
        expect(afterUpdate?.name, equals('สมชาย อัปเดต'));

        // 6. ลบผู้ใช้
        final removed = userService.removeUser(1);
        expect(removed, isTrue);
        expect(userService.getTotalUsers(), equals(0));
      });

      test('should handle multiple users with different filters', () {
        // Arrange
        userService.addUser(testUser1); // adult, active
        userService.addUser(testUser2); // minor, active
        userService.addUser(testUser3); // adult, inactive

        // Act & Assert
        expect(userService.getTotalUsers(), equals(3));
        expect(userService.getAdultUsers().length, equals(2));
        expect(userService.getActiveUsers().length, equals(2));

        final adultsAndActive = userService
            .getAdultUsers()
            .where((u) => u.isActive)
            .toList();
        expect(adultsAndActive.length, equals(1));
        expect(adultsAndActive.first, equals(testUser1));
      });
    });

    group('Error Handling Tests', () {
      test('should maintain data integrity after exceptions', () {
        // Arrange
        userService.addUser(testUser1);

        // Act - พยายามเพิ่มผู้ใช้ที่มี ID ซ้ำ
        expect(
          () => userService.addUser(testUser1),
          throwsA(isA<ArgumentError>()),
        );

        // Assert - ข้อมูลเดิมยังคงอยู่
        expect(userService.getTotalUsers(), equals(1));
        expect(userService.findUserById(1), equals(testUser1));
      });

      test('should handle edge cases gracefully', () {
        // Act & Assert
        expect(userService.removeUser(0), isFalse);
        expect(userService.findUserById(-1), isNull);
        expect(userService.findUserByEmail(''), isNull);
      });
    });
  });
}
