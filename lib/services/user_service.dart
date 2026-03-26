import '../models/user.dart';

/// คลาสสำหรับจัดการข้อมูลผู้ใช้
class UserService {
  final List<User> _users = [];

  /// เพิ่มผู้ใช้ใหม่
  void addUser(User user) {
    if (_users.any((u) => u.id == user.id)) {
      throw ArgumentError('User with ID ${user.id} already exists');
    }
    _users.add(user);
  }

  /// ลบผู้ใช้ตาม ID
  bool removeUser(int userId) {
    int initialLength = _users.length;
    _users.removeWhere((user) => user.id == userId);
    return _users.length < initialLength;
  }

  /// ค้นหาผู้ใช้ตาม ID
  User? findUserById(int userId) {
    for (final user in _users) {
      if (user.id == userId) return user;
    }
    return null;
  }

  /// ค้นหาผู้ใช้ตาม email
  User? findUserByEmail(String email) {
    for (final user in _users) {
      if (user.email == email) return user;
    }
    return null;
  }

  /// อัปเดตข้อมูลผู้ใช้
  bool updateUser(int userId, User updatedUser) {
    int index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = updatedUser.copyWith(id: userId);
      return true;
    }
    return false;
  }

  /// ดึงผู้ใช้ทั้งหมด
  List<User> getAllUsers() {
    return List.unmodifiable(_users);
  }

  /// ดึงผู้ใช้ที่เป็นผู้ใหญ่
  List<User> getAdultUsers() {
    return _users.where((user) => user.isAdult).toList();
  }

  /// ดึงผู้ใช้ที่ยังใช้งานอยู่
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

  /// ล้างข้อมูลผู้ใช้ทั้งหมด
  void clearAllUsers() {
    _users.clear();
  }

  /// ดึงผู้ใช้ที่มีอายุในช่วงที่กำหนด
  List<User> getUsersByAgeRange(int minAge, int maxAge) {
    if (minAge < 0 || maxAge < 0 || minAge > maxAge) {
      throw ArgumentError('Invalid age range');
    }
    return _users
        .where((user) => user.age >= minAge && user.age <= maxAge)
        .toList();
  }

  /// เปิดใช้งาน/ปิดใช้งานผู้ใช้
  bool toggleUserStatus(int userId) {
    User? user = findUserById(userId);
    if (user != null) {
      return updateUser(userId, user.copyWith(isActive: !user.isActive));
    }
    return false;
  }
}
