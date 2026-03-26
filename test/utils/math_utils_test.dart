/// ===================================================================
/// MathUtils Unit Tests — ทดสอบ Pure Functions
/// ===================================================================
///
/// ## ไฟล์นี้สอนอะไร?
/// ทดสอบ static pure functions — ฟังก์ชันที่ input เดิม → output เดิมเสมอ
/// ไม่มี side effect, ไม่ต้อง mock อะไร → **ทดสอบง่ายที่สุด**
///
/// ## แนวคิดที่ใช้
/// - **Pure Function Testing** — ไม่มี dependency, ไม่ต้อง setUp
/// - **Exception Testing** — `throwsA(isA<ArgumentError>())`
/// - **Boundary Value** — ทดสอบ 0, 1, -1, ค่าใหญ่มาก
/// - **Generics Testing** — ทดสอบ `max<T>`, `min<T>` กับหลาย type
/// - **closeTo()** — สำหรับเปรียบเทียบ double ที่มีทศนิยม
///
/// ## วิธีรัน
/// ```bash
/// flutter test test/utils/math_utils_test.dart
/// ```
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_unit_tests/utils/math_utils.dart';

void main() {
  group('MathUtils Tests', () {
    group('Basic Arithmetic Operations', () {
      test('add should return correct sum', () {
        // Act & Assert
        expect(MathUtils.add(2, 3), equals(5));
        expect(MathUtils.add(-1, 1), equals(0));
        expect(MathUtils.add(0, 0), equals(0));
        expect(MathUtils.add(-5, -3), equals(-8));
      });

      test('subtract should return correct difference', () {
        // Act & Assert
        expect(MathUtils.subtract(5, 3), equals(2));
        expect(MathUtils.subtract(1, 1), equals(0));
        expect(MathUtils.subtract(-1, -1), equals(0));
        expect(MathUtils.subtract(0, 5), equals(-5));
      });

      test('multiply should return correct product', () {
        // Act & Assert
        expect(MathUtils.multiply(3, 4), equals(12));
        expect(MathUtils.multiply(0, 100), equals(0));
        expect(MathUtils.multiply(-2, 3), equals(-6));
        expect(MathUtils.multiply(-2, -3), equals(6));
      });

      test('divide should return correct quotient', () {
        // Act & Assert
        expect(MathUtils.divide(10, 2), equals(5.0));
        expect(MathUtils.divide(7, 2), equals(3.5));
        expect(MathUtils.divide(-10, 2), equals(-5.0));
        expect(MathUtils.divide(0, 5), equals(0.0));
      });

      test('divide should throw exception when dividing by zero', () {
        // Act & Assert
        expect(() => MathUtils.divide(10, 0), throwsA(isA<ArgumentError>()));

        // ตรวจสอบข้อความ error
        expect(
          () => MathUtils.divide(10, 0),
          throwsA(
            predicate(
              (e) => e is ArgumentError && e.message == 'Cannot divide by zero',
            ),
          ),
        );
      });
    });

    group('Advanced Operations', () {
      test('power should calculate exponentiation correctly', () {
        // Act & Assert
        expect(MathUtils.power(2, 3), equals(8.0));
        expect(MathUtils.power(5, 0), equals(1.0));
        expect(MathUtils.power(3, 2), equals(9.0));
        expect(MathUtils.power(2, -1), equals(0.5));
      });

      test('absolute should return positive value', () {
        // Act & Assert
        expect(MathUtils.absolute(5), equals(5));
        expect(MathUtils.absolute(-5), equals(5));
        expect(MathUtils.absolute(0), equals(0));
        expect(MathUtils.absolute(-3.14), equals(3.14));
      });

      test('factorial should calculate correctly', () {
        // Act & Assert
        expect(MathUtils.factorial(0), equals(1));
        expect(MathUtils.factorial(1), equals(1));
        expect(MathUtils.factorial(5), equals(120));
        expect(MathUtils.factorial(3), equals(6));
        expect(MathUtils.factorial(10), equals(3628800));
      });

      test('factorial should throw exception for negative numbers', () {
        // Act & Assert
        expect(() => MathUtils.factorial(-1), throwsA(isA<ArgumentError>()));

        expect(
          () => MathUtils.factorial(-5),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message == 'Factorial is not defined for negative numbers',
            ),
          ),
        );
      });
    });

    group('Number Classification', () {
      test('isEven should identify even numbers correctly', () {
        // Act & Assert
        expect(MathUtils.isEven(2), isTrue);
        expect(MathUtils.isEven(0), isTrue);
        expect(MathUtils.isEven(-4), isTrue);
        expect(MathUtils.isEven(1), isFalse);
        expect(MathUtils.isEven(-3), isFalse);
      });

      test('isOdd should identify odd numbers correctly', () {
        // Act & Assert
        expect(MathUtils.isOdd(1), isTrue);
        expect(MathUtils.isOdd(3), isTrue);
        expect(MathUtils.isOdd(-5), isTrue);
        expect(MathUtils.isOdd(2), isFalse);
        expect(MathUtils.isOdd(0), isFalse);
      });

      test('isPrime should identify prime numbers correctly', () {
        // Act & Assert
        expect(MathUtils.isPrime(2), isTrue);
        expect(MathUtils.isPrime(3), isTrue);
        expect(MathUtils.isPrime(5), isTrue);
        expect(MathUtils.isPrime(7), isTrue);
        expect(MathUtils.isPrime(11), isTrue);
        expect(MathUtils.isPrime(97), isTrue);
        expect(MathUtils.isPrime(101), isTrue);

        expect(MathUtils.isPrime(1), isFalse);
        expect(MathUtils.isPrime(4), isFalse);
        expect(MathUtils.isPrime(6), isFalse);
        expect(MathUtils.isPrime(8), isFalse);
        expect(MathUtils.isPrime(9), isFalse);
        expect(MathUtils.isPrime(0), isFalse);
        expect(MathUtils.isPrime(-2), isFalse);
        expect(MathUtils.isPrime(100), isFalse);
      });
    });

    group('List Operations', () {
      test('max should find maximum value in list', () {
        // Arrange
        final numbers = [1, 5, 3, 9, 2];
        final negativeNumbers = [-1, -5, -3];
        final singleNumber = [42];

        // Act & Assert
        expect(MathUtils.max(numbers), equals(9));
        expect(MathUtils.max(negativeNumbers), equals(-1));
        expect(MathUtils.max(singleNumber), equals(42));
      });

      test('max should throw exception for empty list', () {
        // Arrange
        final emptyList = <int>[];

        // Act & Assert
        expect(() => MathUtils.max(emptyList), throwsA(isA<ArgumentError>()));
      });

      test('min should find minimum value in list', () {
        // Arrange
        final numbers = [1, 5, 3, 9, 2];
        final negativeNumbers = [-1, -5, -3];
        final singleNumber = [42];

        // Act & Assert
        expect(MathUtils.min(numbers), equals(1));
        expect(MathUtils.min(negativeNumbers), equals(-5));
        expect(MathUtils.min(singleNumber), equals(42));
      });

      test('min should throw exception for empty list', () {
        // Arrange
        final emptyList = <int>[];

        // Act & Assert
        expect(() => MathUtils.min(emptyList), throwsA(isA<ArgumentError>()));
      });

      test('average should calculate mean correctly', () {
        // Arrange
        final numbers = [2, 4, 6, 8, 10];
        final singleNumber = [5];
        final negativeNumbers = [-2, -4, -6];

        // Act & Assert
        expect(MathUtils.average(numbers), equals(6.0));
        expect(MathUtils.average(singleNumber), equals(5.0));
        expect(MathUtils.average(negativeNumbers), equals(-4.0));
      });

      test('average should throw exception for empty list', () {
        // Arrange
        final emptyList = <num>[];

        // Act & Assert
        expect(
          () => MathUtils.average(emptyList),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Edge Cases and Boundary Values', () {
      test('operations with zero', () {
        // Act & Assert
        expect(MathUtils.add(0, 0), equals(0));
        expect(MathUtils.multiply(100, 0), equals(0));
        expect(MathUtils.power(0, 2), equals(0.0));
        expect(MathUtils.absolute(0), equals(0));
      });

      test('operations with large numbers', () {
        // Act & Assert
        expect(MathUtils.add(1000000, 2000000), equals(3000000));
        expect(MathUtils.multiply(1000, 1000), equals(1000000));
      });

      test('mixed integer and double operations', () {
        // Arrange
        final mixedList = [1, 2.5, 3, 4.7];

        // Act & Assert
        expect(MathUtils.max(mixedList), equals(4.7));
        expect(MathUtils.min(mixedList), equals(1));
        expect(MathUtils.average(mixedList), closeTo(2.8, 0.1));
      });
    });

    group('Type Safety Tests', () {
      test('max should work with different comparable types', () {
        // Arrange
        final strings = ['apple', 'banana', 'cherry'];
        final dates = [
          DateTime(2023, 1, 1),
          DateTime(2024, 1, 1),
          DateTime(2022, 1, 1),
        ];

        // Act & Assert
        expect(MathUtils.max(strings), equals('cherry'));
        expect(MathUtils.max(dates), equals(DateTime(2024, 1, 1)));
      });

      test('min should work with different comparable types', () {
        // Arrange
        final strings = ['zebra', 'apple', 'banana'];

        // Act & Assert
        expect(MathUtils.min(strings), equals('apple'));
      });
    });
  });
}
