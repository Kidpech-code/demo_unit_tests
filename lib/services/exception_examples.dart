/// ===================================================================
/// Exception Classes & Services สำหรับสอน Exception Handling Testing
/// ===================================================================
///
/// ## ภาพรวม
/// ไฟล์นี้สอน 3 แนวคิดหลัก:
///
/// ### 1. Custom Exception Classes
/// สร้าง Exception เองที่มีข้อมูลเพิ่มเติม (field, statusCode, errorCode)
/// ทำให้ catch แล้วดึงรายละเอียดได้ → ดีกว่า throw String ธรรมดา
///
/// ### 2. Exception Testing Patterns
/// ```dart
/// // ตรวจว่า throw exception ชนิดที่ถูกต้อง
/// expect(() => fn(), throwsA(isA<ValidationException>()));
///
/// // ตรวจ message ข้างในด้วย .having()
/// expect(
///   () => fn(),
///   throwsA(isA<ValidationException>()
///     .having((e) => e.message, 'message', 'Email is required')
///     .having((e) => e.field, 'field', 'email')),
/// );
/// ```
///
/// ### 3. Business Logic Testing
/// ทดสอบ logic ที่ซับซ้อน เช่น โอนเงิน → ต้อง rollback ถ้าล้มเหลว
///
/// ## ต่อยอดได้อย่างไร?
/// - เพิ่ม `AuthenticationException`, `PermissionException`
/// - ใช้ `sealed class` (Dart 3.0+) แทน `implements Exception`
/// - สร้าง global error handler ที่แปลง Exception เป็น user-friendly message

/// Custom Exception สำหรับ Validation — มี [field] บอกว่าผิดที่ field ไหน
///
/// ## ใช้ทำอะไร?
/// ใช้เมื่อข้อมูลที่ user ป้อนเข้ามาไม่ถูกต้อง
///
/// ## ทดสอบ
/// ```dart
/// expect(
///   () => service.validateEmail(null),
///   throwsA(isA<ValidationException>()
///     .having((e) => e.field, 'field', 'email')),
/// );
/// ```
class ValidationException implements Exception {
  final String message;
  final String? field;

  const ValidationException(this.message, {this.field});

  @override
  String toString() {
    return field != null
        ? 'ValidationException: $message (field: $field)'
        : 'ValidationException: $message';
  }
}

/// Custom Exception สำหรับ Network Error — มี [statusCode]
///
/// ## ใช้ทำอะไร?
/// ใช้เมื่อ HTTP request ล้มเหลว พร้อม status code
/// ทำให้ caller ตัดสินใจได้ว่าจะ retry หรือไม่ (4xx ไม่ retry, 5xx retry)
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(this.message, {this.statusCode});

  @override
  String toString() {
    return statusCode != null
        ? 'NetworkException: $message (status: $statusCode)'
        : 'NetworkException: $message';
  }
}

/// Custom Exception สำหรับ Business Logic Error — มี [errorCode]
///
/// ## ใช้ทำอะไร?
/// ใช้เมื่อ business rule ไม่ผ่าน เช่น ยอดเงินไม่พอ, บัญชีซ้ำ
/// `errorCode` ใช้ map กับ UI error messages
class BusinessLogicException implements Exception {
  final String message;
  final String errorCode;

  const BusinessLogicException(this.message, this.errorCode);

  @override
  String toString() => 'BusinessLogicException: $message (code: $errorCode)';
}

/// Service สำหรับ Validation — สอน Exception Testing แบบละเอียด
///
/// ## แนวคิดที่สอน
/// - **throwsA + isA<T>** — ตรวจ type ของ exception
/// - **isA<T>.having()** — ตรวจ property ข้างใน exception
/// - **try/catch ซ้อน** — validateUser จับ error จากหลายฟังก์ชัน
///
/// ## ทดสอบ
/// แต่ละ validate function ต้องทดสอบ:
/// 1. null → throw
/// 2. empty → throw
/// 3. ค่าผิดรูปแบบ → throw พร้อม message ที่ถูกต้อง
/// 4. ค่าถูกต้อง → ไม่ throw (ใช้ `expect(() => fn(), returnsNormally)`)
class ValidationService {
  /// ตรวจสอบอีเมล — throw [ValidationException] ถ้าไม่ถูกต้อง
  ///
  /// field: 'email' → บอก caller ว่า error มาจาก field ไหน
  void validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      throw ValidationException('Email is required', field: 'email');
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw ValidationException('Invalid email format', field: 'email');
    }
  }

  /// ตรวจสอบรหัสผ่าน — ต้องยาว >= 8, มีตัวใหญ่, มีตัวเลข
  ///
  /// ## ทดสอบแยกทีละเงื่อนไข
  /// - null → 'Password is required'
  /// - 'abc' → 'must be at least 8 characters'
  /// - 'abcdefgh' → 'must contain uppercase letter'
  /// - 'ABCDEFGH' → 'must contain number'
  void validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      throw ValidationException('Password is required', field: 'password');
    }

    if (password.length < 8) {
      throw ValidationException(
        'Password must be at least 8 characters',
        field: 'password',
      );
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      throw ValidationException(
        'Password must contain uppercase letter',
        field: 'password',
      );
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      throw ValidationException(
        'Password must contain number',
        field: 'password',
      );
    }
  }

  /// ตรวจสอบอายุ — ต้องอยู่ในช่วง 0-150
  void validateAge(int? age) {
    if (age == null) {
      throw ValidationException('Age is required', field: 'age');
    }

    if (age < 0) {
      throw ValidationException('Age cannot be negative', field: 'age');
    }

    if (age > 150) {
      throw ValidationException('Age cannot exceed 150', field: 'age');
    }
  }

  /// ตรวจสอบข้อมูลผู้ใช้ทั้งหมด — รวม error จากทุก field
  ///
  /// ## แนวคิด Testing: Multiple Validation
  /// ถ้ามีหลาย field ผิด → เก็บ error ทั้งหมดแล้ว throw ทีเดียว
  /// ทดสอบ: ส่งค่าผิดหลาย field → ตรวจว่า message รวมทุก error
  void validateUser({String? email, String? password, int? age}) {
    final errors = <String>[];

    try {
      validateEmail(email);
    } on ValidationException catch (e) {
      errors.add(e.message);
    }

    try {
      validatePassword(password);
    } on ValidationException catch (e) {
      errors.add(e.message);
    }

    try {
      validateAge(age);
    } on ValidationException catch (e) {
      errors.add(e.message);
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        'Multiple validation errors: ${errors.join(', ')}',
      );
    }
  }
}

/// Service สำหรับจำลอง Network — สอน HTTP Error Handling
///
/// ## แนวคิดที่สอน
/// - **HTTP Status Codes** — 400 Bad Request, 401 Unauthorized, 404 Not Found, 500 Server Error
/// - **Retry Logic** — retry เฉพาะ 5xx (server error), ไม่ retry 4xx (client error)
/// - **Endpoint Routing** — จำลอง endpoint ต่างๆ ให้ผลลัพธ์ต่างกัน
///
/// ## ทดสอบ
/// ทดสอบทุก endpoint: '/error/400', '/error/401', '/error/404', '/error/500'
/// ตรวจทั้ง type (NetworkException) และ statusCode
class NetworkService {
  /// จำลองการเรียก API — เลือก endpoint ต่างกัน ได้ผลต่างกัน
  ///
  /// - `'/error/400'` → throw NetworkException(statusCode: 400)
  /// - `'/error/401'` → throw NetworkException(statusCode: 401)
  /// - `'/error/404'` → throw NetworkException(statusCode: 404)
  /// - `'/error/500'` → throw NetworkException(statusCode: 500)
  /// - อื่นๆ → return success Map
  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (endpoint.isEmpty) {
      throw ArgumentError('Endpoint cannot be empty');
    }

    if (endpoint == '/error/400') {
      throw NetworkException('Bad Request', statusCode: 400);
    }

    if (endpoint == '/error/401') {
      throw NetworkException('Unauthorized', statusCode: 401);
    }

    if (endpoint == '/error/404') {
      throw NetworkException('Not Found', statusCode: 404);
    }

    if (endpoint == '/error/500') {
      throw NetworkException('Internal Server Error', statusCode: 500);
    }

    if (endpoint == '/timeout') {
      await Future.delayed(const Duration(seconds: 10));
      return {'data': 'success'};
    }

    return {
      'data': 'success',
      'endpoint': endpoint,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// เรียก API พร้อม Retry Logic
  ///
  /// ## Retry Strategy
  /// - **4xx** (Client Error) → **ไม่ retry** (rethrow ทันที)
  /// - **5xx** (Server Error) → retry ตาม maxRetries
  /// - retry หมด → rethrow
  ///
  /// ## ทดสอบ
  /// - endpoint '/error/400' → throw ทันที ไม่ retry
  /// - endpoint '/error/500' + maxRetries: 1 → throw หลัง retry 1 ครั้ง
  Future<Map<String, dynamic>> fetchDataWithRetry(
    String endpoint, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(milliseconds: 100),
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        return await fetchData(endpoint);
      } on NetworkException catch (e) {
        attempt++;

        // ไม่ retry สำหรับ client errors (4xx)
        if (e.statusCode != null &&
            e.statusCode! >= 400 &&
            e.statusCode! < 500) {
          rethrow;
        }

        if (attempt >= maxRetries) {
          rethrow;
        }

        await Future.delayed(retryDelay);
      }
    }

    throw NetworkException('Max retries exceeded');
  }
}

/// Service สำหรับจัดการบัญชีเงิน — สอน **Business Logic Testing**
///
/// ## แนวคิดที่สอน
/// - **State Management** — ใช้ Map เก็บยอดเงินแต่ละบัญชี
/// - **Transaction Rollback** — transfer ล้มเหลว → คืนเงินให้ต้นทาง
/// - **Business Rules** — ห้ามฝากค่าลบ, ห้ามถอนเกินยอด, ห้ามโอนไปบัญชีเดียวกัน
/// - **Error Code Pattern** — ใช้ errorCode เช่น 'INSUFFICIENT_FUNDS'
///   → frontend ใช้ code นี้แสดง error message ที่เหมาะสม
///
/// ## ทดสอบ
/// - ใช้ `setUp()` สร้างบัญชีใหม่ทุก test
/// - ทดสอบ transfer: ตรวจยอดทั้ง 2 บัญชีหลังโอน
/// - ทดสอบ rollback: โอนไปบัญชีที่ไม่มี → ตรวจว่ายอดต้นทางไม่เปลี่ยน
class AccountService {
  final Map<String, double> _accounts = {};

  /// สร้างบัญชีใหม่ — throw [BusinessLogicException] ถ้า:
  /// - accountId ว่าง → errorCode: 'INVALID_ACCOUNT_ID'
  /// - initialBalance ติดลบ → errorCode: 'NEGATIVE_BALANCE'
  /// - บัญชีซ้ำ → errorCode: 'DUPLICATE_ACCOUNT'
  void createAccount(String accountId, double initialBalance) {
    if (accountId.isEmpty) {
      throw BusinessLogicException(
        'Account ID cannot be empty',
        'INVALID_ACCOUNT_ID',
      );
    }

    if (initialBalance < 0) {
      throw BusinessLogicException(
        'Initial balance cannot be negative',
        'NEGATIVE_BALANCE',
      );
    }

    if (_accounts.containsKey(accountId)) {
      throw BusinessLogicException(
        'Account already exists',
        'DUPLICATE_ACCOUNT',
      );
    }

    _accounts[accountId] = initialBalance;
  }

  /// ฝากเงิน — amount ต้อง > 0 + บัญชีต้องมีอยู่
  void deposit(String accountId, double amount) {
    if (!_accounts.containsKey(accountId)) {
      throw BusinessLogicException('Account not found', 'ACCOUNT_NOT_FOUND');
    }

    if (amount <= 0) {
      throw BusinessLogicException(
        'Deposit amount must be positive',
        'INVALID_AMOUNT',
      );
    }

    _accounts[accountId] = _accounts[accountId]! + amount;
  }

  /// ถอนเงิน — ตรวจยอดเงินคงเหลือ (Insufficient Funds Check)
  void withdraw(String accountId, double amount) {
    if (!_accounts.containsKey(accountId)) {
      throw BusinessLogicException('Account not found', 'ACCOUNT_NOT_FOUND');
    }

    if (amount <= 0) {
      throw BusinessLogicException(
        'Withdrawal amount must be positive',
        'INVALID_AMOUNT',
      );
    }

    final currentBalance = _accounts[accountId]!;
    if (amount > currentBalance) {
      throw BusinessLogicException('Insufficient funds', 'INSUFFICIENT_FUNDS');
    }

    _accounts[accountId] = currentBalance - amount;
  }

  /// โอนเงิน — **มี Rollback** ถ้า deposit ไปบัญชีปลายทางล้มเหลว
  ///
  /// ## Transaction Flow
  /// 1. withdraw จากบัญชีต้นทาง
  /// 2. deposit ไปบัญชีปลายทาง
  /// 3. ถ้า step 2 ล้มเหลว → deposit เงินกลับบัญชีต้นทาง (rollback)
  ///
  /// ## ทดสอบ Rollback
  /// ```dart
  /// // สร้างแค่ account A ไม่สร้าง account B
  /// accountService.createAccount('A', 1000);
  /// // โอนจาก A ไป B → B ไม่มี → expect throw
  /// // ตรวจว่ายอด A ยังเป็น 1000 (rollback สำเร็จ)
  /// ```
  void transfer(String fromAccountId, String toAccountId, double amount) {
    if (fromAccountId == toAccountId) {
      throw BusinessLogicException(
        'Cannot transfer to same account',
        'SAME_ACCOUNT_TRANSFER',
      );
    }

    // ใช้ withdraw และ deposit ที่มีการ validate อยู่แล้ว
    withdraw(fromAccountId, amount);
    try {
      deposit(toAccountId, amount);
    } catch (e) {
      // ถ้า deposit ล้มเหลว ให้คืนเงินกลับไปยัง account ต้นทาง
      deposit(fromAccountId, amount);
      rethrow;
    }
  }

  /// ดูยอดเงิน — throw ถ้าบัญชีไม่มี
  double getBalance(String accountId) {
    if (!_accounts.containsKey(accountId)) {
      throw BusinessLogicException('Account not found', 'ACCOUNT_NOT_FOUND');
    }

    return _accounts[accountId]!;
  }
}
