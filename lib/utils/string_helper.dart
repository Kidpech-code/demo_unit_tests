import 'dart:convert';

/// คลาส Utility สำหรับจัดการ String, การ Validation, และ Transformation
///
/// ## ใช้ทำอะไร?
/// รวมฟังก์ชัน String ที่ใช้บ่อยไว้ในที่เดียว:
/// - **Validation** — ตรวจสอบ email, เบอร์โทรไทย, รหัสผ่าน
/// - **Transformation** — capitalize, title case, truncate, reverse
/// - **Parsing** — JSON parsing, word counting
///
/// ## แนวคิดที่สอน
/// - **Null Safety Testing** — ฟังก์ชัน `isEmpty`/`isNotEmpty` รับ `String?`
///   → ต้องทดสอบกรณี null, "", " " (whitespace only)
/// - **RegExp Testing** — ทดสอบ pattern matching กับ valid/invalid inputs
/// - **Edge Cases** — empty string, very long string, special characters, emoji
/// - **Thai-specific Validation** — เบอร์โทรไทย (06x/08x/09x)
///
/// ## ต่อยอดได้อย่างไร?
/// - เพิ่ม `isValidThaiIdCard()` ตรวจเลขบัตรประชาชน
/// - เพิ่ม `maskEmail()`, `maskPhone()` สำหรับ privacy
/// - ใช้ extension methods แทน static methods
class StringHelper {
  /// ตรวจสอบว่า string ว่างเปล่าหรือไม่ — รองรับ **null safety**
  ///
  /// ## กรณีที่เป็น true
  /// - `null` → true
  /// - `""` (empty) → true
  /// - `"   "` (whitespace only) → true
  ///
  /// ## แนวคิด Testing
  /// ทดสอบทุกกรณีข้างต้น + กรณี false เช่น "text"
  static bool isEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// ตรวจสอบว่า string ไม่ว่างเปล่า — ตรงข้ามกับ [isEmpty]
  static bool isNotEmpty(String? text) {
    return !isEmpty(text);
  }

  /// แปลงตัวอักษรตัวแรกเป็นพิมพ์ใหญ่ ที่เหลือพิมพ์เล็ก
  ///
  /// ```dart
  /// StringHelper.capitalize('hello WORLD') // 'Hello world'
  /// ```
  ///
  /// ## Edge Cases ที่ต้องทดสอบ
  /// - empty string → return เดิม
  /// - ตัวเดียว "a" → "A"
  /// - ภาษาไทย → ไม่มี upper/lower case (ไม่เปลี่ยน)
  static String capitalize(String text) {
    if (isEmpty(text)) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// แปลงข้อความเป็น Title Case — ทุกคำขึ้นต้นตัวใหญ่
  ///
  /// ```dart
  /// StringHelper.toTitleCase('hello world') // 'Hello World'
  /// ```
  static String toTitleCase(String text) {
    if (isEmpty(text)) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// ลบ whitespace ทั้งหมดออกจากข้อความ (รวม non-breaking space)
  ///
  /// ใช้ RegExp `[\s\u00A0]+` ครอบคลุมทั้ง space, tab, newline, และ non-breaking space
  static String removeWhitespace(String text) {
    return text.replaceAll(RegExp(r'[\s\u00A0]+'), '');
  }

  /// ตรวจสอบว่าเป็น email ที่ถูกต้องหรือไม่
  ///
  /// ## RegExp Pattern: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
  /// - ก่อน @ → ตัวอักษร ตัวเลข . _ % + -
  /// - หลัง @ → domain.ext (ext อย่างน้อย 2 ตัวอักษร)
  ///
  /// ## ทดสอบ
  /// - Valid: test@mail.com, user.name+tag@domain.co.th
  /// - Invalid: @mail.com, test@, test@.com, "" (empty)
  static bool isValidEmail(String email) {
    if (isEmpty(email)) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// ตรวจสอบว่าเป็นหมายเลขโทรศัพท์ไทยที่ถูกต้องหรือไม่
  ///
  /// ## รูปแบบที่รองรับ
  /// - `06x-xxx-xxxx` / `08x-xxx-xxxx` / `09x-xxx-xxxx`
  /// - `+66-6x-xxx-xxxx` / `+66-8x-xxx-xxxx` / `+66-9x-xxx-xxxx`
  /// - รองรับทั้งแบบมี/ไม่มี `-`
  ///
  /// ## แนวคิด Testing: Thai-specific Validation
  /// ต้องทดสอบรูปแบบเฉพาะของเบอร์โทรไทยที่เริ่มด้วย 06, 08, 09
  static bool isValidThaiPhoneNumber(String phone) {
    if (isEmpty(phone)) return false;
    // รูปแบบ: 06x/08x/09x-xxx-xxxx หรือ +66-6x/8x/9x-xxx-xxxx
    return RegExp(
      r'^(\+66[689]|0[689])\d{8}$',
    ).hasMatch(phone.replaceAll('-', ''));
  }

  /// ตรวจสอบว่าเป็นรหัสผ่านที่แข็งแรงหรือไม่
  ///
  /// ## เงื่อนไข (ต้องผ่านทุกข้อ)
  /// 1. ความยาว >= 8 ตัวอักษร
  /// 2. มีตัวพิมพ์ใหญ่ (A-Z)
  /// 3. มีตัวพิมพ์เล็ก (a-z)
  /// 4. มีตัวเลข (0-9)
  /// 5. มีสัญลักษณ์พิเศษ (!@#$%^&*...)
  ///
  /// ## ทดสอบ: ทดสอบแยกทีละเงื่อนไข
  /// - ขาดตัวใหญ่ → false, ขาดตัวเล็ก → false, ขาดตัวเลข → false ฯลฯ
  static bool isStrongPassword(String password) {
    if (isEmpty(password) || password.length < 8) return false;

    bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    bool hasDigit = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar;
  }

  /// นับจำนวนคำในข้อความ — แยกด้วย whitespace
  ///
  /// ทดสอบ: empty → 0, "hello" → 1, "hello world" → 2
  /// ทดสอบ Edge: whitespace หลายตัว, tab, newline
  static int countWords(String text) {
    if (isEmpty(text)) return 0;
    // Handle newlines and tabs as word separators
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  /// ตัดข้อความให้ไม่เกินความยาวที่กำหนด พร้อม suffix (default: "...")
  ///
  /// ```dart
  /// StringHelper.truncate('Hello World', 8) // 'Hello...'
  /// ```
  ///
  /// ## Edge Cases
  /// - ข้อความสั้นกว่า maxLength → return เดิม
  /// - maxLength < suffix.length → return suffix
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    int cutLength = maxLength - suffix.length;
    if (cutLength <= 0) return suffix;
    return text.substring(0, cutLength) + suffix;
  }

  /// แปลง JSON String เป็น Map — return `null` ถ้า parse ไม่ได้
  ///
  /// ## แนวคิด Testing: Error Handling ที่ return null แทน throw
  /// - valid JSON → Map
  /// - invalid JSON → null (ไม่ throw)
  /// - empty string → null
  static Map<String, dynamic>? parseJson(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// สลับตำแหน่งตัวอักษร — "hello" → "olleh"
  static String reverse(String text) {
    return text.split('').reversed.join('');
  }

  /// ตรวจสอบว่าเป็น Palindrome หรือไม่ (อ่านจากหน้าและหลังเหมือนกัน)
  ///
  /// ลบ whitespace และแปลงเป็น lowercase ก่อนเปรียบเทียบ
  /// เช่น: "racecar" → true, "Race Car" → true
  static bool isPalindrome(String text) {
    if (isEmpty(text)) return false;
    String cleaned = removeWhitespace(text.toLowerCase());
    return cleaned == reverse(cleaned);
  }

  /// แทนที่อิโมจิด้วยข้อความ — default เป็น "[emoji]"
  ///
  /// ## ข้อจำกัด
  /// ใช้ RegExp ครอบคลุมอิโมจิส่วนใหญ่แต่ไม่ทั้งหมด
  /// ใช้ flag `unicode: true` สำหรับ Unicode Emoji Ranges
  static String replaceEmojis(String text, {String replacement = '[emoji]'}) {
    // Simple emoji pattern - อาจไม่ครอบคลุมอีโมจิทั้งหมด
    return text.replaceAll(
      RegExp(
        r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]',
        unicode: true,
      ),
      replacement,
    );
  }
}
