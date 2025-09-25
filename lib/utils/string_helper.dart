import 'dart:convert';

/// คลาสสำหรับจัดการ String และการ validation
class StringHelper {
  /// ตรวจสอบว่า string ว่างเปล่าหรือไม่
  static bool isEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// ตรวจสอบว่า string ไม่ว่างเปล่า
  static bool isNotEmpty(String? text) {
    return !isEmpty(text);
  }

  /// แปลงข้อความเป็นตัวพิมพ์ใหญ่คำแรก
  static String capitalize(String text) {
    if (isEmpty(text)) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// แปลงข้อความเป็น Title Case
  static String toTitleCase(String text) {
    if (isEmpty(text)) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// ลบ whitespace ออกจากข้อความ
  static String removeWhitespace(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[\n\t\r\u00A0]+'), '');
  }

  /// ตรวจสอบว่าเป็น email ที่ถูกต้องหรือไม่
  static bool isValidEmail(String email) {
    if (isEmpty(email)) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// ตรวจสอบว่าเป็นหมายเลขโทรศัพท์ไทยที่ถูกต้องหรือไม่
  static bool isValidThaiPhoneNumber(String phone) {
    if (isEmpty(phone)) return false;
    // รูปแบบ: 08x-xxx-xxxx หรือ 08xxxxxxxx หรือ +66-8x-xxx-xxxx
    return RegExp(r'^(\+66-?8|08)\d{8}$').hasMatch(phone.replaceAll('-', ''));
  }

  /// ตรวจสอบว่าเป็นรหัสผ่านที่แข็งแรงหรือไม่
  /// (อย่างน้อย 8 ตัวอักษร มีตัวพิมพ์ใหญ่ พิมพ์เล็ก ตัวเลข และสัญลักษณ์)
  static bool isStrongPassword(String password) {
    if (isEmpty(password) || password.length < 8) return false;

    bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    bool hasDigit = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar;
  }

  /// นับจำนวนคำในข้อความ
  static int countWords(String text) {
    if (isEmpty(text)) return 0;
    // Handle newlines and tabs as word separators
    return text
        .trim()
        .split(RegExp(r'[\s\n\t]+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  /// ตัดข้อความให้มีความยาวไม่เกินที่กำหนด
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    int cutLength = maxLength - suffix.length;
    if (cutLength <= 0) return suffix;
    return text.substring(0, cutLength) + suffix;
  }

  /// แปลง String เป็น JSON Object
  static Map<String, dynamic>? parseJson(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// สลับตำแหน่งของตัวอักษรในคำ
  static String reverse(String text) {
    return text.split('').reversed.join('');
  }

  /// ตรวจสอบว่าเป็น palindrome หรือไม่
  static bool isPalindrome(String text) {
    if (isEmpty(text)) return false;
    String cleaned = removeWhitespace(text.toLowerCase());
    return cleaned == reverse(cleaned);
  }

  /// แทนที่อีโมจิหรือตัวอักษรพิเศษด้วยข้อความ
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
