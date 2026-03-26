# 📘 คู่มือการเขียน Unit Test ใน Flutter (ฉบับสมบูรณ์ภาษาไทย)

> **เขียนโดย:** โปรเจค demo_unit_tests  
> **สำหรับ:** นักพัฒนาไทยที่ต้องการเรียนรู้การเขียน Unit Test  
> **ระดับ:** เริ่มต้น → กลาง → สูง

---

## 📑 สารบัญ

1. [แนวคิดพื้นฐาน — Unit Test คืออะไร?](#1-แนวคิดพื้นฐาน--unit-test-คืออะไร)
2. [โครงสร้างโปรเจค — อะไรอยู่ตรงไหน?](#2-โครงสร้างโปรเจค--อะไรอยู่ตรงไหน)
3. [ไฟล์ Source Code — แต่ละไฟล์ทำอะไร?](#3-ไฟล์-source-code--แต่ละไฟล์ทำอะไร)
4. [ไฟล์ Test — แต่ละไฟล์ทดสอบอะไร?](#4-ไฟล์-test--แต่ละไฟล์ทดสอบอะไร)
5. [เทคนิคและ Pattern ที่ใช้ — ใช้อะไรอย่างไร?](#5-เทคนิคและ-pattern-ที่ใช้--ใช้อะไรอย่างไร)
6. [วิธีรัน Test](#6-วิธีรัน-test)
7. [แนวคิดปัจจุบันและการต่อยอด](#7-แนวคิดปัจจุบันและการต่อยอด)
8. [สรุป Cheat Sheet](#8-สรุป-cheat-sheet)
9. [อ้างอิงจากเอกสารทางการ Flutter](#9-อ้างอิงจากเอกสารทางการ-flutter-official-testing-docs)

---

## 1. แนวคิดพื้นฐาน — Unit Test คืออะไร?

### 🤔 ทำไมต้องเขียน Test?

ลองนึกภาพว่าคุณสร้างแอปคำนวณเงิน ถ้าคุณแก้โค้ดส่วนหนึ่งแล้วส่วนอื่นพังล่ะ?  
**Unit Test** คือ "ยามเฝ้า" ที่คอยตรวจว่าโค้ดทุกส่วนยังทำงานถูกต้องอยู่

```
┌─────────────────────────────────────────────┐
│  Unit Test = ทดสอบหน่วยย่อยสุดของโปรแกรม      │
│                                             │
│  ตัวอย่าง:                                    │
│  - ฟังก์ชัน "บวกเลข" บวกได้ถูกไหม?            │
│  - Model "User" สร้างข้อมูลได้ถูกไหม?          │
│  - Service "API" เรียกข้อมูลได้ถูกไหม?         │
└─────────────────────────────────────────────┘
```

### 📐 หลัก AAA (Arrange-Act-Assert)

ทุก Test Case ใช้โครงสร้าง 3 ขั้นตอน:

```dart
test('ควรบวกเลขได้ถูกต้อง', () {
  // 1. Arrange (เตรียมข้อมูล)
  final a = 2;
  final b = 3;

  // 2. Act (ทำสิ่งที่ต้องการทดสอบ)
  final result = MathUtils.add(a, b);

  // 3. Assert (ตรวจสอบผลลัพธ์)
  expect(result, equals(5));
});
```

### 🧪 ประเภทของ Test ใน Flutter

| ประเภท               | ทดสอบอะไร             | ความเร็ว   | ไฟล์ตัวอย่าง                |
| -------------------- | --------------------- | ---------- | --------------------------- |
| **Unit Test**        | Logic, Model, Service | ⚡ เร็วมาก | `math_utils_test.dart`      |
| **Widget Test**      | UI Component          | 🚀 เร็ว    | `custom_widgets_test.dart`  |
| **Integration Test** | ทั้งแอป               | 🐌 ช้า     | `app_integration_test.dart` |

---

## 2. โครงสร้างโปรเจค — อะไรอยู่ตรงไหน?

```
demo_unit_tests/
├── lib/                          ← 📦 โค้ดจริงของแอป
│   ├── models/
│   │   └── user.dart             ← โมเดลข้อมูลผู้ใช้
│   ├── services/
│   │   ├── api_service.dart      ← เรียก API ภายนอก
│   │   ├── async_data_service.dart ← งาน Async (Future/Stream)
│   │   ├── exception_examples.dart ← จัดการ Error/Exception
│   │   ├── user_service.dart     ← จัดการข้อมูลผู้ใช้
│   │   └── webview_service.dart  ← ควบคุม WebView
│   ├── utils/
│   │   ├── math_utils.dart       ← ฟังก์ชันคณิตศาสตร์
│   │   └── string_helper.dart    ← ฟังก์ชันจัดการข้อความ
│   └── widgets/
│       └── custom_widgets.dart   ← Widget แบบกำหนดเอง
│
├── test/                         ← 🧪 ไฟล์ทดสอบ (ชื่อเดียวกัน + _test)
│   ├── models/
│   │   └── user_test.dart
│   ├── services/
│   │   ├── api_service_test.dart
│   │   ├── api_service_test.mocks.dart  ← ไฟล์ Mock ที่สร้างอัตโนมัติ
│   │   ├── async_data_service_test.dart
│   │   ├── exception_handling_test.dart
│   │   ├── user_service_test.dart
│   │   └── webview_service_test.dart
│   ├── utils/
│   │   ├── math_utils_test.dart
│   │   └── string_helper_test.dart
│   └── widgets/
│       └── custom_widgets_test.dart
│
└── integration_test/             ← 🌐 ทดสอบทั้งแอป
    └── app_integration_test.dart
```

**หลักสำคัญ:** โครงสร้าง `test/` สะท้อนโครงสร้าง `lib/` เพื่อให้หาง่าย

---

## 3. ไฟล์ Source Code — แต่ละไฟล์ทำอะไร?

### 3.1 `lib/models/user.dart` — โมเดลผู้ใช้

**หน้าที่:** กำหนดโครงสร้างข้อมูลผู้ใช้

| คุณสมบัติ/เมธอด                          | หน้าที่         | ตัวอย่าง                          |
| ---------------------------------------- | --------------- | --------------------------------- |
| `id`, `name`, `email`, `age`, `isActive` | ข้อมูลพื้นฐาน   | `User(id: 1, name: 'สมชาย', ...)` |
| `isAdult` (getter)                       | ตรวจอายุ >= 18  | `user.isAdult → true`             |
| `isValidEmail` (getter)                  | ตรวจรูปแบบอีเมล | `user.isValidEmail → true`        |
| `toMap()`                                | แปลงเป็น Map    | สำหรับส่งข้อมูลหรือบันทึก         |
| `fromMap()` (factory)                    | สร้างจาก Map    | สำหรับรับข้อมูลจาก API/DB         |
| `copyWith()`                             | สำเนาพร้อมแก้ไข | `user.copyWith(name: 'ชื่อใหม่')` |
| `==` / `hashCode`                        | เปรียบเทียบ     | ใช้ใน `expect(a, equals(b))`      |

**แนวคิดที่สอน:**

- Immutable object (ใช้ `final` ทุก field)
- Factory constructor
- Value equality (override `==` กับ `hashCode`)

---

### 3.2 `lib/utils/math_utils.dart` — ฟังก์ชันคณิตศาสตร์

**หน้าที่:** รวมฟังก์ชัน static สำหรับคำนวณ

| ฟังก์ชัน                                | หน้าที่        | หมายเหตุ                          |
| --------------------------------------- | -------------- | --------------------------------- |
| `add`, `subtract`, `multiply`, `divide` | เลขคณิตพื้นฐาน | `divide` throw error ถ้าหารด้วย 0 |
| `power`                                 | ยกกำลัง        | `power(2, 3) → 8.0`               |
| `absolute`                              | ค่าสัมบูรณ์    | `absolute(-5) → 5`                |
| `factorial`                             | แฟกทอเรียล     | throw error ถ้าค่าติดลบ           |
| `isEven`, `isOdd`, `isPrime`            | จำแนกประเภทเลข | ตรวจคู่/คี่/จำนวนเฉพาะ            |
| `max`, `min`, `average`                 | คำนวณจาก List  | รับ generic `List<T>`             |

**แนวคิดที่สอน:**

- Static method (ไม่ต้องสร้าง instance)
- Error handling ด้วย `ArgumentError`
- Generic type `<T extends Comparable<T>>`

---

### 3.3 `lib/utils/string_helper.dart` — จัดการข้อความ

**หน้าที่:** Validate และแปลงข้อความ

| ฟังก์ชัน                 | หน้าที่                   | ตัวอย่าง                               |
| ------------------------ | ------------------------- | -------------------------------------- |
| `isEmpty` / `isNotEmpty` | ตรวจว่าง                  | รองรับ `null`                          |
| `capitalize`             | ตัวพิมพ์ใหญ่ตัวแรก        | `'hello' → 'Hello'`                    |
| `toTitleCase`            | ตัวพิมพ์ใหญ่ทุกคำ         | `'hello world' → 'Hello World'`        |
| `removeWhitespace`       | ลบช่องว่าง                | `'h e l l o' → 'hello'`                |
| `isValidEmail`           | ตรวจอีเมล                 | ใช้ RegExp                             |
| `isValidThaiPhoneNumber` | ตรวจเบอร์ไทย              | รองรับ 06x, 08x, 09x, +66              |
| `isStrongPassword`       | ตรวจความแข็งแรงรหัสผ่าน   | ต้องมีพิมพ์ใหญ่/เล็ก/เลข/สัญลักษณ์     |
| `isPalindrome`           | ตรวจ palindrome           | `'racecar' → true`                     |
| `truncate`               | ตัดข้อความ                | `truncate('hello world', 5) → 'he...'` |
| `parseJson`              | แปลง JSON string เป็น Map | คืน `null` ถ้าไม่ valid                |
| `replaceEmojis`          | แทนที่อีโมจิ              | `'Hi 😀' → 'Hi [emoji]'`               |

**แนวคิดที่สอน:**

- Null safety (`String?`)
- Regular Expression (RegExp)
- JSON parsing ที่ปลอดภัย

---

### 3.4 `lib/services/user_service.dart` — จัดการผู้ใช้

**หน้าที่:** CRUD operations สำหรับผู้ใช้ (ใช้ List เก็บข้อมูลในหน่วยความจำ)

| เมธอด                          | หน้าที่                   | Return                      |
| ------------------------------ | ------------------------- | --------------------------- |
| `addUser(User)`                | เพิ่มผู้ใช้ (ห้าม ID ซ้ำ) | `void` (throw ถ้าซ้ำ)       |
| `removeUser(int id)`           | ลบผู้ใช้                  | `bool` สำเร็จหรือไม่        |
| `findUserById(int)`            | ค้นหาตาม ID               | `User?` (null ถ้าไม่เจอ)    |
| `findUserByEmail(String)`      | ค้นหาตามอีเมล             | `User?`                     |
| `updateUser(int, User)`        | อัพเดตข้อมูล              | `bool`                      |
| `getAllUsers()`                | ดึงทั้งหมด                | `List<User>` (unmodifiable) |
| `getAdultUsers()`              | กรองเฉพาะผู้ใหญ่          | `List<User>`                |
| `getActiveUsers()`             | กรองเฉพาะ active          | `List<User>`                |
| `getUsersByAgeRange(min, max)` | กรองตามช่วงอายุ           | `List<User>`                |
| `toggleUserStatus(int id)`     | สลับสถานะ active          | `bool`                      |

**แนวคิดที่สอน:**

- In-memory data management
- Unmodifiable list (ป้องกันแก้ไขจากภายนอก)
- Filter ด้วย `where()`

---

### 3.5 `lib/services/api_service.dart` — เรียก API

**หน้าที่:** เชื่อมต่อ REST API ภายนอก (**ส่วนที่ต้อง Mock ใน test**)

```
┌─────────────────────────────────────────────┐
│  HttpClient (abstract)    ← Interface       │
│  ├── RealHttpClient       ← ใช้งานจริง       │
│  └── MockHttpClient       ← ใช้ใน test       │
│                                             │
│  ApiService(HttpClient)   ← รับผ่าน DI      │
│  ├── fetchUser(id)        ← GET /users/{id}  │
│  ├── createPost(...)      ← POST /posts      │
│  └── fetchUserPosts(id)   ← GET /users/{id}/posts │
└─────────────────────────────────────────────┘
```

| เมธอด                             | HTTP | หน้าที่                  |
| --------------------------------- | ---- | ------------------------ |
| `fetchUser(int userId)`           | GET  | ดึงข้อมูลผู้ใช้ 1 คน     |
| `createPost(userId, title, body)` | POST | สร้างโพสต์ใหม่           |
| `fetchUserPosts(int userId)`      | GET  | ดึงโพสต์ทั้งหมดของผู้ใช้ |

**แนวคิดที่สอน:**

- **Dependency Injection (DI):** ส่ง `HttpClient` เข้ามาเพื่อ Mock ได้
- **Interface/Abstract class:** แยก interface กับ implementation
- **Error handling ตาม HTTP status code**

---

### 3.6 `lib/services/async_data_service.dart` — งาน Async

**หน้าที่:** จำลองการทำงานแบบ asynchronous

| เมธอด                            | รูปแบบ           | สิ่งที่สอน                   |
| -------------------------------- | ---------------- | ---------------------------- |
| `fetchUserData(userId)`          | `Future<Map>`    | Async/Await พื้นฐาน          |
| `fetchDataWithRandomFailure()`   | `Future<String>` | Exception ที่สุ่มเกิด        |
| `uploadFile(filename, data)`     | `Future<bool>`   | Validation + Exception       |
| `downloadProgress()`             | `Stream<int>`    | Stream testing               |
| `fetchMultipleData(ids)`         | `Future<List>`   | `Future.wait()` (Concurrent) |
| `fetchDataWithTimeout(timeout)`  | `Future<String>` | `TimeoutException`           |
| `fetchDataWithRetry(maxRetries)` | `Future<String>` | Retry pattern                |
| `processBatch(items, processor)` | `Future<List>`   | Batch processing             |

**แนวคิดที่สอน:**

- `Future` vs `Stream`
- `Future.wait()` สำหรับรัน concurrent
- Timeout handling
- Retry pattern
- Batch processing

---

### 3.7 `lib/services/exception_examples.dart` — จัดการ Exception

**หน้าที่:** ตัวอย่าง Custom Exception และ Business Logic

#### Exception Classes:

| Exception                | ฟิลด์                   | ใช้เมื่อ                |
| ------------------------ | ----------------------- | ----------------------- |
| `ValidationException`    | `message`, `field`      | ข้อมูล input ไม่ถูกต้อง |
| `NetworkException`       | `message`, `statusCode` | เรียก API ล้มเหลว       |
| `BusinessLogicException` | `message`, `errorCode`  | ผิด business rule       |

#### Service Classes:

| Service             | หน้าที่                         |
| ------------------- | ------------------------------- |
| `ValidationService` | ตรวจ email, password, age       |
| `NetworkService`    | จำลอง API call + retry logic    |
| `AccountService`    | จัดการบัญชี (สร้าง/ฝาก/ถอน/โอน) |

**แนวคิดที่สอน:**

- Custom Exception types
- Error codes สำหรับ client
- Rollback transaction (โอนเงินล้มเหลว → คืนเงิน)
- Multiple validation (รวม error หลายตัว)

---

### 3.8 `lib/services/webview_service.dart` — WebView

**หน้าที่:** ควบคุม WebViewController

**แนวคิดที่สอน:**

- Null safety check ก่อนเรียกใช้ controller
- Mock third-party package (webview_flutter)
- ใช้ **mocktail** แทน **mockito** (ไม่ต้อง code generation)

---

### 3.9 `lib/widgets/custom_widgets.dart` — Custom Widgets

| Widget          | หน้าที่           | คุณสมบัติ                                    |
| --------------- | ----------------- | -------------------------------------------- |
| `UserCard`      | แสดงข้อมูลผู้ใช้  | Avatar, ปุ่ม edit/delete, สถานะ selected     |
| `CounterWidget` | นับเลขขึ้น/ลง     | ค่า min/max, สี, callback                    |
| `AddUserForm`   | ฟอร์มเพิ่มผู้ใช้  | Validation, loading state, clear หลัง submit |
| `LoadingWidget` | แสดงสถานะ loading | Circular/Linear/Dots + message               |
| `SearchWidget`  | ช่องค้นหา         | Debounce, ปุ่ม clear                         |

**แนวคิดที่สอน:**

- StatelessWidget vs StatefulWidget
- Widget testing ด้วย `testWidgets`
- User interaction testing (tap, type)
- Debounce pattern

---

## 4. ไฟล์ Test — แต่ละไฟล์ทดสอบอะไร?

### 4.1 `test/models/user_test.dart`

**ทดสอบ:** โมเดล User — ~16 test cases

| กลุ่ม Test        | ทดสอบอะไร                           | เทคนิค                             |
| ----------------- | ----------------------------------- | ---------------------------------- |
| Constructor Tests | สร้าง User ได้ถูกต้อง + ค่า default | `equals()`                         |
| Getter Tests      | `isAdult`, `isValidEmail`           | Boundary value (17, 18, 19)        |
| Method Tests      | `toMap`, `fromMap`, `copyWith`      | Round-trip test                    |
| Equality Tests    | `==`, `hashCode`                    | `identical()`, different reference |
| toString Tests    | แสดงข้อมูลครบ                       | `contains()`                       |

**ตัวอย่างเทคนิค Boundary Value:**

```dart
// ทดสอบค่าขอบเขต: อายุ 17, 18 (เส้นแบ่ง), 20
test('isAdult สำหรับอายุ 17', () => expect(user17.isAdult, isFalse));
test('isAdult สำหรับอายุ 18', () => expect(user18.isAdult, isTrue));  // ← ค่าขอบ
test('isAdult สำหรับอายุ 20', () => expect(user20.isAdult, isTrue));
```

---

### 4.2 `test/utils/math_utils_test.dart`

**ทดสอบ:** ฟังก์ชันคณิตศาสตร์ — ~35 test cases

| กลุ่ม Test            | ทดสอบอะไร                        | เทคนิค               |
| --------------------- | -------------------------------- | -------------------- |
| Basic Arithmetic      | บวก ลบ คูณ หาร                   | ค่าบวก/ลบ/ศูนย์      |
| Advanced Operations   | ยกกำลัง, ค่าสัมบูรณ์, แฟกทอเรียล | Exception test       |
| Number Classification | คู่/คี่/จำนวนเฉพาะ               | Boolean matchers     |
| List Operations       | max, min, average                | Empty list exception |
| Edge Cases            | ค่า 0, ค่าใหญ่มาก                | `closeTo()`          |
| Type Safety           | ใช้กับ String, DateTime          | Generic type         |

---

### 4.3 `test/utils/string_helper_test.dart`

**ทดสอบ:** จัดการข้อความ — ~25 test cases

| กลุ่ม Test              | ทดสอบอะไร                             | เทคนิคพิเศษ     |
| ----------------------- | ------------------------------------- | --------------- |
| Empty String Validation | null, empty, whitespace               | Null safety     |
| Text Transformation     | capitalize, titleCase, reverse        | Edge cases      |
| Validation Methods      | email, เบอร์ไทย, password, palindrome | RegExp          |
| Utility Methods         | countWords, parseJson, replaceEmojis  | Unicode         |
| Edge Cases              | ตัวอักษรพิเศษ, ข้อความยาวมาก          | `'a' * 1000`    |
| Unicode/Thai            | ภาษาไทย, ภาษาผสม                      | `'สวัสดี ครับ'` |

---

### 4.4 `test/services/user_service_test.dart`

**ทดสอบ:** CRUD ผู้ใช้ — ~27 test cases

| กลุ่ม Test      | ทดสอบอะไร                         | เทคนิค                          |
| --------------- | --------------------------------- | ------------------------------- |
| Add User        | เพิ่ม + ซ้ำ = error               | `throwsA(isA<ArgumentError>())` |
| Find User       | ค้นหาตาม ID/email + ไม่เจอ = null | `isNull`, `isNotNull`           |
| Remove User     | ลบ + ลบไม่เจอ                     | Return value check              |
| Update User     | อัพเดต + ไม่เจอ = false           | Nested setUp                    |
| Get Users       | กรอง adult/active/ช่วงอายุ        | `contains()`, `isNot()`         |
| Utility Methods | hasUsers, toggle, clear           | State change                    |
| Integration     | Lifecycle ครบวงจร                 | Multi-step assertion            |
| Error Handling  | ข้อมูลคงอยู่หลัง error            | Data integrity                  |

**เทคนิค nested setUp:**

```dart
group('Find User Tests', () {
  setUp(() {
    // เพิ่ม user 3 คนก่อนทุก test ในกลุ่มนี้
    userService.addUser(testUser1);
    userService.addUser(testUser2);
    userService.addUser(testUser3);
  });
  // test cases...
});
```

---

### 4.5 `test/services/api_service_test.dart`

**ทดสอบ:** เรียก API ด้วย Mock — ~25 test cases  
**ใช้:** `mockito` + code generation (`@GenerateMocks`)

| กลุ่ม Test     | ทดสอบอะไร                       | เทคนิค Mock                              |
| -------------- | ------------------------------- | ---------------------------------------- |
| Basic Mock     | สำเร็จ/404/500/Network error    | `when().thenAnswer()`                    |
| Verification   | นับจำนวนครั้ง, URL ที่เรียก     | `verify().called(n)`                     |
| Advanced Mock  | ตอบต่างกันตาม input             | `captureAny`, `verifyNoMoreInteractions` |
| createPost     | POST สำเร็จ/ล้มเหลว/header/body | `captureAnyNamed('body')`                |
| fetchUserPosts | List response/empty/error       | `json.decode`                            |

**ขั้นตอนใช้ Mockito:**

```dart
// 1. ประกาศ annotation (ครั้งเดียว)
@GenerateMocks([HttpClient])
import 'api_service_test.mocks.dart';

// 2. รัน code generation
// $ dart run build_runner build

// 3. ใช้ใน test
final mock = MockHttpClient();
when(mock.get(any)).thenAnswer((_) async => http.Response('...', 200));
```

---

### 4.6 `test/services/async_data_service_test.dart`

**ทดสอบ:** งาน Async — ~32 test cases

| กลุ่ม Test                 | ทดสอบอะไร                      | เทคนิค Async                 |
| -------------------------- | ------------------------------ | ---------------------------- |
| fetchUserData              | valid/invalid, concurrent      | `await expectLater()`        |
| fetchDataWithRandomFailure | สุ่มผลลัพธ์                    | `anyOf()` matcher            |
| uploadFile                 | valid/empty/too large/boundary | File size validation         |
| downloadProgress (Stream)  | ค่า 0-100, ลำดับ, complete     | `await for`, `stream.last`   |
| fetchMultipleData          | concurrent, empty, single      | `Future.wait()` performance  |
| fetchDataWithTimeout       | สำเร็จ/timeout                 | `TimeoutException`           |
| fetchDataWithRetry         | retry สำเร็จ/เกินจำนวน         | Retry count                  |
| processBatch               | batch size, empty, data types  | Generic batch                |
| Integration                | หลาย operations พร้อมกัน       | Error handling in concurrent |

**เทคนิค Stream Test:**

```dart
test('ควรปล่อยค่า 0 ถึง 100', () async {
  final values = <int>[];
  await for (final progress in service.downloadProgress()) {
    values.add(progress);
  }
  expect(values, equals([0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]));
});
```

---

### 4.7 `test/services/exception_handling_test.dart`

**ทดสอบ:** Exception handling — ~30 test cases

| กลุ่ม Test                | ทดสอบอะไร                                | เทคนิค                      |
| ------------------------- | ---------------------------------------- | --------------------------- |
| Email Validation          | valid/null/empty/format                  | `throwsA(isA<>().having())` |
| Password Validation       | strong/null/short/no uppercase/no number | Chained `.having()`         |
| Age Validation            | valid/null/negative/over 150             | Boundary values             |
| Multiple Validation       | ผิดหลายฟิลด์พร้อมกัน                     | Error aggregation           |
| NetworkException          | status 400/401/404/500                   | Loop over test cases        |
| Retry Logic               | ไม่ retry 4xx, retry 5xx                 | Timing assertions           |
| BusinessLogicException    | สร้างบัญชี/ฝาก/ถอน/โอน                   | Transaction rollback        |
| Error Code Classification | จัดกลุ่ม error code                      | Pattern matching            |
| Exception Recovery        | ข้อมูลสำหรับแก้ไข error                  | Error code usage            |

**เทคนิค `.having()` chain:**

```dart
expect(
  () => service.validateEmail(null),
  throwsA(
    isA<ValidationException>()
      .having((e) => e.message, 'message', contains('required'))
      .having((e) => e.field, 'field', equals('email')),
  ),
);
```

---

### 4.8 `test/services/webview_service_test.dart`

**ทดสอบ:** WebView Controller — ~12 test cases  
**ใช้:** `mocktail` (ไม่ต้อง code generation)

| Test             | ทดสอบอะไร                            | เทคนิค               |
| ---------------- | ------------------------------------ | -------------------- |
| loadUrl          | โหลด URL เมื่อมี controller          | `verify()`           |
| goBack/goForward | เช็ค canGoBack ก่อน                  | Conditional behavior |
| reload           | reload เมื่อมี controller            | Null safety          |
| runJavaScript    | รัน JS แล้วรับผลลัพธ์                | Async mock           |
| null controller  | ไม่ crash เมื่อ controller เป็น null | Safety check         |
| dispose          | clear controller                     | State check          |

**ความต่างของ Mocktail vs Mockito:**

```dart
// Mocktail — ไม่ต้อง code generation
class MockWebViewController extends Mock implements WebViewController {}

// ต้อง registerFallbackValue สำหรับ non-nullable type
setUpAll(() {
  registerFallbackValue(Uri.parse('https://example.com'));
});

// when ใช้ lambda
when(() => mock.loadRequest(any())).thenAnswer((_) async {});
```

---

### 4.9 `test/widgets/custom_widgets_test.dart`

**ทดสอบ:** UI Widgets — ~45 test cases

| กลุ่ม Widget      | ทดสอบอะไร                                          | เทคนิค Widget Test                      |
| ----------------- | -------------------------------------------------- | --------------------------------------- |
| **UserCard**      | แสดงข้อมูล, avatar, ปุ่ม, tap, selected            | `find.text()`, `find.byIcon()`          |
| **CounterWidget** | ค่าเริ่มต้น, เพิ่ม/ลด, min/max, สี, callback       | `tester.tap()`, `tester.pump()`         |
| **AddUserForm**   | validation, submit, loading, clear, initial values | `tester.enterText()`, `pumpAndSettle()` |
| **LoadingWidget** | circular/linear/dots, message                      | `find.byType()`                         |
| **SearchWidget**  | hint, search callback, clear, debounce             | `Timer`, `Completer`                    |
| **Integration**   | หลาย widget ทำงานร่วมกัน                           | Multi-widget interaction                |
| **Performance**   | กดเร็วๆ, dispose ไม่ leak                          | Rapid interaction                       |

**เทคนิค Widget Test สำคัญ:**

```dart
testWidgets('ควรแสดง loading ระหว่าง submit', (tester) async {
  // สร้าง widget
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: MyForm())));

  // กรอกข้อมูลและกด submit
  await tester.enterText(find.byType(TextFormField).first, 'John');
  await tester.tap(find.text('Submit'));
  await tester.pump(); // สร้าง frame ใหม่ (ไม่รอหมด)

  // ตรวจว่ากำลัง loading
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // รอจนเสร็จ
  await tester.pumpAndSettle();
  expect(find.byType(CircularProgressIndicator), findsNothing);
});
```

---

## 5. เทคนิคและ Pattern ที่ใช้ — ใช้อะไรอย่างไร?

### 5.1 Package ที่ใช้

| Package        | หน้าที่                        | ไฟล์ที่ใช้                  |
| -------------- | ------------------------------ | --------------------------- |
| `flutter_test` | Framework หลัก (มากับ Flutter) | ทุกไฟล์ test                |
| `mockito`      | สร้าง Mock + code generation   | `api_service_test.dart`     |
| `build_runner` | Generate mock classes          | รัน command line            |
| `mocktail`     | Mock แบบไม่ต้อง generate       | `webview_service_test.dart` |
| `http`         | HTTP client                    | `api_service.dart`          |

### 5.2 เปรียบเทียบ Mockito vs Mocktail

| คุณสมบัติ       | Mockito                          | Mocktail                           |
| --------------- | -------------------------------- | ---------------------------------- |
| Code generation | ✅ ต้องใช้ `build_runner`        | ❌ ไม่ต้อง                         |
| Setup           | ใส่ `@GenerateMocks` + รัน build | สร้าง class `extends Mock`         |
| Syntax `when`   | `when(mock.method(any))`         | `when(() => mock.method(any()))`   |
| Syntax `verify` | `verify(mock.method(any))`       | `verify(() => mock.method(any()))` |
| Fallback values | ไม่ต้อง                          | ต้อง `registerFallbackValue()`     |
| **เหมาะกับ**    | โปรเจคใหญ่, interface ซับซ้อน    | โปรเจคเล็ก-กลาง, เริ่มต้นเร็ว      |

### 5.3 Matchers ที่ใช้บ่อย

```dart
// ค่าเท่ากัน
expect(result, equals(5));
expect(result, isTrue);
expect(result, isFalse);
expect(result, isNull);
expect(result, isNotNull);

// ตรวจ type
expect(result, isA<String>());
expect(result, isA<Map<String, dynamic>>());

// ตรวจ collection
expect(list, isEmpty);
expect(list, isNotEmpty);
expect(list, contains(item));
expect(list, hasLength(3));

// ตรวจ string
expect(text, contains('hello'));
expect(text, startsWith('Hello'));

// ตรวจ exception
expect(() => doSomething(), throwsA(isA<ArgumentError>()));
expect(() => doSomething(), throwsA(predicate((e) => e.message == 'error')));

// ตรวจ exception พร้อมรายละเอียด
expect(
  () => doSomething(),
  throwsA(
    isA<MyException>()
      .having((e) => e.message, 'message', contains('error'))
      .having((e) => e.code, 'code', equals(404)),
  ),
);

// ตรวจค่าตัวเลข
expect(value, greaterThan(0));
expect(value, lessThan(100));
expect(value, closeTo(3.14, 0.01));

// ตรวจ async
await expectLater(future, throwsA(isA<TimeoutException>()));
await expectLater(stream, emitsInOrder([1, 2, 3]));
```

### 5.4 Lifecycle Hooks

```dart
group('กลุ่ม Test', () {
  late MyService service;

  setUpAll(() {
    // รัน 1 ครั้งก่อนทุก test ในกลุ่ม
    // เหมาะสำหรับ setup ที่ใช้เวลานาน
  });

  setUp(() {
    // รันก่อนแต่ละ test case
    // สร้าง instance ใหม่ทุกครั้ง → test ไม่กระทบกัน
    service = MyService();
  });

  tearDown(() {
    // รันหลังแต่ละ test case
    // เหมาะสำหรับ cleanup resources
  });

  tearDownAll(() {
    // รัน 1 ครั้งหลังทุก test ในกลุ่มเสร็จ
  });
});
```

### 5.5 Pattern สำคัญที่ใช้ในโปรเจค

#### 1. Boundary Value Testing (ทดสอบค่าขอบเขต)

```
ตัวอย่าง: isAdult ตรวจ age >= 18
→ ทดสอบค่า 17 (ต่ำกว่าขอบ), 18 (บนขอบ), 19 (สูงกว่าขอบ)
```

#### 2. Round-Trip Test (ทดสอบแปลงไป-กลับ)

```dart
final original = User(id: 1, name: 'Test', ...);
final restored = User.fromMap(original.toMap());
expect(restored, equals(original));  // ← ได้ข้อมูลเดิมกลับมา
```

#### 3. Data Integrity After Exception

```dart
userService.addUser(user);
expect(() => userService.addUser(user), throwsA(...));  // ← ซ้ำ = error
expect(userService.getTotalUsers(), equals(1));  // ← ข้อมูลเดิมยังอยู่
```

#### 4. Debounce Test (ทดสอบการชะลอ)

```dart
await tester.enterText(field, 'a');     // พิมพ์
await tester.pump(Duration(ms: 50));    // รอนิดหน่อย
await tester.enterText(field, 'ab');    // พิมพ์ต่อ
await tester.pump(Duration(ms: 50));
await tester.enterText(field, 'abc');   // พิมพ์ต่อ
await tester.pump(Duration(ms: 300));   // รอ debounce หมด
expect(callCount, equals(1));           // ← เรียกแค่ครั้งเดียว
```

#### 5. Loop-Based Test (ทดสอบหลาย case ในลูป)

```dart
final testCases = {'/error/400': 400, '/error/404': 404, '/error/500': 500};
for (final entry in testCases.entries) {
  await expectLater(
    service.fetchData(entry.key),
    throwsA(isA<NetworkException>().having((e) => e.statusCode, 'status', equals(entry.value))),
  );
}
```

---

## 6. วิธีรัน Test

### รัน Test ทั้งหมด

```bash
flutter test
```

### รัน Test เฉพาะไฟล์

```bash
flutter test test/models/user_test.dart
flutter test test/services/api_service_test.dart
flutter test test/widgets/custom_widgets_test.dart
```

### รัน Test เฉพาะโฟลเดอร์

```bash
flutter test test/services/
flutter test test/utils/
```

### รัน Test พร้อม Coverage

```bash
flutter test --coverage
# ดูผลลัพธ์ที่ coverage/lcov.info
```

### Generate Mock (ต้องรันก่อนถ้าแก้ไข @GenerateMocks)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### รัน Integration Test

```bash
flutter test integration_test/
```

---

## 7. แนวคิดปัจจุบันและการต่อยอด

### 🎯 แนวคิดปัจจุบันของโปรเจค

โปรเจคนี้ออกแบบเป็น **"ห้องเรียน Unit Test"** ที่ครอบคลุม:

1. **Model Testing** — ทดสอบโครงสร้างข้อมูล
2. **Service Testing** — ทดสอบ business logic
3. **Mock Testing** — จำลอง dependency ภายนอก
4. **Async Testing** — ทดสอบงานไม่ synchronous
5. **Exception Testing** — จัดการ error อย่างเป็นระบบ
6. **Widget Testing** — ทดสอบ UI
7. **Integration Testing** — ทดสอบทั้งแอป

### 🚀 แนวทางต่อยอด

#### ระดับ 1: เพิ่มเติมสิ่งที่มี

| สิ่งที่ทำ           | วิธีทำ                       | ประโยชน์                       |
| ------------------- | ---------------------------- | ------------------------------ |
| เพิ่ม Test Coverage | เขียน test ให้ครอบคลุม 100%  | มั่นใจว่าทุก branch ถูกทดสอบ   |
| เพิ่ม Edge Case     | ทดสอบ Unicode, ข้อมูลใหญ่มาก | จับ bug ที่ซ่อนอยู่            |
| Golden Test         | เปรียบเทียบ widget กับภาพ    | ป้องกัน UI เปลี่ยนโดยไม่ตั้งใจ |

#### ระดับ 2: เพิ่ม Pattern ใหม่

| Pattern                | คำอธิบาย                  | ตัวอย่าง                         |
| ---------------------- | ------------------------- | -------------------------------- |
| **BLoC Testing**       | ทดสอบ state management    | ทดสอบ `Cubit`, `Bloc`            |
| **Repository Pattern** | แยก data source กับ logic | Mock DataSource                  |
| **Provider Testing**   | ทดสอบ ChangeNotifier      | `ProviderContainer`              |
| **Riverpod Testing**   | ทดสอบ modern state mgmt   | `ProviderContainer`, `overrides` |
| **Freezed Models**     | Immutable + code gen      | `@freezed` class                 |

#### ระดับ 3: เพิ่มเครื่องมือ

| เครื่องมือ              | คำอธิบาย                   | คำสั่ง                       |
| ----------------------- | -------------------------- | ---------------------------- |
| **CI/CD**               | รัน test อัตโนมัติ         | GitHub Actions / GitLab CI   |
| **Coverage Report**     | รายงาน coverage เป็น HTML  | `genhtml coverage/lcov.info` |
| **flutter_test_robots** | Helper สำหรับ widget test  | ลด boilerplate code          |
| **patrol**              | Integration test ที่ดีกว่า | ทดสอบ native features        |

#### ระดับ 4: Best Practices

```
✅ ตั้งชื่อ test ให้ชัดเจน: "should [ผลลัพธ์] when [เงื่อนไข]"
✅ ทุก test case ต้องเป็นอิสระ (ไม่พึ่งพา test อื่น)
✅ ใช้ setUp() สร้างข้อมูลทดสอบใหม่ทุกครั้ง
✅ ทดสอบทั้ง happy path และ error path
✅ ใช้ group() จัดกลุ่ม test ที่เกี่ยวข้อง
✅ Mock เฉพาะ external dependency (ไม่ mock โค้ดตัวเอง)
✅ ทดสอบ boundary values (ค่าขอบเขต)
✅ รัน test ก่อน commit ทุกครั้ง
```

---

## 8. สรุป Cheat Sheet

### การสร้าง Test File ใหม่

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_unit_tests/my_class.dart';

void main() {
  group('ชื่อกลุ่ม', () {
    late MyClass instance;

    setUp(() {
      instance = MyClass();
    });

    test('ควร [ผลลัพธ์] เมื่อ [เงื่อนไข]', () {
      // Arrange
      final input = 'test';

      // Act
      final result = instance.doSomething(input);

      // Assert
      expect(result, equals('expected'));
    });
  });
}
```

### สรุปคำสั่ง

| คำสั่ง                                  | หน้าที่                 |
| --------------------------------------- | ----------------------- |
| `flutter test`                          | รัน test ทั้งหมด        |
| `flutter test test/path/file_test.dart` | รัน test เฉพาะไฟล์      |
| `flutter test --coverage`               | รัน test + วัด coverage |
| `dart run build_runner build`           | Generate mock files     |
| `flutter test integration_test/`        | รัน integration test    |

### สรุป Matchers

| Matcher                  | ใช้เมื่อ                   |
| ------------------------ | -------------------------- |
| `equals(x)`              | ค่าเท่ากัน                 |
| `isTrue` / `isFalse`     | ค่า boolean                |
| `isNull` / `isNotNull`   | ค่า null                   |
| `isA<Type>()`            | ตรวจ type                  |
| `contains(x)`            | มีอยู่ใน collection/string |
| `isEmpty` / `isNotEmpty` | collection ว่าง            |
| `throwsA(matcher)`       | throw exception            |
| `closeTo(x, delta)`      | ค่าใกล้เคียง (double)      |
| `returnsNormally`        | ไม่ throw exception        |
| `findsOneWidget`         | Widget test: เจอ 1 ตัว     |
| `findsNothing`           | Widget test: ไม่เจอ        |

---

## 9. อ้างอิงจากเอกสารทางการ Flutter (Official Testing Docs)

### 📚 แหล่งเรียนรู้เพิ่มเติม

| เอกสาร                   | URL                                                                | สิ่งที่สอน                               |
| ------------------------ | ------------------------------------------------------------------ | ---------------------------------------- |
| Testing Overview         | https://docs.flutter.dev/testing/overview                          | ภาพรวม unit/widget/integration test      |
| Unit Test Introduction   | https://docs.flutter.dev/cookbook/testing/unit/introduction        | test(), group(), setUp()                 |
| Mocking Dependencies     | https://docs.flutter.dev/cookbook/testing/unit/mocking             | Mockito, DI, when/then/verify            |
| Widget Test Introduction | https://docs.flutter.dev/cookbook/testing/widget/introduction      | testWidgets, pumpWidget, Finder, Matcher |
| Widget Finders           | https://docs.flutter.dev/cookbook/testing/widget/finders           | find.text(), find.byType(), find.byKey() |
| Widget Interactions      | https://docs.flutter.dev/cookbook/testing/widget/tap-drag          | tap(), enterText(), drag(), pump()       |
| Integration Testing      | https://docs.flutter.dev/cookbook/testing/integration/introduction | แอปทั้งตัว                               |

### 🔑 สิ่งสำคัญจากเอกสารทางการ

#### pump() vs pumpAndSettle() (จากเอกสาร Widget Testing)

```dart
// pump() — rebuild widget 1 frame, ใช้เมื่อรู้ว่าต้องรอกี่ frame
await tester.tap(find.byIcon(Icons.add));
await tester.pump(); // rebuild 1 ครั้ง → เห็น setState ใหม่

// pump(Duration) — rebuild หลังผ่าน duration, ใช้กับ delay/animation
await tester.tap(find.text('Submit'));
await tester.pump(const Duration(milliseconds: 500)); // รอ 500ms แล้ว rebuild

// pumpAndSettle() — rebuild ซ้ำจนไม่มี scheduled frame (animation เสร็จหมด)
// ⚠️ ห้ามใช้กับ infinite animation (เช่น CircularProgressIndicator) จะ timeout
await tester.tap(find.text('Navigate'));
await tester.pumpAndSettle(); // รอ transition animation เสร็จ
```

#### Finder Types (จากเอกสาร Widget Finders)

```dart
// ค้นหาด้วยข้อความ — ใช้บ่อยสุด
find.text('Hello World')

// ค้นหาด้วย type ของ widget
find.byType(ElevatedButton)

// ค้นหาด้วย Key — ดีที่สุดสำหรับ widget ที่ซ้ำกัน
find.byKey(const Key('submit-button'))

// ค้นหาด้วย Icon
find.byIcon(Icons.add)

// ค้นหาด้วย tooltip
find.byTooltip('Back')

// ค้นหาด้วย widget instance
find.byWidget(myWidget)

// ค้นหาด้วย predicate (เงื่อนไขกำหนดเอง)
find.byWidgetPredicate((widget) => widget is Text && widget.data!.startsWith('Hello'))
```

#### User Interactions (จากเอกสาร Tap/Drag)

```dart
// แตะ (tap)
await tester.tap(find.byType(ElevatedButton));

// พิมพ์ข้อความ
await tester.enterText(find.byType(TextField), 'Hello');

// ลาก (drag)
await tester.drag(find.byType(Dismissible), const Offset(500, 0));

// Long press
await tester.longPress(find.byType(ListTile));
```

#### Mocking ตามแนว Flutter Docs

```dart
// 1. สร้าง abstract class เป็น interface
abstract class HttpClient {
  Future<Response> get(Uri uri);
}

// 2. สร้าง real implementation
class RealHttpClient implements HttpClient { ... }

// 3. สร้าง mock ด้วย Mockito
@GenerateMocks([HttpClient])
// หรือ Mocktail
class MockHttpClient extends Mock implements HttpClient {}

// 4. Inject mock เข้า service
final service = ApiService(mockClient);

// 5. กำหนดพฤติกรรม mock
when(mockClient.get(any)).thenAnswer((_) async => Response('{}', 200));

// 6. ทดสอบ
final result = await service.fetchData();
expect(result, isNotNull);

// 7. ตรวจว่า mock ถูกเรียก
verify(mockClient.get(any)).called(1);
```

---

## สรุป: เส้นทางการเรียนรู้แนะนำ

```
1. อ่านเอกสารนี้ก่อน (ภาพรวมทั้งหมด)
     ↓
2. เริ่มจาก test/utils/math_utils_test.dart (ง่ายที่สุด)
     ↓
3. ดู test/models/user_test.dart (ทดสอบ Model)
     ↓
4. ดู test/services/user_service_test.dart (ทดสอบ Service)
     ↓
5. ดู test/services/api_service_test.dart (เรียนรู้ Mock)
     ↓
6. ดู test/services/async_data_service_test.dart (Async/Stream)
     ↓
7. ดู test/services/exception_handling_test.dart (Exception)
     ↓
8. ดู test/widgets/custom_widgets_test.dart (Widget Test)
     ↓
9. ดู test/services/webview_service_test.dart (Mocktail)
     ↓
10. ลองเขียน test ของคุณเอง! 🎉
```

---

> **💡 เคล็ดลับ:** อ่านโค้ดใน `lib/` คู่กับไฟล์ `test/` จะเข้าใจง่ายที่สุด  
> เช่น เปิด `lib/utils/math_utils.dart` คู่กับ `test/utils/math_utils_test.dart`
