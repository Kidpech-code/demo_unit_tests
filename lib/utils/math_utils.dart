import 'dart:math';

/// คลาส Utility สำหรับฟังก์ชันคณิตศาสตร์ (Math Utilities)
///
/// ## ใช้ทำอะไร?
/// รวมฟังก์ชันคำนวณทางคณิตศาสตร์ทั้งหมดไว้ในที่เดียว
/// ทุกฟังก์ชันเป็น `static` — เรียกใช้ได้เลยโดยไม่ต้องสร้าง instance
///
/// ```dart
/// final result = MathUtils.add(2, 3); // 5
/// final isPrime = MathUtils.isPrime(7); // true
/// ```
///
/// ## แนวคิดที่สอน
/// - **Pure Function Testing** — ฟังก์ชันที่ไม่มี side effect, ใส่ input เดิมจะได้ output เดิมเสมอ
///   → ทดสอบง่ายที่สุด เพราะไม่ต้อง mock อะไร
/// - **Exception Testing** — ฟังก์ชัน `divide`, `factorial` จะ throw error ถ้าใส่ค่าผิด
///   → ใช้ `expect(() => fn(), throwsA(isA<ArgumentError>()))` ทดสอบ
/// - **Boundary Value Analysis** — ทดสอบค่าขอบ เช่น 0, 1, -1, ค่าที่ใหญ่มาก
/// - **Generics Testing** — `max<T>`, `min<T>` ใช้กับทุก type ที่เป็น Comparable
///
/// ## ต่อยอดได้อย่างไร?
/// - เพิ่มฟังก์ชัน `gcd()`, `lcm()`, `fibonacci()`
/// - เพิ่ม extension method บน `int` หรือ `double` แทน static methods
/// - รองรับ BigInt สำหรับตัวเลขขนาดใหญ่
class MathUtils {
  /// บวกเลขสองจำนวน — ใช้สอน Pure Function Testing
  ///
  /// Test: `expect(MathUtils.add(2, 3), equals(5))`
  static int add(int a, int b) => a + b;

  /// ลบเลขสองจำนวน — ควรทดสอบกรณีผลลัพธ์ติดลบด้วย
  static int subtract(int a, int b) => a - b;

  /// คูณเลขสองจำนวน — ทดสอบ: คูณด้วย 0, คูณค่าลบ, overflow
  static int multiply(int a, int b) => a * b;

  /// หารเลขสองจำนวน — **throw ArgumentError** ถ้าหารด้วย 0
  ///
  /// ## แนวคิด Testing: Exception Testing
  /// ```dart
  /// expect(
  ///   () => MathUtils.divide(10, 0),
  ///   throwsA(isA<ArgumentError>()),
  /// );
  /// ```
  /// ใช้ `throwsA()` ตรวจว่า throw exception ชนิดที่ถูกต้อง
  /// ใช้ `.having()` ตรวจ message ข้างใน
  static double divide(double a, double b) {
    if (b == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return a / b;
  }

  /// คำนวณเลขยกกำลัง — ใช้ `dart:math` pow()
  ///
  /// ทดสอบ: ยกกำลัง 0, ยกกำลัง 1, ยกกำลังลบ (ได้เศษส่วน)
  static double power(double base, double exponent) {
    return pow(base, exponent).toDouble();
  }

  /// หาค่าสัมบูรณ์ (absolute value) — ทำให้ค่าลบเป็นบวก
  ///
  /// รับ `num` (ทั้ง int และ double) — ทดสอบทั้ง 2 type
  static num absolute(num number) {
    return number.abs();
  }

  /// ตรวจสอบว่าเป็นเลขคู่หรือไม่ — ใช้ modulo operator `%`
  ///
  /// ทดสอบ Boundary: 0 (คู่), -2 (คู่), 1 (ไม่ใช่)
  static bool isEven(int number) => number % 2 == 0;

  /// ตรวจสอบว่าเป็นเลขคี่หรือไม่ — ตรงข้ามกับ [isEven]
  static bool isOdd(int number) => number % 2 != 0;

  /// ตรวจสอบว่าเป็นจำนวนเฉพาะ (Prime Number) หรือไม่
  ///
  /// ## Algorithm
  /// - ตัวเลข < 2 ไม่ใช่จำนวนเฉพาะ
  /// - 2 เป็นจำนวนเฉพาะคู่ตัวเดียว
  /// - ตรวจหารลงตัวถึง √n เท่านั้น (ประหยัดเวลา)
  ///
  /// ## ทดสอบ Boundary Value
  /// - ค่าน้อยกว่า 2: false
  /// - 2: true (กรณีพิเศษ — จำนวนเฉพาะคู่)
  /// - เลขคู่ > 2: false
  /// - เลขคี่ที่ไม่ใช่เฉพาะ: 9, 15, 25
  static bool isPrime(int number) {
    if (number < 2) return false;
    if (number == 2) return true;
    if (number % 2 == 0) return false;

    for (int i = 3; i * i <= number; i += 2) {
      if (number % i == 0) return false;
    }
    return true;
  }

  /// คำนวณ Factorial (n!) — **recursive function**
  ///
  /// ## ข้อจำกัด
  /// - n < 0 → throw [ArgumentError] (ไม่นิยาม factorial ของค่าลบ)
  /// - n ใหญ่เกินไป → StackOverflow (recursive limit)
  ///
  /// ## ทดสอบ
  /// - 0! = 1, 1! = 1 (base cases)
  /// - 5! = 120 (ค่าปกติ)
  /// - ค่าลบ → expect throwsA
  static int factorial(int n) {
    if (n < 0) {
      throw ArgumentError('Factorial is not defined for negative numbers');
    }
    if (n == 0 || n == 1) return 1;
    return n * factorial(n - 1);
  }

  /// หาค่าสูงสุดในลิสต์ — ใช้ **Generics** `<T extends Comparable<T>>`
  ///
  /// ## แนวคิด Testing: Generics
  /// ทดสอบกับหลาย type: `List<int>`, `List<double>`, `List<String>`
  /// ทดสอบ list ว่าง → throwsA
  ///
  /// ```dart
  /// expect(MathUtils.max([3, 1, 2]), equals(3));
  /// expect(() => MathUtils.max([]), throwsA(isA<ArgumentError>()));
  /// ```
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

  /// หาค่าต่ำสุดในลิสต์ — ตรงข้ามกับ [max]
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

  /// คำนวณค่าเฉลี่ย (Average/Mean) — ใช้ `fold` รวมค่าแล้วหารจำนวน
  ///
  /// ## ทดสอบ
  /// - list ว่าง → throwsA
  /// - list ตัวเดียว → ค่าเฉลี่ย = ตัวเอง
  /// - list หลายตัว → ตรวจด้วย `closeTo()` สำหรับทศนิยม
  static double average(List<num> numbers) {
    if (numbers.isEmpty) {
      throw ArgumentError('List cannot be empty');
    }
    num sum = numbers.fold<num>(0, (previous, element) => previous + element);
    return sum / numbers.length;
  }
}
