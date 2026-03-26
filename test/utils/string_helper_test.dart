import 'package:flutter_test/flutter_test.dart';
import 'package:demo_unit_tests/utils/string_helper.dart';

void main() {
  group('StringHelper Tests', () {
    group('Empty String Validation', () {
      test('isEmpty should return true for null string', () {
        // Act & Assert
        expect(StringHelper.isEmpty(null), isTrue);
      });

      test('isEmpty should return true for empty string', () {
        // Act & Assert
        expect(StringHelper.isEmpty(''), isTrue);
        expect(StringHelper.isEmpty('   '), isTrue); // whitespace only
      });

      test('isEmpty should return false for non-empty string', () {
        // Act & Assert
        expect(StringHelper.isEmpty('hello'), isFalse);
        expect(StringHelper.isEmpty(' hello '), isFalse);
      });

      test('isNotEmpty should return opposite of isEmpty', () {
        // Act & Assert
        expect(StringHelper.isNotEmpty('hello'), isTrue);
        expect(StringHelper.isNotEmpty(''), isFalse);
        expect(StringHelper.isNotEmpty(null), isFalse);
      });
    });

    group('Text Transformation', () {
      test('capitalize should capitalize first letter only', () {
        // Act & Assert
        expect(StringHelper.capitalize('hello'), equals('Hello'));
        expect(StringHelper.capitalize('HELLO'), equals('Hello'));
        expect(StringHelper.capitalize('hELLO'), equals('Hello'));
        expect(StringHelper.capitalize('h'), equals('H'));
      });

      test('capitalize should handle empty strings', () {
        // Act & Assert
        expect(StringHelper.capitalize(''), equals(''));
        expect(StringHelper.capitalize(' '), equals(' '));
      });

      test('toTitleCase should capitalize each word', () {
        // Act & Assert
        expect(StringHelper.toTitleCase('hello world'), equals('Hello World'));
        expect(StringHelper.toTitleCase('HELLO WORLD'), equals('Hello World'));
        expect(
          StringHelper.toTitleCase('hello-world'),
          equals('Hello-world'),
        ); // ไม่แยกที่ dash
        expect(
          StringHelper.toTitleCase('one two three'),
          equals('One Two Three'),
        );
      });

      test('toTitleCase should handle edge cases', () {
        // Act & Assert
        expect(StringHelper.toTitleCase(''), equals(''));
        expect(StringHelper.toTitleCase('a'), equals('A'));
        expect(
          StringHelper.toTitleCase('  hello  world  '),
          equals('  Hello  World  '),
        );
      });

      test('removeWhitespace should remove all whitespace', () {
        // Act & Assert
        expect(
          StringHelper.removeWhitespace('hello world'),
          equals('helloworld'),
        );
        expect(StringHelper.removeWhitespace('  a  b  c  '), equals('abc'));
        expect(
          StringHelper.removeWhitespace('hello\nworld\t'),
          equals('helloworld'),
        ); // Fixed: actual newline/tab
        expect(StringHelper.removeWhitespace(''), equals(''));
      });

      test('reverse should reverse string correctly', () {
        // Act & Assert
        expect(StringHelper.reverse('hello'), equals('olleh'));
        expect(StringHelper.reverse('a'), equals('a'));
        expect(StringHelper.reverse(''), equals(''));
        expect(StringHelper.reverse('12345'), equals('54321'));
      });

      test('truncate should limit string length', () {
        // Act & Assert
        expect(StringHelper.truncate('hello world', 5), equals('he...'));
        expect(StringHelper.truncate('hello', 10), equals('hello')); // ไม่ตัด
        expect(
          StringHelper.truncate('hello world', 11),
          equals('hello world'),
        ); // พอดี
        expect(
          StringHelper.truncate('hello world', 8, suffix: '>>'),
          equals('hello >>'),
        ); // Fixed: correct length calculation
      });

      test('truncate should handle maxLength shorter than suffix', () {
        expect(StringHelper.truncate('hello', 2), equals('...'));
        expect(StringHelper.truncate('hello', 0), equals('...'));
      });
    });

    group('Validation Methods', () {
      test('isValidEmail should validate email format correctly', () {
        // Valid emails
        expect(StringHelper.isValidEmail('test@example.com'), isTrue);
        expect(StringHelper.isValidEmail('user.name@domain.co.th'), isTrue);
        expect(StringHelper.isValidEmail('test+tag@example.org'), isTrue);

        // Invalid emails
        expect(StringHelper.isValidEmail('invalid-email'), isFalse);
        expect(StringHelper.isValidEmail('@example.com'), isFalse);
        expect(StringHelper.isValidEmail('test@'), isFalse);
        expect(StringHelper.isValidEmail('test@.com'), isFalse);
        expect(StringHelper.isValidEmail(''), isFalse);
        expect(StringHelper.isValidEmail('test.example.com'), isFalse);
      });

      test('isValidThaiPhoneNumber should validate Thai phone format', () {
        // Valid Thai phone numbers
        expect(StringHelper.isValidThaiPhoneNumber('08-1234-5678'), isTrue);
        expect(StringHelper.isValidThaiPhoneNumber('0812345678'), isTrue);
        expect(StringHelper.isValidThaiPhoneNumber('081-234-5678'), isTrue);
        expect(StringHelper.isValidThaiPhoneNumber('0612345678'), isTrue);
        expect(StringHelper.isValidThaiPhoneNumber('0912345678'), isTrue);

        // Valid with +66 format
        expect(StringHelper.isValidThaiPhoneNumber('+66812345678'), isTrue);
        expect(StringHelper.isValidThaiPhoneNumber('+66612345678'), isTrue);
        expect(StringHelper.isValidThaiPhoneNumber('+66912345678'), isTrue);

        // Invalid Thai phone numbers
        expect(
          StringHelper.isValidThaiPhoneNumber('07-1234-5678'),
          isFalse,
        ); // ไม่ขึ้นต้นด้วย 06/08/09
        expect(
          StringHelper.isValidThaiPhoneNumber('081234567'),
          isFalse,
        ); // สั้นเกินไป
        expect(
          StringHelper.isValidThaiPhoneNumber('08123456789'),
          isFalse,
        ); // ยาวเกินไป
        expect(StringHelper.isValidThaiPhoneNumber(''), isFalse);
        expect(StringHelper.isValidThaiPhoneNumber('abc'), isFalse);
      });

      test('isStrongPassword should validate password strength', () {
        // Strong passwords
        expect(StringHelper.isStrongPassword('Password123!'), isTrue);
        expect(StringHelper.isStrongPassword('MyStr0ng@Pass'), isTrue);
        expect(StringHelper.isStrongPassword('Abc123!@#'), isTrue);

        // Weak passwords
        expect(
          StringHelper.isStrongPassword('password'),
          isFalse,
        ); // ไม่มีตัวพิมพ์ใหญ่, ตัวเลข, สัญลักษณ์
        expect(
          StringHelper.isStrongPassword('PASSWORD'),
          isFalse,
        ); // ไม่มีตัวพิมพ์เล็ก, ตัวเลข, สัญลักษณ์
        expect(
          StringHelper.isStrongPassword('Pass123'),
          isFalse,
        ); // ไม่มีสัญลักษณ์
        expect(StringHelper.isStrongPassword('Pass!'), isFalse); // สั้นเกินไป
        expect(StringHelper.isStrongPassword(''), isFalse);
        expect(
          StringHelper.isStrongPassword('12345678'),
          isFalse,
        ); // ไม่มีตัวอักษร
      });

      test('isPalindrome should detect palindromes', () {
        // Palindromes
        expect(StringHelper.isPalindrome('racecar'), isTrue);
        expect(
          StringHelper.isPalindrome('A man a plan a canal Panama'),
          isTrue,
        );
        expect(StringHelper.isPalindrome('Madam'), isTrue);
        expect(StringHelper.isPalindrome('a'), isTrue);

        // Not palindromes
        expect(StringHelper.isPalindrome('hello'), isFalse);
        expect(StringHelper.isPalindrome('test'), isFalse);
        expect(StringHelper.isPalindrome(''), isFalse);
      });
    });

    group('Utility Methods', () {
      test('countWords should count words correctly', () {
        // Act & Assert
        expect(StringHelper.countWords('hello world'), equals(2));
        expect(StringHelper.countWords('one'), equals(1));
        expect(StringHelper.countWords(''), equals(0));
        expect(StringHelper.countWords('  hello   world  test  '), equals(3));
        expect(
          StringHelper.countWords('hello\nworld\ttest'),
          equals(3),
        ); // Fixed: actual newline/tab
      });

      test('parseJson should parse valid JSON', () {
        // Arrange
        const validJson = '{"name": "John", "age": 30}';

        // Act
        final result = StringHelper.parseJson(validJson);

        // Assert
        expect(result, isNotNull);
        expect(result!['name'], equals('John'));
        expect(result['age'], equals(30));
      });

      test('parseJson should return null for invalid JSON', () {
        // Arrange
        const invalidJson = '{name: John}'; // missing quotes

        // Act
        final result = StringHelper.parseJson(invalidJson);

        // Assert
        expect(result, isNull);
      });

      test('parseJson should return null for empty string', () {
        expect(StringHelper.parseJson(''), isNull);
      });

      test('parseJson should return null for JSON array', () {
        // parseJson คืน Map เท่านั้น — array จะ cast ไม่ได้
        expect(StringHelper.parseJson('[1, 2, 3]'), isNull);
      });

      test('replaceEmojis should replace emojis with text', () {
        // Act & Assert
        expect(
          StringHelper.replaceEmojis('Hello 😀 World 🚀'),
          equals('Hello [emoji] World [emoji]'),
        );

        expect(
          StringHelper.replaceEmojis('No emojis here'),
          equals('No emojis here'),
        );

        expect(
          StringHelper.replaceEmojis('Test 😀', replacement: '*'),
          equals('Test *'),
        );
      });
    });

    group('Edge Cases and Boundary Values', () {
      test('should handle null and empty strings consistently', () {
        // Act & Assert
        expect(StringHelper.capitalize(''), equals(''));
        expect(StringHelper.toTitleCase(''), equals(''));
        expect(StringHelper.removeWhitespace(''), equals(''));
        expect(StringHelper.reverse(''), equals(''));
        expect(StringHelper.countWords(''), equals(0));
      });

      test('should handle single character strings', () {
        // Act & Assert
        expect(StringHelper.capitalize('a'), equals('A'));
        expect(StringHelper.toTitleCase('a'), equals('A'));
        expect(StringHelper.reverse('a'), equals('a'));
        expect(StringHelper.countWords('a'), equals(1));
        expect(StringHelper.truncate('a', 5), equals('a'));
      });

      test('should handle strings with special characters', () {
        // Act & Assert
        expect(StringHelper.capitalize('élève'), equals('Élève'));
        expect(
          StringHelper.removeWhitespace('hello\u00A0world'),
          equals('helloworld'),
        ); // Fixed: actual non-breaking space
        expect(
          StringHelper.countWords('hello-world_test'),
          equals(1),
        ); // treated as one word
      });

      test('should handle very long strings', () {
        // Arrange
        final longString = 'a' * 1000;

        // Act & Assert
        expect(StringHelper.removeWhitespace(longString), equals(longString));
        expect(StringHelper.reverse(longString), equals('a' * 1000));
        expect(StringHelper.truncate(longString, 10), equals('aaaaaaa...'));
      });
    });

    group('Unicode and International Text', () {
      test('should handle Thai text correctly', () {
        // Act & Assert
        expect(StringHelper.isEmpty('สวัสดี'), isFalse);
        expect(StringHelper.countWords('สวัสดี ครับ'), equals(2));
        expect(
          StringHelper.reverse('สวัสดี'),
          equals('ีดสัวส'),
        ); // Fixed: proper Thai text reversal
      });

      test('should handle mixed language text', () {
        // Act & Assert
        expect(
          StringHelper.toTitleCase('hello สวัสดี world'),
          equals('Hello สวัสดี World'),
        );
        expect(StringHelper.countWords('hello สวัสดี world'), equals(3));
      });
    });
  });
}
