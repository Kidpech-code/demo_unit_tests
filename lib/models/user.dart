/// Model class สำหรับผู้ใช้
class User {
  final int id;
  final String name;
  final String email;
  final int age;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    this.isActive = true,
  });

  /// ตรวจสอบว่าผู้ใช้เป็นผู้ใหญ่หรือไม่
  bool get isAdult => age >= 18;

  /// ตรวจสอบว่า email มีรูปแบบที่ถูกต้องหรือไม่
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// แปลงข้อมูลผู้ใช้เป็น Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'isActive': isActive,
    };
  }

  /// สร้างผู้ใช้จาก Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  /// สำเนาผู้ใช้พร้อมแก้ไขค่าบางอย่าง
  User copyWith({
    int? id,
    String? name,
    String? email,
    int? age,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.age == age &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        age.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, age: $age, isActive: $isActive)';
  }
}
