import 'dart:math';

/// คลาสสำหรับคำนวณทางคณิตศาสตร์
class MathUtils {
  /// บวกเลขสองจำนวน
  static int add(int a, int b) => a + b;

  /// ลบเลขสองจำนวน
  static int subtract(int a, int b) => a - b;

  /// คูณเลขสองจำนวน
  static int multiply(int a, int b) => a * b;

  /// หารเลขสองจำนวน (จะ throw exception ถ้าหารด้วย 0)
  static double divide(double a, double b) {
    if (b == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return a / b;
  }

  /// คำนวณเลขยกกำลัง
  static double power(double base, double exponent) {
    return pow(base, exponent).toDouble();
  }

  /// หาค่าสัมบูรณ์
  static num absolute(num number) {
    return number.abs();
  }

  /// ตรวจสอบว่าเป็นเลขคู่หรือไม่
  static bool isEven(int number) => number % 2 == 0;

  /// ตรวจสอบว่าเป็นเลขคี่หรือไม่
  static bool isOdd(int number) => number % 2 != 0;

  /// ตรวจสอบว่าเป็นจำนวนเฉพาะหรือไม่
  static bool isPrime(int number) {
    if (number < 2) return false;
    if (number == 2) return true;
    if (number % 2 == 0) return false;

    for (int i = 3; i * i <= number; i += 2) {
      if (number % i == 0) return false;
    }
    return true;
  }

  /// คำนวณแฟกทอเรียล
  static int factorial(int n) {
    if (n < 0) {
      throw ArgumentError('Factorial is not defined for negative numbers');
    }
    if (n == 0 || n == 1) return 1;
    return n * factorial(n - 1);
  }

  /// หาค่าสูงสุดในลิสต์
  static T max<T extends Comparable<T>>(List<T> numbers) {
    if (numbers.isEmpty) {
      throw ArgumentError('List cannot be empty');
    }
    T maxValue = numbers.first;
    for (T number in numbers) {
      if (number.compareTo(maxValue) > 0) {
        maxValue = number;
      }
    }
    return maxValue;
  }

  /// หาค่าต่ำสุดในลิสต์
  static T min<T extends Comparable<T>>(List<T> numbers) {
    if (numbers.isEmpty) {
      throw ArgumentError('List cannot be empty');
    }
    T minValue = numbers.first;
    for (T number in numbers) {
      if (number.compareTo(minValue) < 0) {
        minValue = number;
      }
    }
    return minValue;
  }

  /// คำนวณค่าเฉลี่ย
  static double average(List<num> numbers) {
    if (numbers.isEmpty) {
      throw ArgumentError('List cannot be empty');
    }
    num sum = numbers.fold<num>(0, (previous, element) => previous + element);
    return sum / numbers.length;
  }
}
