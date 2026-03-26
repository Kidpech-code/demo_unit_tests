import '../models/user.dart';

/// Service สำหรับจัดการข้อมูลผู้ใช้ (CRUD Operations)
///
/// ## ใช้ทำอะไร?
/// จัดการรายชื่อผู้ใช้แบบ In-Memory — เพิ่ม, ลบ, ค้นหา, อัปเดต
///
/// ## แนวคิดที่สอน
/// - **State-based Testing** — ทดสอบสถานะก่อน/หลังเรียกฟังก์ชัน
///   → เช่น addUser แล้ว getTotalUsers ต้องเพิ่ม 1
/// - **setUp/tearDown** — ใช้ `setUp()` สร้างข้อมูลใหม่ทุกครั้งก่อน test
///   → แต่ละ test ไม่กระทบกัน (Test Isolation)
/// - **CRUD Testing** — ทดสอบครบทุก operation: Create, Read, Update, Delete
/// - **Exception Testing** — addUser ที่ ID ซ้ำ → throwsA
/// - **Unmodifiable List** — getAllUsers() return list ที่แก้ไขไม่ได้
///
/// ## ต่อยอดได้อย่างไร?
/// - แยก interface `UserRepository` สำหรับ DI
/// - เพิ่มการเชื่อมต่อ database จริง (SQLite, Firebase)
/// - เพิ่ม pagination สำหรับ getAllUsers
class UserService {
  final List<User> _users = [];

  /// เพิ่มผู้ใช้ใหม่ — **throw ArgumentError** ถ้า ID ซ้ำ
  ///
  /// ## แนวคิด Testing
  /// ทดสอบ 2 กรณี:
  /// 1. เพิ่มสำเร็จ → ตรวจ getTotalUsers เพิ่มขึ้น
  /// 2. ID ซ้ำ → `expect(() => addUser(dup), throwsA(isA<ArgumentError>()))`
  void addUser(User user) {
    if (_users.any((u) => u.id == user.id)) {
      throw ArgumentError('User with ID ${user.id} already exists');
    }
    _users.add(user);
  }

  /// ลบผู้ใช้ตาม ID — return `true` ถ้าลบสำเร็จ, `false` ถ้าไม่เจอ
  ///
  /// ## แนวคิด Testing: Return Value Testing
  /// - ลบ ID ที่มีอยู่ → true + ตรวจว่า list ลดลง
  /// - ลบ ID ที่ไม่มี → false + ตรวจว่า list ไม่เปลี่ยน
  bool removeUser(int userId) {
    int initialLength = _users.length;
    _users.removeWhere((user) => user.id == userId);
    return _users.length < initialLength;
  }

  /// ค้นหาผู้ใช้ตาม ID — return `null` ถ้าไม่เจอ
  ///
  /// ## แนวคิด Testing: Nullable Return
  /// - เจอ → ตรวจว่า user ที่ได้ตรงกัน
  /// - ไม่เจอ → `expect(result, isNull)`
  User? findUserById(int userId) {
    for (final user in _users) {
      if (user.id == userId) return user;
    }
    return null;
  }

  /// ค้นหาผู้ใช้ตาม email — return `null` ถ้าไม่เจอ
  User? findUserByEmail(String email) {
    for (final user in _users) {
      if (user.email == email) return user;
    }
    return null;
  }

  /// อัปเดตข้อมูลผู้ใช้ — return `true` ถ้าอัปเดตสำเร็จ
  ///
  /// ## ข้อควรรู้
  /// ใช้ `copyWith(id: userId)` เพื่อรักษา ID เดิมไว้
  /// ป้องกันการเปลี่ยน ID โดยไม่ตั้งใจ
  bool updateUser(int userId, User updatedUser) {
    int index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = updatedUser.copyWith(id: userId);
      return true;
    }
    return false;
  }

  /// ดึงผู้ใช้ทั้งหมด — return **List.unmodifiable** (แก้ไขไม่ได้)
  ///
  /// ## แนวคิด Testing: Immutable Return
  /// ทดสอบว่า list ที่ return กลับมาแก้ไขไม่ได้:
  /// `expect(() => list.add(user), throwsUnsupportedError)`
  List<User> getAllUsers() {
    return List.unmodifiable(_users);
  }

  /// ดึงผู้ใช้ที่เป็นผู้ใหญ่ (อายุ >= 18) — ใช้ `where()` + `isAdult`
  List<User> getAdultUsers() {
    return _users.where((user) => user.isAdult).toList();
  }

  /// ดึงผู้ใช้ที่ยังใช้งานอยู่ (`isActive == true`)
  List<User> getActiveUsers() {
    return _users.where((user) => user.isActive).toList();
  }

  /// นับจำนวนผู้ใช้ทั้งหมด
  int getTotalUsers() {
    return _users.length;
  }

  /// ตรวจสอบว่ามีผู้ใช้หรือไม่
  bool hasUsers() {
    return _users.isNotEmpty;
  }

  /// ล้างข้อมูลผู้ใช้ทั้งหมด — ใช้ใน `tearDown()` ของ test
  void clearAllUsers() {
    _users.clear();
  }

  /// ดึงผู้ใช้ที่มีอายุในช่วงที่กำหนด — **throw ArgumentError** ถ้าช่วงไม่ถูกต้อง
  ///
  /// ## ทดสอบ Boundary
  /// - minAge > maxAge → throwsA
  /// - minAge < 0 → throwsA
  /// - ช่วงปกติ → ตรวจจำนวนและค่าที่ได้
  List<User> getUsersByAgeRange(int minAge, int maxAge) {
    if (minAge < 0 || maxAge < 0 || minAge > maxAge) {
      throw ArgumentError('Invalid age range');
    }
    return _users
        .where((user) => user.age >= minAge && user.age <= maxAge)
        .toList();
  }

  /// เปิดใช้งาน/ปิดใช้งานผู้ใช้ (Toggle) — return `true` ถ้าสำเร็จ
  ///
  /// ## แนวคิด Testing: State Toggle
  /// ทดสอบว่าเรียกซ้ำ 2 ครั้ง → กลับมาค่าเดิม
  bool toggleUserStatus(int userId) {
    User? user = findUserById(userId);
    if (user != null) {
      return updateUser(userId, user.copyWith(isActive: !user.isActive));
    }
    return false;
  }
}
