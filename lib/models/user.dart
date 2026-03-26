/// Model class สำหรับผู้ใช้ (User Model)
///
/// ## ใช้ทำอะไร?
/// เก็บข้อมูลผู้ใช้ เช่น ชื่อ อีเมล อายุ สถานะ
/// เป็น **Immutable Object** — สร้างแล้วแก้ไม่ได้ ต้องใช้ [copyWith] สร้างตัวใหม่
///
/// ## ใช้อย่างไร?
/// ```dart
/// final user = User(id: 1, name: 'สมชาย', email: 'somchai@mail.com', age: 25);
/// print(user.isAdult);    // true
/// print(user.isValidEmail); // true
/// ```
///
/// ## แนวคิดที่สอน
/// - **Immutable Data Model** — ใช้ `final` ทุก field, ใช้ `const` constructor
/// - **Boundary Value Testing** — ทดสอบค่าขอบเขต เช่น อายุ 17, 18, 19
/// - **Round-trip Testing** — toMap → fromMap ต้องได้ข้อมูลเดิม
/// - **Equality & hashCode** — ใช้เปรียบเทียบ object ใน test ด้วย `expect(a, equals(b))`
///
/// ## ต่อยอดได้อย่างไร?
/// - เพิ่ม validation ใน constructor (เช่น age ต้อง >= 0)
/// - เพิ่ม `toJson()`/`fromJson()` สำหรับ REST API
/// - ใช้ package `freezed` หรือ `json_serializable` ลดโค้ดซ้ำ
class User {
  /// รหัสผู้ใช้ — ต้องไม่ซ้ำกัน ใช้เป็น Primary Key
  final int id;

  /// ชื่อผู้ใช้ — ใช้แสดงใน UI และค้นหา
  final String name;

  /// อีเมลผู้ใช้ — ใช้ validate ด้วย [isValidEmail]
  final String email;

  /// อายุผู้ใช้ — ใช้ตรวจสอบว่าเป็นผู้ใหญ่ด้วย [isAdult]
  final int age;

  /// สถานะการใช้งาน — ค่า default เป็น `true` (ใช้งานอยู่)
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    this.isActive = true,
  });

  /// ตรวจสอบว่าผู้ใช้เป็นผู้ใหญ่หรือไม่ (อายุ >= 18)
  ///
  /// ## ใช้ทำอะไร?
  /// ใช้กรองผู้ใช้ที่มีสิทธิ์เข้าถึงเนื้อหาสำหรับผู้ใหญ่
  ///
  /// ## แนวคิด Testing: Boundary Value Analysis
  /// ค่าขอบ = 18 → ต้องทดสอบ: 17 (false), 18 (true), 19 (true)
  bool get isAdult => age >= 18;

  /// ตรวจสอบว่า email มีรูปแบบที่ถูกต้องหรือไม่
  ///
  /// ใช้ RegExp ตรวจรูปแบบ `name@domain.ext`
  /// ไม่ได้ตรวจว่ามีอยู่จริง แค่ตรวจรูปแบบเท่านั้น
  ///
  /// ## ต่อยอด: ควรย้ายไปใช้ StringHelper.isValidEmail() แทน
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// แปลงข้อมูลผู้ใช้เป็น Map (Serialization)
  ///
  /// ## ใช้ทำอะไร?
  /// - บันทึกลง SharedPreferences หรือ SQLite
  /// - ส่งข้อมูลผ่าน API
  ///
  /// ## แนวคิด Testing: Round-trip Test
  /// `User.fromMap(user.toMap())` ต้องได้ผลลัพธ์เท่ากับ user เดิม
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'isActive': isActive,
    };
  }

  /// สร้างผู้ใช้จาก Map (Deserialization)
  ///
  /// ## ใช้ทำอะไร?
  /// แปลงข้อมูลจาก JSON/Map กลับเป็น User object
  ///
  /// ## ข้อควรรู้
  /// - ถ้า field ไม่มีจะใช้ค่า default (เช่น id=0, name='')
  /// - ควรทดสอบกรณี Map ว่าง และ Map ที่ขาด field
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  /// สำเนาผู้ใช้พร้อมแก้ไขค่าบางอย่าง (Immutable Update Pattern)
  ///
  /// ## ใช้ทำอะไร?
  /// สร้าง User ใหม่โดยเปลี่ยนแค่ field ที่ต้องการ ไม่แก้ object เดิม
  ///
  /// ```dart
  /// final updated = user.copyWith(name: 'ชื่อใหม่');
  /// // user เดิมไม่เปลี่ยน, updated เป็น object ใหม่
  /// ```
  ///
  /// ## แนวคิด Testing
  /// - ตรวจว่า object เดิมไม่เปลี่ยน (Immutability)
  /// - ตรวจว่า field ที่ไม่ได้ระบุยังคงค่าเดิม
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

  /// เปรียบเทียบ User สอง object ว่าเท่ากันหรือไม่
  ///
  /// ## ใช้ทำอะไร?
  /// ทำให้ใช้ `expect(user1, equals(user2))` ใน test ได้
  /// ถ้าไม่ override จะเปรียบเทียบด้วย reference (ตำแหน่งในหน่วยความจำ)
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

  /// hashCode ต้อง override คู่กับ == เสมอ
  ///
  /// ถ้า a == b จะต้อง a.hashCode == b.hashCode ด้วย
  @override
  int get hashCode => Object.hash(id, name, email, age, isActive);

  /// แสดงข้อมูล User เป็นข้อความ — ใช้ debug และ test toString
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, age: $age, isActive: $isActive)';
  }
}
