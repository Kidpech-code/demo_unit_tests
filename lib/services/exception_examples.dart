/// Exception classes สำหรับตัวอย่าง unit test
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

class BusinessLogicException implements Exception {
  final String message;
  final String errorCode;

  const BusinessLogicException(this.message, this.errorCode);

  @override
  String toString() => 'BusinessLogicException: $message (code: $errorCode)';
}

/// Service class ที่มี error handling
class ValidationService {
  /// ตรวจสอบอีเมล
  void validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      throw ValidationException('Email is required', field: 'email');
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw ValidationException('Invalid email format', field: 'email');
    }
  }

  /// ตรวจสอบรหัสผ่าน
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

  /// ตรวจสอบอายุ
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

  /// ตรวจสอบข้อมูลผู้ใช้ทั้งหมด
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

/// Service class สำหรับจำลองการทำงานกับ network
class NetworkService {
  /// จำลองการเรียก API ที่อาจล้มเหลว
  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    await Future.delayed(Duration(milliseconds: 100)); // จำลองความล่าช้า

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
      await Future.delayed(Duration(seconds: 10)); // จำลองการ timeout
      return {'data': 'success'};
    }

    return {
      'data': 'success',
      'endpoint': endpoint,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// เรียก API พร้อมการจัดการ retry
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

/// Business logic service
class AccountService {
  final Map<String, double> _accounts = {};

  /// สร้างบัญชีใหม่
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

  /// ฝากเงิน
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

  /// ถอนเงิน
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

  /// โอนเงิน
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

  /// ดูยอดเงิน
  double getBalance(String accountId) {
    if (!_accounts.containsKey(accountId)) {
      throw BusinessLogicException('Account not found', 'ACCOUNT_NOT_FOUND');
    }

    return _accounts[accountId]!;
  }
}
