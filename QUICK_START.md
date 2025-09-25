# 🚀 Quick Start Guide - เริ่มต้น Unit Testing ใน 10 นาที

## 🎯 เป้าหมาย

ทำความเข้าใจ unit testing พื้นฐานใน Flutter ด้วยตัวอย่างจริงใน 10 นาที

## ⚡ ขั้นตอนเร็ว (Quick Steps)

### 1️⃣ เตรียมโปรเจค (1 นาที)

```bash
# Clone โปรเจค
git clone <repository-url>
cd demo_unit_tests

# ติดตั้ง dependencies
flutter pub get

# สร้าง mock files
dart run build_runner build
```

### 2️⃣ รัน Test แรก (2 นาที)

```bash
# ทดสอบ User Model - ง่ายที่สุด
flutter test test/models/user_test.dart
```

**คาดหวัง:** เห็น `All tests passed!` ✅

### 3️⃣ เข้าใจโครงสร้าง Test (3 นาที)

เปิดไฟล์ `test/models/user_test.dart`:

```dart
void main() {
  group('User Model Tests', () {           // 📁 กลุ่ม tests
    test('should create user', () {        // 🧪 test case เดี่ยว
      // Arrange - จัดเตรียมข้อมูล
      final user = User(id: 1, name: 'John', email: 'john@test.com', age: 25);

      // Act - ทำการทดสอบ (ในที่นี้ไม่มีเพราะแค่ test properties)

      // Assert - ตรวจสอบผลลัพธ์
      expect(user.name, equals('John'));
      expect(user.isAdult, isTrue);
    });
  });
}
```

### 4️⃣ ทดลองแก้ไข Test (2 นาที)

1. **เปลี่ยน expected value** ในบรรทัดใดบรรทัดหนึ่ง:

   ```dart
   expect(user.name, equals('Jane')); // เปลี่ยนจาก 'John' เป็น 'Jane'
   ```

2. **รัน test อีกครั้ง:**

   ```bash
   flutter test test/models/user_test.dart
   ```

3. **สังเกต error message:** จะเห็นว่า test fail และ error ชัดเจน

4. **แก้ไขกลับ** ให้ถูกต้อง

### 5️⃣ ลองทดสอบ Service (2 นาที)

```bash
# ทดสอบ business logic ที่ซับซ้อนกว่า
flutter test test/services/user_service_test.dart
```

เปิดไฟล์ดูตัวอย่าง **setUp/tearDown** และ **exception testing**:

```dart
group('UserService Tests', () {
  late UserService userService;

  setUp(() {
    userService = UserService();     // เตรียมก่อนแต่ละ test
  });

  test('should add user successfully', () {
    // Arrange
    final user = User(id: 1, name: 'John', email: 'john@test.com', age: 25);

    // Act
    userService.addUser(user);

    // Assert
    expect(userService.getUserCount(), equals(1));
  });

  test('should throw error for duplicate ID', () {
    // Arrange
    final user = User(id: 1, name: 'John', email: 'john@test.com', age: 25);
    userService.addUser(user);

    // Act & Assert
    expect(
      () => userService.addUser(user),  // คาดหวังว่าจะ throw error
      throwsA(isA<ArgumentError>()),
    );
  });
});
```

## 🎓 สิ่งที่เรียนรู้ได้ใน 10 นาที

### ✅ Basic Concepts

- **Arrange-Act-Assert** pattern
- **group()** สำหรับจัดกลุ่ม tests
- **test()** สำหรับ test case เดี่ยว
- **expect()** สำหรับตรวจสอบผลลัพธ์

### ✅ Testing Patterns

- การทดสอบ **properties และ getters**
- การทดสอบ **business logic methods**
- การทดสอบ **exceptions**
- การใช้ **setUp/tearDown**

### ✅ Best Practices

- ตั้งชื่อ test ที่อธิบายได้ชัดเจน
- จัดกลุ่ม tests ตาม functionality
- ใช้ meaningful assertions

## 📋 Checklist - สิ่งที่ควรทำต่อ

หลังจากเข้าใจพื้นฐานแล้ว:

- [ ] ลอง Widget Testing (`test/widgets/`)
- [ ] เรียนรู้ Mocking (`test/services/api_service_test.dart`)
- [ ] ทดสอบ Async code (`test/services/async_data_service_test.dart`)
- [ ] รัน Integration tests (`flutter test integration_test/`)
- [ ] ดู Code Coverage (`flutter test --coverage`)

## 🚀 Next Steps

1. **อ่าน README.md** สำหรับคำอธิบายแบบละเอียด
2. **ศึกษา PROJECT_SUMMARY.md** เพื่อดูภาพรวม
3. **ลองสร้าง test ใหม่** ตาม E2E guide
4. **ทดลองกับโปรเจคตัวเอง**

## 💡 Pro Tips

- **เริ่มจาก model tests** - ง่ายที่สุด
- **เขียน test ก่อน implementation** (TDD)
- **ใช้ descriptive test names**
- **จัดกลุ่ม tests อย่างเป็นระบบ**
- **มีเป้าหมาย coverage ≥ 80%**

---

**🎉 ยินดีด้วย!** ตอนนี้คุณพร้อมสำหรับการเขียน unit tests ใน Flutter แล้ว

**⏰ เวลาที่ใช้:** ~10 นาที | **ความรู้ที่ได้:** Flutter Testing Fundamentals
